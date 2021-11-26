import 'dart:async';

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
    Map<String, dynamic>? responseHeader,
    int? statusCode,
  }) async {
    var map = Map<String, dynamic>();
    map["key"] = key;
    map["url"] = url.toString();
    map["httpMethod"] = httpMethod;
    map["requestHeader"] = requestHeader;
    map["responseHeader"] = responseHeader;
    map["statusCode"] = statusCode;
    await channel.invokeMethod(methodTrace, map);
  }

  Future<Map<String, String>> getTraceHeader(String key, Uri url) async {
    var map = Map<String, dynamic>();
    map["key"] = key;
    map["url"] = url.toString();
    Map? header = await channel.invokeMethod(methodGetTraceGetHeader, map);
    if (header != null){
      return new Map<String, String>.from(header);
    }else{
      return <String,String>{};
    }
  }
}

enum TraceType { ddTrace, zipkin, jaeger }
