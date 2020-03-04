import 'dart:async';

import 'package:flutter/services.dart';

class FTMobileAgentFlutter {
  static const METHOD_CONFIG = "ft_config";
  static const METHOD_TRACK = "ft_track";

  static const MethodChannel _channel =
      const MethodChannel('ft_mobile_agent_flutter');

  ///
  /// 设置配置
  static Future<void> config(String serverUrl,
      [String akId, String akSecret]) async {
    Map<String, dynamic> map = {};
    map["serverUrl"] = serverUrl;

    if (akId != null && akSecret != null) {
      map["akId"] = akId;
      map["akSecret"] = akSecret;
    }
    _channel.invokeMethod(METHOD_CONFIG, map);
  }

  ///上报数据
  static Future<bool> track(String field, Map<String, dynamic> values,
      [Map<String, dynamic> tags]) async {
    Map<String, dynamic> map = {};
    map["field"] = field;
    map["values"] = values;

    if (tags != null) {
      map["tags"] = tags;
    }
    return await _channel.invokeMethod(METHOD_TRACK, map);
  }
}
