import 'dart:async';

import 'package:flutter/services.dart';

class FTMobileAgentFlutter {
  static const METHOD_CONFIG = "ftConfig";
  static const METHOD_TRACK = "ftTrack";
  static const METHOD_TRACK_LIST = "ftTrackList";

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
  static Future<bool> track(String measurement, Map<String, dynamic> fields,
      [Map<String, dynamic> tags]) async {
    Map<String, dynamic> map = {};
    map["measurement"] = measurement;
    map["fields"] = fields;

    if (tags != null) {
      map["tags"] = tags;
    }
    return await _channel.invokeMethod(METHOD_TRACK, map);
  }

  static Future<bool> trackList(List<Map<String, dynamic>> list) async {
    Map<String, dynamic> map = {};
    map["list"] = list;
    return await _channel.invokeMethod(METHOD_TRACK_LIST, map);
  }
}
