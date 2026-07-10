import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ft_mobile_agent_flutter/ft_rum.dart';
import 'package:ft_mobile_agent_flutter/ft_tracing.dart';
import 'package:uuid/uuid.dart';

import 'ft_http_override_config.dart';

enum _RequestMethod { get, post, delete, head, patch, put }

const responseReadLimit = 33554432; //32 MB data

extension _RequestMethodExt on _RequestMethod {
  String get value {
    return this.name;
  }
}

typedef _ConnectionReuseTracker = bool Function(
    Uri uri, bool persistentConnection);

int _headersByteSize(Map<String, Object?>? headers) {
  if (headers == null || headers.isEmpty) {
    return 0;
  }

  var size = 2; // Final CRLF after the header block.
  headers.forEach((name, value) {
    final headerValue = value is Iterable
        ? value.map((item) => item.toString()).join(',')
        : value?.toString() ?? '';
    size += utf8.encode(name).length;
    size += 2; // ": "
    size += utf8.encode(headerValue).length;
    size += 2; // CRLF
  });
  return size;
}

String _connectionKey(Uri uri) {
  final scheme = uri.scheme.toLowerCase();
  final defaultPort = scheme == 'https'
      ? 443
      : scheme == 'http'
          ? 80
          : 0;
  final port = uri.hasPort ? uri.port : defaultPort;
  return '$scheme://${uri.host.toLowerCase()}:$port';
}

String? _resourceHttpProtocol(String url) {
  final scheme = Uri.tryParse(url)?.scheme.toLowerCase();
  if (scheme == 'http' || scheme == 'https') {
    return 'http/1.1';
  }
  return null;
}

String _resourceTypeForHttp(String method, Map<String, String>? headers) {
  final upperMethod = method.toUpperCase();
  if (upperMethod == 'POST' ||
      upperMethod == 'PUT' ||
      upperMethod == 'DELETE') {
    return 'native';
  }

  final contentType = _headerValue(headers, HttpHeaders.contentTypeHeader)
      ?.split(';')
      .first
      .trim()
      .toLowerCase();
  if (contentType == null || contentType.isEmpty) {
    return 'native';
  }
  if (contentType.startsWith('image/')) {
    return 'image';
  }
  if (contentType.startsWith('video/') || contentType.startsWith('audio/')) {
    return 'media';
  }
  if (contentType.startsWith('font/')) {
    return 'font';
  }
  if (contentType == 'text/css') {
    return 'css';
  }
  if (contentType == 'text/javascript' ||
      contentType == 'text/ecmascript' ||
      contentType == 'application/javascript' ||
      contentType == 'application/ecmascript' ||
      contentType == 'application/x-javascript') {
    return 'js';
  }
  return 'native';
}

String? _headerValue(Map<String, String>? headers, String name) {
  if (headers == null || headers.isEmpty) {
    return null;
  }
  final lowerName = name.toLowerCase();
  for (final entry in headers.entries) {
    if (entry.key.toLowerCase() == lowerName) {
      return entry.value;
    }
  }
  return null;
}

Map<String, String> _collectHeaders(HttpHeaders headers) {
  final map = <String, String>{};
  headers.forEach((name, values) {
    map[name] = values.join(',');
  });
  return map;
}

class FTHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    if (FTHttpOverrideConfig.global.traceHeader ||
        FTHttpOverrideConfig.global.traceResource) {
      return FTHttpClient(super.createHttpClient(context));
    }
    return super.createHttpClient(context);
  }
}

class FTHttpClient implements HttpClient {
  final Uuid _uuid = const Uuid();
  final HttpClient _httpClient;
  final Set<String> _seenConnectionKeys = <String>{};

  FTHttpClient(this._httpClient);

  bool _markConnectionReuse(Uri uri, bool persistentConnection) {
    if (!persistentConnection) {
      return false;
    }
    final key = _connectionKey(uri);
    final reused = _seenConnectionKeys.contains(key);
    _seenConnectionKeys.add(key);
    return reused;
  }

  @override
  Future<HttpClientRequest> open(
      String method, String host, int port, String path) {
    Uri uri = Uri(scheme: 'http', host: host, port: port, path: path);
    return _openUrl(method, uri);
  }

