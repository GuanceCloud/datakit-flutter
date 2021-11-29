import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'const.dart';

class FTRUMManager {
  static final FTRUMManager _singleton = FTRUMManager._internal();
  AppState appState = AppState.run;

  factory FTRUMManager() {
    return _singleton;
  }

  FTRUMManager._internal();

  Future<void> setConfig(
      {String? androidAppId,
      String? iOSAppId,
      double? sampleRate,
      bool? enableUserAction,
      MonitorType? monitorType,
      Map? globalContext}) async {
    Map<String, dynamic> map = {};
    if (Platform.isAndroid) {
      map["rumAppId"] = androidAppId;
    } else if (Platform.isIOS) {
      map["rumAppId"] = iOSAppId;
    }
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
  void addError(Object obj, StackTrace stack) {
    if (obj is FlutterErrorDetails) {
      return addFlutterError(obj);
    }
    addCustomError(stack.toString(), obj.toString());
  }

  ///Flutter框架异常捕获
  void addFlutterError(FlutterErrorDetails error) {
    addCustomError(error.stack.toString(), error.exceptionAsString());
  }

  ///添加自定义错误
  Future<void> addCustomError(String stack, String message) async {
    Map<String, dynamic> map = {};
    map["stack"] = stack;
    map["message"] = message;
    map["appState"] = appState.index;
    await channel.invokeMethod(methodRumAddError, map);
  }

  ///开始资源请求
  Future<void> startResource(String key) async {
    Map<String, dynamic> map = {};
    map["key"] = key;
    await channel.invokeMethod(methodRumStartResource, map);
  }

  ///结束资源请求
  Future<void> stopResource(String key) async {
    Map<String, dynamic> map = {};
    map["key"] = key;
    await channel.invokeMethod(methodRumStopResource, map);
  }

  /// 发送资源数据指标
  Future<void> addResource(
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
    await channel.invokeMethod(methodRumAddResource, map);
  }
}


/// app 运行状态
enum AppState { unknown, startup, run }


/// 监控类型
enum MonitorType { all, battery, memory, cpu }

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
