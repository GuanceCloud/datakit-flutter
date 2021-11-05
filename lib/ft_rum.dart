import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import 'const.dart';

class FTRUMManager {
  static final FTRUMManager _singleton = FTRUMManager._internal();

  factory FTRUMManager() {
    return _singleton;
  }

  FTRUMManager._internal();

  Future<void> setConfig(
      {required String rumAppId,
      double? sampleRate,
      bool? enableUserAction,
      MonitorType? monitorType,
      Map? globalContext}) async {
    Map<String, dynamic> map = {};
    map["rumAppId"] = rumAppId;
    map["sampleRate"] = sampleRate;
    map["enableUserAction"] = enableUserAction;
    map["monitorType"] = monitorType?.value;
    map["globalContext"] = globalContext?.entries;
    await channel.invokeMethod(methodRumConfig, map);
  }

  Future<void> startAction(String actionName, String actionType,
      {bool needWait = false}) async {
    Map<String, dynamic> map = {};
    map["actionName"] = actionName;
    map["actionType"] = actionType;
    await channel.invokeMethod(methodRumAddAction, map);
  }

  Future<void> starView(String viewName, String viewReferer) async {
    Map<String, dynamic> map = {};
    map["viewName"] = viewName;
    map["viewReferer"] = viewReferer;
    await channel.invokeMethod(methodRumStartView, map);
  }

  Future<void> stopView() async {
    await channel.invokeMethod(methodRumStopView);
  }

  ///其它异常捕获与日志收集
  Future<void> addError(Object obj, StackTrace stack, AppState state) async {
    if(obj is FlutterErrorDetails) {
      return await addFlutterError(obj, state);
    }
    Map<String, dynamic> map = {};
    map["crash"] = stack.toString();
    map["message"] = obj.toString();
    map["appState"] = state.index;
    await channel.invokeMethod(methodRumAddError, map);
  }
  ///Flutter框架异常捕获
  Future<void> addFlutterError(FlutterErrorDetails error, AppState state) async {
    Map<String, dynamic> map = {};
    map["stack"] = error.stack.toString();
    map["message"] = error.exceptionAsString();
    map["appState"] = state.index;
    await channel.invokeMethod(methodRumAddError, map);
  }

  Future<void> startResource(String key,String url) async {
    Map<String, dynamic> map = {};
    map["key"] = key;
    map["url"] = url;
    await channel.invokeMethod(methodRumStartResource,map);
  }
  Future<void> uploadResource(String key,Response response) async {
    Map<String, dynamic> map = {};
    map["requestHeader"] = response.request!.headers;
    await channel.invokeMethod(methodRumUploadResource);
  }
  Future<void> stopResource(String key) async {
    await channel.invokeMethod(methodRumStopView);
  }
}

enum MonitorType { all, battery, memory, cpu }

enum AppState { unknown, startup, run }

extension MonitorTypeExt on MonitorType {
  int get value {
    switch (this) {
      case MonitorType.all:
        return 0xFFFFFFFF;
      case MonitorType.battery:
        return 1 << 1;
      case MonitorType.memory:
        return 1 << 2;
      case MonitorType.cpu:
        return 1 << 3;
    }
  }
}
