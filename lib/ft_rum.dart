import 'package:flutter/cupertino.dart';

import 'const.dart';

class FTRUMManager {
  static final FTRUMManager _singleton = FTRUMManager._internal();
  AppState appState = AppState.unknown;
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

  Future<void> startAction(String actionName, String actionType) async {
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
  Future<void> addError(Object obj, StackTrace stack) async {
    if(obj is FlutterErrorDetails) {
      return await addFlutterError(obj);
    }
    Map<String, dynamic> map = {};
    map["stack"] = stack.toString();
    map["message"] = obj.toString();
    map["appState"] = appState.index;
    await channel.invokeMethod(methodRumAddError, map);
  }
  ///Flutter框架异常捕获
  Future<void> addFlutterError(FlutterErrorDetails error) async {
    Map<String, dynamic> map = {};
    map["stack"] = error.stack.toString();
    map["message"] = error.exceptionAsString();
    map["appState"] = appState.index;
    await channel.invokeMethod(methodRumAddError, map);
  }

  Future<void> addCustomError(String stack, String message) async {
    Map<String, dynamic> map = {};
    map["stack"] = stack;
    map["message"] = message;
    map["appState"] = appState.index;
    await channel.invokeMethod(methodRumAddError, map);
  }
  Future<void> startResource(String key) async {
    Map<String, dynamic> map = {};
    map["key"] = key;
    await channel.invokeMethod(methodRumStartResource,map);
  }

  Future<void> stopResource(
      {required String key,
      required String url,
      required String httpMethod,
      required Map requestHeader,
      Map? responseHeader,
      String? responseBody = "",
      int? resourceStatus}) async {
    Map<String, dynamic> map = {};
    map["key"] = key;
    map["url"] = url;
    map["resourceMethod"] = httpMethod;
    map["requestHeader"] = requestHeader;
    map["responseHeader"] = responseHeader;
    map["responseBody"] = responseBody;
    map["resourceStatus"] = resourceStatus;
    await channel.invokeMethod(methodRumStopResource, map);
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
