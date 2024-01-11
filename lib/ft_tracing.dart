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

  ///配置 trace
  ///[sampleRate]采样率
  ///[traceType] 链路类型
  ///[enableLinkRUMData] 是否与 RUM 数据关联
  ///[enableNativeAutoTrace] 是否开启原生网络网络自动追踪 iOS NSURLSession ,Android OKhttp
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

  /// 获取 trace http 请求头数据
  /// [key] 唯一 id
  /// [url] 请求地址
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

/// 使用 trace trace 类型
enum TraceType {
  ddTrace,
  zipkinMultiHeader,
  zipkinSingleHeader,
  traceparent,
  skywalking,
  jaeger
}
