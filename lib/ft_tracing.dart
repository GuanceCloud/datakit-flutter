import 'dart:async';

import 'package:ft_mobile_agent_flutter/ft_http_override_config.dart';

import 'const.dart';

class FTTracer {
  static final FTTracer _singleton = FTTracer._internal();

  factory FTTracer() {
    return _singleton;
  }

  FTTracer._internal();

  /// Configure trace
  /// [sampleRate] Sampling rate
  /// [traceType] Trace type
  /// [enableLinkRUMData] Whether to link with RUM data
  /// [enableNativeAutoTrace] Whether to enable native network automatic tracing iOS NSURLSession, Android OKhttp
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
    FTHttpOverrideConfig.global.traceHeader = enableAutoTrace;
    await channel.invokeMethod(methodTraceConfig, map);
  }

  /// Get trace http request header data
  /// [key] Unique id
  /// [url] Request address
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
  ///
  ///  datadog trace
  ///
  ///  x-datadog-trace-id
  ///  x-datadog-parent-id
  ///  x-datadog-sampling-priority
  ///  x-datadog-origin
  ///
  ddTrace,

  ///
  ///  zipkin multi header
  ///
  ///  X-B3-TraceId
  ///  X-B3-SpanId
  ///  X-B3-Sampled
  ///
  zipkinMultiHeader,

  /// zipkin single header,b3
  zipkinSingleHeader,

  ///  w3c, traceparent
  traceparent,

  /// skywalking 8.0+, sw-8
  skywalking,

  /// jaeger, header uber-trace-id
  jaeger
}
