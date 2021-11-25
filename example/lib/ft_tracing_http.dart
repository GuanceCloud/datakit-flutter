import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

///使用 http 库来进行网络请求
class FTTracingHttpClient extends http.BaseClient {
  final http.Client _innerClient;

  FTTracingHttpClient({
    http.Client? innerClient,
  }) : _innerClient = innerClient ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is! http.Request) return _innerClient.send(request);
    String key = Uuid().v4();
    final traceHeaders =
        await FTTracer().getTraceHeader(key, request.url.toString());
    request.headers.addAll(traceHeaders);
    FTRUMManager().startResource(key);
    http.StreamedResponse? response;
    String errorMessage = "";
    try {
      return response = await _innerClient.send(request);
    } catch (e) {
      errorMessage = e.toString();
      throw e;
    } finally {
      FTTracer().addTrace(
          key: key,
          httpMethod: request.method,
          requestHeader: request.headers,
          responseHeader: response?.headers,
          statusCode: response?.statusCode,
          errorMessage: errorMessage);
      Response? newRes;
      if (response != null) {
        newRes = await Response.fromStream(response);
      }

      FTRUMManager().addResource(
        key: key,
        url: request.url,
        requestHeader: request.headers,
        httpMethod: request.method,
        responseHeader: response?.headers,
        resourceStatus: response?.statusCode,
        responseBody: newRes?.body,
      );
      FTRUMManager().stopResource(key);
    }
  }
}
