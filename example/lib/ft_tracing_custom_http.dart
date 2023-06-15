import 'dart:typed_data';

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
    final traceHeaders = await FTTracer().getTraceHeader(request.url.toString(),key: key );
    request.headers.addAll(traceHeaders);
    FTRUMManager().startResource(key);
    http.StreamedResponse? response;
    String errorMessage = "";
    try {
      response = await _innerClient.send(request);
      Stream<List<int>>  stream = response.stream.asBroadcastStream();
      stream.listen((List<int> event) async{
        Uint8List body = await ByteStream.fromBytes(event).toBytes();
        Response res =  Response.bytes(body, response!.statusCode,headers: response.headers);
        String bodyStr = res.body;
        FTRUMManager().stopResource(key);
        FTRUMManager().addResource(
          key: key,
          url: request.url.toString(),
          requestHeader: request.headers,
          httpMethod: request.method,
          responseHeader: response.headers,
          resourceStatus: response.statusCode,
          responseBody: bodyStr,
        );
      });
      return StreamedResponse(stream, response.statusCode,
          contentLength: response.contentLength,
          headers: response.headers,
          isRedirect: response.isRedirect,
          persistentConnection: response.persistentConnection,
          reasonPhrase: response.reasonPhrase);
    } catch (e) {
      errorMessage = e.toString();
      FTRUMManager().stopResource(key);
      FTRUMManager().addResource(
        key: key,
        url: request.url.toString(),
        requestHeader: request.headers,
        httpMethod: request.method,
      );
      throw e;
    } finally {
      // FTTracer().addTrace(
      //     key: key,
      //     httpMethod: request.method,
      //     requestHeader: request.headers,
      //     responseHeader: response?.headers,
      //     statusCode: response?.statusCode,
      //     errorMessage: errorMessage);
    }
  }


}
