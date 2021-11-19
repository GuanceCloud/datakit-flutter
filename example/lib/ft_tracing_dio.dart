import 'package:dio/dio.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
import 'package:uuid/uuid.dart';
///使用 dio 库来进行网络请求

class FTInterceptor extends Interceptor {
  var traceMap = {};

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    String key = Uuid().v4();
    final traceHeaders =
    await FTTracer().getTraceHeader(key, options.uri);
    options.headers.addAll(traceHeaders);
    traceMap[options] = key;
    FTRUMManager().startResource(key);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    RequestOptions options = response.requestOptions;
    if (traceMap.containsKey(options)) {
      String key = traceMap[options];
      FTTracer().addTrace(
          key: key,
          httpMethod: options.method,
          url: options.uri,
          requestHeader: options.headers,
          responseHeader: response.headers.map,
          statusCode: response.statusCode,
          errorMessage: "");
      FTRUMManager().stopResource(
        key: key,
        url:options.uri,
        requestHeader: options.headers,
        httpMethod: options.method,
        responseHeader:response.headers.map,
        resourceStatus: response.statusCode,
        responseBody: response.data.toString(),
      );

      traceMap.remove(key);
    }

    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    RequestOptions options = err.requestOptions;
    if (traceMap.containsKey(options)) {
      String key = traceMap[options];
      FTTracer().addTrace(
          key: key,
          httpMethod: options.method,
          url: options.uri,
          requestHeader: options.headers,
          responseHeader: err.response?.headers.map,
          statusCode: err.response?.statusCode,
          errorMessage: err.message);
      FTRUMManager().stopResource(
        key: key,
        url:options.uri,
        requestHeader: options.headers,
        httpMethod: options.method,
        responseHeader:err.response?.headers.map,
        resourceStatus: err.response?.statusCode,
        responseBody: err.response?.data?.toString(),
      );
      traceMap.remove(options);
    }
    handler.next(err);
  }
}