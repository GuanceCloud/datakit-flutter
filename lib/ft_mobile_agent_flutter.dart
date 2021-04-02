import 'dart:async';

import 'package:flutter/services.dart';

class FTMobileAgentFlutter {
  static const METHOD_CONFIG = "ftConfig";
  static const METHOD_BIND_USER = "ftBindUser";
  static const METHOD_UNBIND_USER = "ftUnBindUser";
  static const METHOD_LOGGING = "ftLogging";

  static const MethodChannel _channel =
      const MethodChannel('ft_mobile_agent_flutter');

  /// 配置
  static Future<void> config(String serverUrl) async {
    Map<String, dynamic> map = {};
    map["metricsUrl"] = serverUrl;
    await _channel.invokeMethod(METHOD_CONFIG, map);
  }

  ///输出日志
  static Future<void> logging(String content, FTLogStatus status) async {
    Map<String, dynamic> map = {};
    map["content"] = content;
    map["status"] = status.index;
    await _channel.invokeListMethod(METHOD_LOGGING, map);
  }
}

enum FTLogStatus {
  info,
  warning,
  error,
  critical,
  ok,
}
