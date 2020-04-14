import 'dart:async';

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
  static const METHOD_START_LOCATION = "ftStartLocation";

  static const MethodChannel _channel =
      const MethodChannel('ft_mobile_agent_flutter');

  /// 设置配置一
  static Future<void> configX(Config con) async {
    if (con != null) {
      await config(
        con.serverUrl,
        akId: con.akId,
        akSecret: con.akSecret,
        dataKitUUID: con.dataKitUUID,
        enableLog: con.enableLog,
        needBindUser: con.needBindUser,
        monitorType: con.monitorType,
        useGeoKey: con.useGeoKey,
        geoKey: con.getKey,
      );
    }
  }

  /// 设置配置二
  static Future<void> config(String serverUrl,
      {String akId,
      String akSecret,
      String dataKitUUID,
      bool enableLog,
      bool needBindUser,
      int monitorType,
      bool useGeoKey,
      String geoKey}) async {
    Map<String, dynamic> map = {};
    map["serverUrl"] = serverUrl;

    if (akId != null && akSecret != null) {
      map["akId"] = akId;
      map["akSecret"] = akSecret;
    }

    if (dataKitUUID != null) {
      map["datakitUUID"] = dataKitUUID;
    }

    if (enableLog != null) {
      map["enableLog"] = enableLog;
    }

    if (needBindUser != null) {
      map["needBindUser"] = needBindUser;
    }

    if (monitorType != null) {
      map["monitorType"] = monitorType;
    }

    if (useGeoKey != null) {
      map["useGeoKey"] = useGeoKey;
    }

    if (geoKey != null) {
      map["geoKey"] = geoKey;
    }
    await _channel.invokeMethod(METHOD_CONFIG, map);
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
  static Future<Map<dynamic, dynamic>> trackList(List<TrackBean> list) async {
    Map<String, dynamic> map = {};
    List<Map<String, dynamic>> convertList =
        list.map((e) => e.convertMap()).toList();
    map["list"] = convertList;
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
      String measurement, Map<String, dynamic> fields,
      {Map<String, dynamic> tags}) async {
    Map<String, dynamic> map = {};
    map["measurement"] = measurement;
    map["fields"] = fields;
    if (tags != null) {
      map["tags"] = tags;
    }
    return await _channel.invokeMethod(METHOD_TRACK_BACKGROUND, map);
  }

  ///绑定用户
  static Future<void> bindUser(String name, String id,
      {Map<String, dynamic> extras}) async {
    Map<String, dynamic> map = {};
    map["name"] = name;
    map["id"] = id;
    if (extras != null) {
      map["extras"] = extras;
    }
    return await _channel.invokeMethod(METHOD_BIND_USER, map);
  }

  ///解绑用户
  static Future<void> unbindUser() async {
    return await _channel.invokeMethod(METHOD_UNBIND_USER);
  }

  ///停止 SDK 后台正在执行的操作
  static Future<void> stopSDK() async {
    return await _channel.invokeMethod(METHOD_STOP_SDK);
  }

  ///开启定位，异步回调通知结果
  static Future<Map<dynamic,dynamic>> startLocation({String geoKey}) async {
    Map<String, dynamic> map = {};
    map["geoKey"] = geoKey;
    return await _channel.invokeMethod(METHOD_START_LOCATION,map);
  }
}

class Config {
  String serverUrl;
  String _akId;
  String _akSecret;
  String _dataKitUUID;
  bool _enableLog;
  bool _needBindUser;
  int _monitorType;
  bool _useGeoKey;
  String _getKey;

  Config(this.serverUrl);

  Config setAK(String _akId, String _akSecret) {
    this._akId = _akId;
    this._akSecret = _akSecret;
    return this;
  }

  Config setGeoKey(bool _useGeoKey, String _getKey) {
    this._useGeoKey = _useGeoKey;
    this._getKey = _getKey;
    return this;
  }

  Config setDataKit(String _dataKitUUID) {
    this._dataKitUUID = _dataKitUUID;
    return this;
  }

  Config setEnableLog(bool _enableLog) {
    this._enableLog = _enableLog;
    return this;
  }

  Config setNeedBindUser(bool _needBindUser) {
    this._needBindUser = _needBindUser;
    return this;
  }

  Config setMonitorType(int _monitorType) {
    this._monitorType = _monitorType;
    return this;
  }

  int get monitorType => _monitorType;

  bool get needBindUser => _needBindUser;

  bool get enableLog => _enableLog;

  String get dataKitUUID => _dataKitUUID;

  String get akSecret => _akSecret;

  String get akId => _akId;

  String get getKey => _getKey;

  bool get useGeoKey => _useGeoKey;
}

class MonitorType {
  static const int ALL = 1;
  static const int BATTERY = 1 << 1;
  static const int MEMORY = 1 << 2;
  static const int CPU = 1 << 3;
  static const int GPU = 1 << 4;
  static const int NETWORK = 1 << 5;
  static const int CAMERA = 1 << 6;
  static const int LOCATION = 1 << 7;
}

/// 主动埋点数据类
class TrackBean {
  String measurement;
  Map<String, dynamic> tags;
  Map<String, dynamic> fields;

  TrackBean(this.measurement, this.fields, {this.tags});

  Map<String, dynamic> convertMap() {
    return {"measurement": measurement, "fields": fields, "tags": tags};
  }
}
