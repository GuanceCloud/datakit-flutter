import 'dart:convert';

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

  Future<void> addTrace(
      Map<String, dynamic> json, String operationName, bool isError) async {
    var map = Map<String, dynamic>();
    map["content"] = jsonEncode(json);
    map["operationName"] = operationName;
    map["isError"] = isError;
    await channel.invokeMethod(methodTrace, map);
  }

  Future<Map<String, String>> getTraceHeader() async {
    return await channel.invokeMethod(methodGetTraceGetHeader);
  }
}

enum TraceType { ddTrace, zipkin, jaeger }