  Future<HttpClientRequest> _openUrl(String method, Uri url) async {
    String? uniqueKey;
    HttpClientRequest request;
    String urlString = url.toString();

    bool isUrlInTake =
        FTHttpOverrideConfig.global.isInTakeUrl?.call(urlString) ?? false;

    try {
      if (!isUrlInTake && FTHttpOverrideConfig.global.traceResource) {
        uniqueKey = _uuid.v4();
        FTRUMManager().startResource(uniqueKey);
      }

      final traceHeaders = FTHttpOverrideConfig.global.traceHeader
          ? await FTTracer().getTraceHeader(urlString, key: uniqueKey)
          : {};
      request = await _httpClient.openUrl(method, url);
      traceHeaders.forEach((key, value) {
        request.headers.add(key, value);
      });
    } catch (e) {
      if (uniqueKey != null) {
        try {
          FTRUMManager().stopResource(uniqueKey);
          FTRUMManager().addResource(
              key: uniqueKey,
              url: urlString,
              httpMethod: method,
              requestHeader: {},
              responseBody: e.toString(),
              resourceType: _resourceTypeForHttp(method, null));
        } catch (innerE) {}
      }
      rethrow;
    }

    request = _GCHttpRequest(request, uniqueKey, url, _markConnectionReuse);

    return request;
  }

  @override
  set connectionFactory(
          Future<ConnectionTask<Socket>> Function(
                  Uri url, String? proxyHost, int? proxyPort)?
              f) =>
      _httpClient.connectionFactory = f;

  @override
  set keyLog(Function(String line)? callback) => _httpClient.keyLog = callback;

  @override
  bool get autoUncompress => _httpClient.autoUncompress;

  @override
  set autoUncompress(bool value) => _httpClient.autoUncompress = value;

  @override
  Duration? get connectionTimeout => _httpClient.connectionTimeout;

  @override
  set connectionTimeout(Duration? value) =>
      _httpClient.connectionTimeout = value;

  @override
  Duration get idleTimeout => _httpClient.idleTimeout;

  @override
  set idleTimeout(Duration value) => _httpClient.idleTimeout = value;

  @override
  int? get maxConnectionsPerHost => _httpClient.maxConnectionsPerHost;

  @override
  set maxConnectionsPerHost(int? value) =>
      _httpClient.maxConnectionsPerHost = value;

  @override
  String? get userAgent => _httpClient.userAgent;

  @override
  set userAgent(String? value) => _httpClient.userAgent = value;

  @override
  void addCredentials(
      Uri url, String realm, HttpClientCredentials credentials) {
    _httpClient.addCredentials(url, realm, credentials);
  }

  @override
  void addProxyCredentials(
      String host, int port, String realm, HttpClientCredentials credentials) {
    _httpClient.addProxyCredentials(host, port, realm, credentials);
  }

  @override
  set authenticate(
          Future<bool> Function(Uri url, String scheme, String? realm)? f) =>
      _httpClient.authenticate = f;

  @override
  set authenticateProxy(
          Future<bool> Function(
                  String host, int port, String scheme, String? realm)?
              f) =>
      _httpClient.authenticateProxy = f;

  @override
  set badCertificateCallback(
          bool Function(X509Certificate cert, String host, int port)?
              callback) =>
      _httpClient.badCertificateCallback = callback;

  @override
  void close({bool force = false}) {
    _httpClient.close(force: force);
  }

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) {
    return _openUrl(_RequestMethod.delete.value,
        Uri(scheme: 'http', host: host, port: port, path: path));
  }

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) =>
      _openUrl(_RequestMethod.delete.value, url);

  @override
  set findProxy(String Function(Uri url)? f) => _httpClient.findProxy = f;

  @override
  Future<HttpClientRequest> get(String host, int port, String path) {
    return _openUrl(_RequestMethod.get.value,
        Uri(scheme: 'http', host: host, port: port, path: path));
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) =>
      _openUrl(_RequestMethod.get.value, url);

  @override
  Future<HttpClientRequest> head(String host, int port, String path) {
    return _openUrl(_RequestMethod.head.value,
        Uri(scheme: 'http', host: host, port: port, path: path));
  }

  @override
  Future<HttpClientRequest> headUrl(Uri url) =>
      _openUrl(_RequestMethod.head.value, url);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      _openUrl(method, url);

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) {
    return _openUrl(_RequestMethod.patch.value,
        Uri(scheme: 'http', host: host, port: port, path: path));
  }

  @override
  Future<HttpClientRequest> patchUrl(Uri url) =>
      _openUrl(_RequestMethod.patch.value, url);

  @override
  Future<HttpClientRequest> post(String host, int port, String path) {
    return _openUrl(_RequestMethod.post.value,
        Uri(scheme: 'http', host: host, port: port, path: path));
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) =>
      _openUrl(_RequestMethod.post.value, url);

  @override
  Future<HttpClientRequest> put(String host, int port, String path) {
    return _openUrl(_RequestMethod.put.value,
        Uri(scheme: 'http', host: host, port: port, path: path));
  }

  @override
  Future<HttpClientRequest> putUrl(Uri url) =>
      _openUrl(_RequestMethod.put.value, url);
}

