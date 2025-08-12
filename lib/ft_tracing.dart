import 'dart:async';

import 'package:ft_mobile_agent_flutter/internal/ft_sdk_config.dart'
    as internalConfig;

import 'const.dart';

class FTTracer {
  static final FTTracer _singleton = FTTracer._internal();

  factory FTTracer() {
    return _singleton;
  }

  FTTracer._internal();

  ///Configure trace
  ///[sampleRate] sampling rate
  ///[traceType] trace type
  ///[enableLinkRUMData] whether to associate with RUM data
  ///[enableNativeAutoTrace] whether to enable native network auto-tracing iOS NSURLSession, Android OKhttp
  Future<void> setConfig(
      {double? sampleRate,
      TraceType? traceType,
      bool? enableLinkRUMData,
      bool? enableNativeAutoTrace,
      bool enableAutoTrace = false}) async {
    var map = Map<String, dynamic>();
    map["sampleRate"] = sampleRate;
    map["traceType"] = traceType?.index;
    map["enableLinkRUMData"] = enableLinkRUMData;
    map["enableNativeAutoTrace"] = enableNativeAutoTrace;
    internalConfig.traceHeader = enableAutoTrace;
    await channel.invokeMethod(methodTraceConfig, map);
  }

  /// Get trace http request header data
  /// [key] unique id
  /// [url] request address
  ///
  Future<Map<String, String>> getTraceHeader(String url, {String? key}) async {
    var map = Map<String, dynamic>();
    map["key"] = key;
    map["url"] = url;
    Map? header = await channel.invokeMethod(methodGetTraceGetHeader, map);
    if (header != null) {
      return new Map<String, String>.from(header);
    } else {
      return <String, String>{};
    }
  }
}

/// Trace type for using trace
enum TraceType {
  ddTrace,
  zipkinMultiHeader,
  zipkinSingleHeader,
  traceparent,
  skywalking,
  jaeger
}
