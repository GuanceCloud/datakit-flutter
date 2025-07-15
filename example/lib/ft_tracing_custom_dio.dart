import 'package:dio/dio.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
import 'package:uuid/uuid.dart';

/// Use dio library for network requests

class FTInterceptor extends Interceptor {
  static const String _dioKey = "ft-dio-key";

  // Adding a function that can be passed externally to decide whether to skip a URL
  final bool Function(String url)? isInTakeUrl;

  FTInterceptor({this.isInTakeUrl});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip request if the external handler decides so
    if (isInTakeUrl != null && !isInTakeUrl!(options.uri.toString())) {
      handler.next(options);
      return;
    }

    String key = Uuid().v4();
    final traceHeaders =
    await FTTracer().getTraceHeader(options.uri.toString(), key: key);
    traceHeaders[_dioKey] = key;
    options.headers.addAll(traceHeaders);
    FTRUMManager().startResource(key);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Skip response processing if the external handler decides so
    if (isInTakeUrl != null && !isInTakeUrl!(response.requestOptions.uri.toString())) {
      handler.next(response);
      return;
    }

    RequestOptions options = response.requestOptions;
    var key = options.headers[_dioKey];
    FTRUMManager().stopResource(key);
    FTRUMManager().addResource(
      key: key,
      url: options.uri.toString(),
      requestHeader: options.headers,
      httpMethod: options.method,
      responseHeader: response.headers.map,
      resourceStatus: response.statusCode,
      responseBody: response.data.toString(),
    );

    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // Skip error processing if the external handler decides so
    if (isInTakeUrl != null && !isInTakeUrl!(err.requestOptions.uri.toString())) {
      handler.next(err);
      return;
    }

    RequestOptions options = err.requestOptions;
    var key = options.headers[_dioKey];
    FTRUMManager().stopResource(key);
    FTRUMManager().addResource(
      key: key,
      url: options.uri.toString(),
      requestHeader: options.headers,
      httpMethod: options.method,
      responseHeader: err.response?.headers.map,
      resourceStatus: err.response?.statusCode,
      responseBody: err.response?.data?.toString(),
    );

    handler.next(err);
  }
}
