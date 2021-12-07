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

  /// 设置 RUM 追踪条件
  /// [androidAppId] appId，监测中申请
  /// [iOSAppId] appId，监测中申请
  /// [sampleRate] 采样率
  /// [enableNativeUserAction] 是否开始 Native Action 追踪，Button 点击事件，纯 flutter 应用建议关闭
  /// [enableNativeUserView] 是否开始 Native View 自动追踪，纯 Flutter 应用建议关闭
  /// [monitorType] 监控补充类型
  /// [globalContext] 自定义全局参数
  Future<void> setConfig(
      {String? androidAppId,
      String? iOSAppId,
      double? sampleRate,
      bool? enableNativeUserAction,
      bool? enableNativeUserView,
      MonitorType? monitorType,
      Map? globalContext}) async {
    Map<String, dynamic> map = {};
    if (Platform.isAndroid) {
      map["rumAppId"] = androidAppId;
    } else if (Platform.isIOS) {
      map["rumAppId"] = iOSAppId;
    }
    map["sampleRate"] = sampleRate;
    map["enableNativeUserAction"] = enableNativeUserAction;
    map["enableNativeUserView"] = enableNativeUserView;
    map["monitorType"] = monitorType?.value;
    map["globalContext"] = globalContext?.entries;
    await channel.invokeMethod(methodRumConfig, map);
  }

  /// 执行 action
  /// [actionName] action 名称
  /// [actionType] action 类型
  Future<void> startAction(String actionName, String actionType) async {
    Map<String, dynamic> map = {};
    map["actionName"] = actionName;
    map["actionType"] = actionType;
    await channel.invokeMethod(methodRumAddAction, map);
  }

  /// view 开始
  /// [viewName] 界面名称
  /// [viewReferer] 前一个界面名称
  Future<void> starView(String viewName, String viewReferer) async {
    Map<String, dynamic> map = {};
    map["viewName"] = viewName;
    map["viewReferer"] = viewReferer;
    await channel.invokeMethod(methodRumStartView, map);
  }

  /// view 结束
  Future<void> stopView() async {
    await channel.invokeMethod(methodRumStopView);
  }

  ///其它异常捕获与日志收集
  ///[obj] 错误内容
  ///[stack] 堆栈日志
  void addError(Object obj, StackTrace stack) {
    if (obj is FlutterErrorDetails) {
      return addFlutterError(obj);
    }
    addCustomError(stack.toString(), obj.toString());
  }

  /// Flutter 框架异常捕获
  ///[error] 错误日志
  void addFlutterError(FlutterErrorDetails error) {
    addCustomError(error.stack.toString(), error.exceptionAsString());
  }

  ///添加自定义错误
  ///[stack] 堆栈日志
  /// [message]错误信息
  ///[appState] 应用状态
  Future<void> addCustomError(String stack, String message) async {
    Map<String, dynamic> map = {};
    map["stack"] = stack;
    map["message"] = message;
    map["appState"] = appState.index;
    await channel.invokeMethod(methodRumAddError, map);
  }

  ///开始资源请求
  ///[key] 唯一 id
  Future<void> startResource(String key) async {
    Map<String, dynamic> map = {};
    map["key"] = key;
    await channel.invokeMethod(methodRumStartResource, map);
  }

  ///结束资源请求
  ///[key] 唯一 id
  Future<void> stopResource(String key) async {
    Map<String, dynamic> map = {};
    map["key"] = key;
    await channel.invokeMethod(methodRumStopResource, map);
  }

  /// 发送资源数据指标
  /// [key] 唯一 id
  /// [url] 请求地址
  /// [httpMethod] 请求方法
  /// [requestHeader] 请求头参数
  /// [responseHeader] 返回头参数
  /// [responseBody] 返回内容
  /// [resourceStatus] 返回状态码
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
enum AppState {
  unknown,//未知
  startup,//启动
  run //运行
}


/// 监控类型
enum MonitorType {
  all,
  battery,
  memory,
  cpu
}

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
