import 'dart:async';
import 'dart:ffi';

import 'package:flutter/services.dart';

class FTMobileAgentFlutter {
  static const METHOD_CONFIG = "ftConfig";
  static const METHOD_TRACK = "ftTrack";
  static const METHOD_TRACK_LIST = "ftTrackList";
  static const METHOD_TRACK_FLOW_CHART = "ftTrackFlowChart";
  static const METHOD_TRACK_BACKGROUND = "ftTrackBackground";
  static const METHOD_BIND_USER = "ftBindUser";
  static const METHOD_UNBIND_USER = "ftUnBindUser";
  static const METHOD_STOP_SDK = "ftStopSdk";

  static const MethodChannel _channel =
      const MethodChannel('ft_mobile_agent_flutter');

  ///
  /// 设置配置
  static Future<void> config(String serverUrl,
      [String akId, String akSecret, String datakitUUID,bool enableLog,bool needBindUser]) async {
    Map<String, dynamic> map = {};
    map["serverUrl"] = serverUrl;

    if (akId != null && akSecret != null) {
      map["akId"] = akId;
      map["akSecret"] = akSecret;
    }

    if (datakitUUID != null) {
      map["datakitUUID"] = datakitUUID;
    }

    if (enableLog != null) {
      map["enableLog"] = enableLog;
    }

    if (needBindUser != null) {
      map["needBindUser"] = needBindUser;
    }
    _channel.invokeMethod(METHOD_CONFIG, map);
  }

  ///上报数据
  static Future<Map<dynamic, dynamic>> track(
      String measurement, Map<String, dynamic> fields,
      [Map<String, dynamic> tags]) async {
    Map<String, dynamic> map = {};
    map["measurement"] = measurement;
    map["fields"] = fields;

    if (tags != null) {
      map["tags"] = tags;
    }
    return await _channel.invokeMethod(METHOD_TRACK, map);
  }

  ///上报列表
  static Future<Map<dynamic, dynamic>> trackList(
      List<Map<String, dynamic>> list) async {
    Map<String, dynamic> map = {};
    map["list"] = list;
    return await _channel.invokeMethod(METHOD_TRACK_LIST, map);
  }

  ///上报流程图
  static Future<void> trackFlowChart(
      String production, String traceId, String name, int duration,
      {String parent,
      Map<String, dynamic> tags,
      Map<String, dynamic> fields}) async {
    Map<String, dynamic> map = {};
    map["production"] = production;
    map["traceId"] = traceId;
    map["name"] = name;
    map["duration"] = duration;
    if (parent != null) {
      map["parent"] = parent;
    }
    if (tags != null) {
      map["tags"] = tags;
    }
    if (fields != null) {
      map["fields"] = fields;
    }
    return await _channel.invokeMethod(METHOD_TRACK_FLOW_CHART, map);
  }

  ///主动埋点数据上报（后台运行）
  static Future<void> trackBackground(
      String measurement, Map<String, dynamic> tags,
      {Map<String, dynamic> fields}) async {
    Map<String, dynamic> map = {};
    map["measurement"] = measurement;
    map["tags"] = tags;
    if (fields != null) {
      map["fields"] = fields;
    }
    return await _channel.invokeMethod(METHOD_TRACK_BACKGROUND,map);
  }

  ///绑定用户
  static Future<void> bindUser(
      String name, String id,
      {Map<String, dynamic> extras}) async {
    Map<String, dynamic> map = {};
    map["name"] = name;
    map["id"] = id;
    if (extras != null) {
      map["extras"] = extras;
    }
    return await _channel.invokeMethod(METHOD_BIND_USER,map);
  }

  ///解绑用户
  static Future<void> unbindUser() async {
    return await _channel.invokeMethod(METHOD_UNBIND_USER);
  }

  ///停止 SDK 后台正在执行的操作
  static Future<void> stopSDK() async {
    return await _channel.invokeMethod(METHOD_STOP_SDK);
  }
}
