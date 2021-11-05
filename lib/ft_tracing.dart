import 'dart:convert';
import 'package:http/http.dart' as http;

import 'const.dart';
class FTTracingHttpClient extends http.BaseClient {
  final http.Client _innerClient;

  FTTracingHttpClient({
    http.Client? innerClient,
  }) : _innerClient = innerClient ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is! http.Request) return _innerClient.send(request);
    String key = "";
    final traceHeaders = await FTTracer().getTraceHeader(key, request.url.toString());
    request.headers.addAll(traceHeaders);
    http.StreamedResponse? response;
    try {
      return response = await _innerClient.send(request);
    } finally {
      String  operationName = request.method.toUpperCase()+' '+request.url.path;
      Map requestContent = {
        "method":request.method,
        "headers":request.headers,
        "url":request.url.toString(),
      };
      Map responseContent = {
        "code":response!.statusCode.toString(),
        "headers":response.headers
      };
      Map<String,dynamic> content = {
        "requestContent":requestContent,
        "responseContent":responseContent
      };
      bool isError = response.statusCode<400;
      FTTracer().addTrace(key, content, operationName, isError);
    }
  }

}
class FTTracer {
  static final FTTracer _singleton = FTTracer._internal();
  factory FTTracer() {
    return _singleton;
  }

  FTTracer._internal();

  Future<void> setConfig(
      {double? sampleRate,
      String? serviceName,
      TraceType? traceType,
      bool? enableLinkRUMData}) async {
    var map = Map<String, dynamic>();
    map["sampleRate"] = sampleRate;
    map["serviceName"] = serviceName;
    map["traceType"] = traceType?.index;
    map["enableLinkRUMData"] = enableLinkRUMData;
    await channel.invokeMethod(methodTraceConfig, map);
  }

  Future<void> addTrace(String key,
      Map<String, dynamic> json, String operationName, bool isError) async {
    var map = Map<String, dynamic>();
    map["key"] = key;
    map["content"] = jsonEncode(json);
    map["operationName"] = operationName;
    map["isError"] = isError;
    await channel.invokeMethod(methodTrace, map);
  }

  Future<Map<String, String>> getTraceHeader(String key,String url) async {
    var map = Map<String, dynamic>();
    map["key"] = key;
    return await channel.invokeMethod(methodGetTraceGetHeader,key);
  }
}

enum TraceType { ddTrace, zipkin, jaeger }
