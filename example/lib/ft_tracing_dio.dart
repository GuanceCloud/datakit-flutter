import 'package:dio/dio.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
import 'package:uuid/uuid.dart';

///使用 dio 库来进行网络请求

class FTInterceptor extends Interceptor {
  static const String _dioKey = "ft-dio-key";

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    String key = Uuid().v4();
    final traceHeaders =
    await FTTracer().getTraceHeader(key, options.uri.toString());
    traceHeaders[_dioKey] = key;
    options.headers.addAll(traceHeaders);
    FTRUMManager().startResource(key);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    RequestOptions options = response.requestOptions;
    var key = options.headers[_dioKey];
    FTTracer().addTrace(
        key: key,
        httpMethod: options.method,
        requestHeader: options.headers,
        responseHeader: response.headers.map,
        statusCode: response.statusCode,
        errorMessage: "");

    FTRUMManager().addResource(
      key: key,
      url: options.uri.toString(),
      requestHeader: options.headers,
      httpMethod: options.method,
      responseHeader: response.headers.map,
      resourceStatus: response.statusCode,
      responseBody: response.data.toString(),
    );

    FTRUMManager().stopResource(key);

    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    RequestOptions options = err.requestOptions;
    var key = options.headers[_dioKey];
    FTTracer().addTrace(
        key: key,
        httpMethod: options.method,
        requestHeader: options.headers,
        responseHeader: err.response?.headers.map,
        statusCode: err.response?.statusCode,
        errorMessage: err.message);

    FTRUMManager().addResource(
      key: key,
      url: options.uri.toString(),
      requestHeader: options.headers,
      httpMethod: options.method,
      responseHeader: err.response?.headers.map,
      resourceStatus: err.response?.statusCode,
      responseBody: err.response?.data?.toString(),
    );

    FTRUMManager().stopResource(key);
    handler.next(err);
  }
}
