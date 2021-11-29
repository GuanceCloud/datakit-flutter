import 'dart:async';

import 'const.dart';

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

  Future<void> addTrace({
    required String key,
    required String httpMethod,
    required Map<String, dynamic> requestHeader,
    int? statusCode,
    Map<String, dynamic>? responseHeader,
    String? errorMessage,
  }) async {
    var map = Map<String, dynamic>();
    map["key"] = key;
    map["httpMethod"] = httpMethod;
    map["requestHeader"] = requestHeader;
    map["responseHeader"] = responseHeader;
    map["statusCode"] = statusCode;
    map["errorMessage"] = errorMessage;
    await channel.invokeMethod(methodTrace, map);
  }

  Future<Map<String, String>> getTraceHeader(String key, String url) async {
    var map = Map<String, dynamic>();
    map["key"] = key;
    map["url"] = url;
    Map? header = await channel.invokeMethod(methodGetTraceGetHeader, map);
    if (header != null) {
      return new Map<String, String>.from(header);
    }else{
      return <String,String>{};
    }
  }
}

enum TraceType { ddTrace, zipkin, jaeger }
