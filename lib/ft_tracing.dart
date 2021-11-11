import 'dart:async';
import 'dart:convert';

import 'const.dart';

class FTTracer {
  static final FTTracer _singleton = FTTracer._internal();

  factory FTTracer() {
    return _singleton;
  }

  FTTracer._internal();

  Future<void> setConfig({double? sampleRate,
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

  Future<void> addTrace({
    required String key,
    required Uri url,
    required String httpMethod,
    required Map<String, dynamic>requestHeader,
    int? statusCode,
    Map<String, dynamic>? responseHeader,
    String? errorMessage,
  }) async {
    String operationName = httpMethod.toUpperCase() + ' ' + url.path;
    Map requestContent = {
      "method": httpMethod,
      "headers": requestHeader,
      "url": url.toString(),
    };
    Map responseContent = {};
    Map headers = responseHeader != null ? responseHeader : {};
    int code = statusCode != null ? statusCode : 0;
    bool isError = responseHeader == null || code >= 400;
    if (isError) {
      String error = errorMessage != null ? errorMessage : "";
      responseContent = {
        "error": error,
        "headers": headers
      };
    } else {
      responseContent = {
        "code": code.toString(),
        "headers": headers
      };
    }
    Map<String, dynamic> content = {
      "requestContent": requestContent,
      "responseContent": responseContent
    };
    _addTrace(key, content, operationName, isError);
  }

  Future<void> _addTrace(String key,
      Map<String, dynamic> json, String operationName, bool isError) async {
    var map = Map<String, dynamic>();
    map["key"] = key;
    map["content"] = jsonEncode(json);
    map["operationName"] = operationName;
    map["isError"] = isError;
    await channel.invokeMethod(methodTrace, map);
  }

  Future<Map<String, String>> getTraceHeader(String key, String url) async {
    var map = Map<String, dynamic>();
    map["key"] = key;
    return await channel.invokeMethod(methodGetTraceGetHeader, key);
  }
}

enum TraceType { ddTrace, zipkin, jaeger }
