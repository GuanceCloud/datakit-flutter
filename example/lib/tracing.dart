import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
///使用 http 库来进行网络请求
class FTTracingHttpClient extends http.BaseClient {
  final http.Client _innerClient;

  FTTracingHttpClient({
    http.Client? innerClient,
  }) : _innerClient = innerClient ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is! http.Request) return _innerClient.send(request);
    String key = "";
    final traceHeaders =
    await FTTracer().getTraceHeader(key, request.url.toString());
    request.headers.addAll(traceHeaders);
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
          url: request.url,
          httpMethod: request.method,
          requestHeader: request.headers,
          responseHeader: response?.headers,
          statusCode: response?.statusCode,
          errorMessage: errorMessage);
    }
  }
}
class Tracing extends StatefulWidget {
  const Tracing({required Key key}) : super(key: key);

  @override
  _TracingState createState() => _TracingState();
}

class _TracingState extends State<Tracing> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
