import 'dart:async';

import 'package:flutter/services.dart';

class FTMobileAgentFlutter {
  static const METHOD_CONFIG = "ft_config";
  static const METHOD_TRACK = "ft_track";

  static const MethodChannel _channel =
  const MethodChannel('ft_mobile_agent_flutter');

  static Future<void> config(String serverUrl,
      [String akId, String akSecret]) async {
    Map<String, dynamic> map = {};
    if (akId == null || akSecret == null) {
      map["serverUrl"] = serverUrl;
    } else {
      map["akId"] = akId;
      map["akSecret"] = akSecret;
    }
    _channel.invokeListMethod(METHOD_CONFIG, map);
  }

  static Future<bool> track(String field,
      [Map<String, dynamic> tags, Map<String, dynamic> values]) async {
    Map<String, dynamic> map = {};
    map["field"] = field;
    map["values"] = values;

    if (tags != null) {
      map["tags"] = tags;
    }
    return await _channel.invokeMethod(METHOD_TRACK, [field, values])
  }
}