class _GCHttpRequest implements HttpClientRequest {
  final HttpClientRequest _request;
  final String? _uniqueKey;
  final Uri _url;
  final _ConnectionReuseTracker _connectionReuseTracker;
  int _requestBodyBytes = 0;
  bool? _connectionReusedCache;

  _GCHttpRequest(
      this._request, this._uniqueKey, this._url, this._connectionReuseTracker);

  @override
  Future<HttpClientResponse> get done {
    final innerFuture = _request.done;
    return innerFuture.then((value) {
      final requestHeaders = _collectHeaders(_request.headers);
      return _FTHttpResponse(
        value,
        _uniqueKey,
        _url.toString(),
        method,
        requestHeaders,
        _requestSize(requestHeaders),
        _connectionReused(),
      );
    }, onError: (e, st) {
      _onStreamError(e, st);
      throw e;
    });
  }

  @override
  Future<HttpClientResponse> close() {
    return _request.close().then((value) {
      final requestHeaders = _collectHeaders(_request.headers);
      return _FTHttpResponse(
        value,
        _uniqueKey,
        _url.toString(),
        method,
        requestHeaders,
        _requestSize(requestHeaders),
        _connectionReused(),
      );
    }, onError: (e, st) async {
      _onStreamError(e, st);
      throw e;
    });
  }

  void _onStreamError(Object e, StackTrace? st) {
    try {
      if (_uniqueKey != null) {
        final requestHeaders = _collectHeaders(_request.headers);
        FTRUMManager().stopResource(_uniqueKey!);
        FTRUMManager().addResource(
            key: _uniqueKey!,
            url: _url.toString(),
            httpMethod: method,
            requestHeader: requestHeaders,
            responseBody: e.toString(),
            resourceType: _resourceTypeForHttp(method, null),
            metrics: FTRUMResourceMetrics(
              requestSize: _requestSize(requestHeaders),
              reusedConnection: _connectionReused(),
            ));
      }
    } catch (e) {}
  }

  int _requestSize(Map<String, String> requestHeaders) {
    final bodySize = _requestBodyBytes > 0
        ? _requestBodyBytes
        : _request.contentLength > 0
            ? _request.contentLength
            : 0;
    return _headersByteSize(requestHeaders) + bodySize;
  }

  bool _connectionReused() {
    return _connectionReusedCache ??=
        _connectionReuseTracker(_url, _request.persistentConnection);
  }

  void _addRequestBodyBytes(int bytes) {
    if (bytes > 0) {
      _requestBodyBytes += bytes;
    }
  }

  @override
  bool get bufferOutput => _request.bufferOutput;

  @override
  set bufferOutput(bool value) => _request.bufferOutput = value;

  @override
  int get contentLength => _request.contentLength;

  @override
  set contentLength(int value) => _request.contentLength = value;

  @override
  Encoding get encoding => _request.encoding;

  @override
  set encoding(Encoding value) => _request.encoding = value;

  @override
  bool get followRedirects => _request.followRedirects;

  @override
  set followRedirects(bool value) => _request.followRedirects = value;

  @override
  int get maxRedirects => _request.maxRedirects;

  @override
  set maxRedirects(int value) => _request.maxRedirects = value;

  @override
  bool get persistentConnection => _request.persistentConnection;

  @override
  set persistentConnection(bool value) => _request.persistentConnection = value;

  @override
  void abort([Object? exception, StackTrace? stackTrace]) =>
      _request.abort(exception, stackTrace);

