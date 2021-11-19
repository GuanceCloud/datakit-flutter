import 'package:http/http.dart' as http;
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

class HttpHelper {}

///使用 http 库来进行网络请求
class FTTracingHttpClient extends http.BaseClient {
  final http.Client _innerClient;
  var rumMap = {};

  FTTracingHttpClient({
    http.Client? innerClient,
  }) : _innerClient = innerClient ?? http.Client();

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    http.Response response = await super.get(url, headers: headers);
    BaseRequest req = response.request!;
    String? key = rumMap[req];
    if (key != null) {
      FTRUMManager().stopResource(
        key: key,
        url: req.url,
        requestHeader: req.headers,
        httpMethod: req.method,
        responseHeader: response.headers,
        resourceStatus: response.statusCode,
        responseBody: response.body,
      );
      rumMap.remove(req);
    }
    return response;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    String key = Uuid().v4();
    final traceHeaders = await FTTracer().getTraceHeader(key, request.url);
    request.headers.addAll(traceHeaders);
    FTRUMManager().startResource(key);
    http.StreamedResponse? response;
    String errorMessage = "";
    try {
      rumMap[request] = key;
      return response = await _innerClient.send(request);
    } catch (e) {
      errorMessage = e.toString();
      FTRUMManager().stopResource(
        key: key,
        url: request.url,
        requestHeader: request.headers,
        httpMethod: request.method,
      );
      throw e;
    } finally {
      FTTracer().addTrace(
          key: key,
          url: request.url,
          httpMethod: request.method,
          requestHeader: request.headers,
          responseHeader: response?.headers,
          statusCode: response?.statusCode,
          errorMessage: errorMessage);
    }
  }
}