  @override
  void add(List<int> data) {
    _addRequestBodyBytes(data.length);
    _request.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _request.addError(error, stackTrace);

  @override
  Future addStream(Stream<List<int>> stream) {
    return _request.addStream(stream.map((event) {
      _addRequestBodyBytes(event.length);
      return event;
    }));
  }

  @override
  HttpConnectionInfo? get connectionInfo => _request.connectionInfo;

  @override
  List<Cookie> get cookies => _request.cookies;

  @override
  Future flush() => _request.flush();

  @override
  HttpHeaders get headers => _request.headers;

  @override
  String get method => _request.method;

  @override
  Uri get uri => _request.uri;

  @override
  void write(Object? object) {
    _addRequestBodyBytes(encoding.encode(object.toString()).length);
    _request.write(object);
  }

  @override
  void writeAll(Iterable objects, [String separator = '']) {
    _addRequestBodyBytes(encoding.encode(objects.join(separator)).length);
    _request.writeAll(objects, separator);
  }

  @override
  void writeCharCode(int charCode) {
    _addRequestBodyBytes(encoding.encode(String.fromCharCode(charCode)).length);
    _request.writeCharCode(charCode);
  }

  @override
  void writeln([Object? object = '']) {
    _addRequestBodyBytes(encoding.encode('${object.toString()}\n').length);
    _request.writeln(object);
  }
}

class _FTHttpResponse extends Stream<List<int>> implements HttpClientResponse {
  final HttpClientResponse response;
  final String? uniqueKey;
  Object? _lastError;
  String url;
  String method;
  Map<String, String> requestHeaders;
  int requestSize;
  bool connectionReused;

  _FTHttpResponse(this.response, this.uniqueKey, this.url, this.method,
      this.requestHeaders, this.requestSize, this.connectionReused);

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    List<int> bodyBytes = [];
    void Function(List<int> event)? func = (event) {
      if (onData != null) {
        // read bytes limit
        if (bodyBytes.length <= responseReadLimit) {
          bodyBytes.addAll(event);
        }
        onData.call(event);
      }
    };
    return response.listen(
      func,
      cancelOnError: cancelOnError,
      onError: (e, st) {
        _onError(e, st);
        if (onError == null) {
          return;
        }
        if (onError is void Function(Object, StackTrace)) {
          onError(e, st);
        } else {
          assert(onError is void Function(Object));
          onError(e);
        }
      },
      onDone: () {
        try {
          String body = utf8.decode(bodyBytes, allowMalformed: true);
          _onFinish(body, null, null);
          bodyBytes.clear();
        } on FormatException catch (_) {
          // baseLog.LogUtils().e(e.message);
          _onFinish("", null, null);
        }
        if (onDone != null) {
          onDone();
        }
      },
    );
  }

  void _onError(Object error, StackTrace? stackTrace) {
    _lastError = error;
  }

  void _onFinish(String? body, Object? error, StackTrace? stackTrace) {
    try {
      if (uniqueKey != null) {
        final statusCode = response.statusCode;
        final responseHeaders = _collectHeaders(response.headers);
        final resourceType = _resourceTypeForHttp(method, responseHeaders);
        final metrics = FTRUMResourceMetrics(
          requestSize: requestSize,
          resourceHttpProtocol: _resourceHttpProtocol(url),
          reusedConnection: connectionReused && response.persistentConnection,
        );
        FTRUMManager().stopResource(uniqueKey!);
        if (_lastError != null) {
          FTRUMManager().addResource(
              key: uniqueKey!,
              url: url,
              requestHeader: requestHeaders,
              httpMethod: method,
              responseHeader: responseHeaders,
              resourceStatus: statusCode,
              resourceSize: contentLength,
              responseBody: _lastError.toString(),
              resourceType: resourceType,
              metrics: metrics);
        } else {
          FTRUMManager().addResource(
            key: uniqueKey!,
            url: url,
            requestHeader: requestHeaders,
            httpMethod: method,
            responseHeader: responseHeaders,
            resourceStatus: statusCode,
            resourceSize: contentLength,
            responseBody: body ?? "",
            resourceType: resourceType,
            metrics: metrics,
          );
        }
      }
    } catch (e) {}
  }

  @override
  X509Certificate? get certificate => response.certificate;

  @override
  HttpClientResponseCompressionState get compressionState =>
      response.compressionState;

  @override
  HttpConnectionInfo? get connectionInfo => response.connectionInfo;

  @override
  int get contentLength => response.contentLength;

  @override
  List<Cookie> get cookies => response.cookies;

  @override
  Future<Socket> detachSocket() {
    return response.detachSocket();
  }

  @override
  HttpHeaders get headers => response.headers;

  @override
  bool get isRedirect => response.isRedirect;

  @override
  bool get persistentConnection => response.persistentConnection;

  @override
  String get reasonPhrase => response.reasonPhrase;

  @override
  Future<HttpClientResponse> redirect(
      [String? method, Uri? url, bool? followLoops]) {
    return response.redirect(method, url, followLoops);
  }

  @override
  List<RedirectInfo> get redirects => response.redirects;

  @override
  int get statusCode => response.statusCode;
}
