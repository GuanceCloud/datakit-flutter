library ft_mobile_agent_flutter;

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:ft_mobile_agent_flutter/internal/ft_sdk_config.dart'
    as internalConfig;

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
  /// [enableNativeUserAction] 是否进行 Native Action 追踪，Button 点击事件，纯 flutter 应用建议关闭
  /// [enableNativeUserView] 是否进行 Native View 自动追踪，纯 Flutter 应用建议关闭
  /// [enableNativeUserResource] 是否进行 Native Resource 自动追踪，纯 Flutter 应用建议关闭
  /// [enableNativeAppUIBlock] 是否进行 Native Longtask 自动追踪
  /// [uiBlockDurationMS] 是否对 LongTask uiBlockDurationMS 的时间范围进行设置
  /// [enableTrackNativeAppANR]是否开启 Native ANR 监测
  /// [enableTrackNativeCrash] 是否开启 Android Java Crash 和 C/C++ 崩溃的监测
  /// [errorMonitorType] 监控补充类型
  /// [deviceMonitorType] 监控补充类型
  /// [globalContext] 自定义全局参数
  Future<void> setConfig(
      {String? androidAppId,
      String? iOSAppId,
      double? sampleRate,
      bool enableUserResource = false,
      bool? enableNativeUserAction,
      bool? enableNativeUserView,
      bool? enableNativeUserResource,
      bool? enableNativeAppUIBlock,
      int? uiBlockDurationMS,
      bool? enableTrackNativeAppANR,
      bool? enableTrackNativeCrash,
      int? errorMonitorType,
      int? deviceMetricsMonitorType,
      DetectFrequency? detectFrequency,
      Map<String, String>? globalContext}) async {
    Map<String, dynamic> map = {};
    if (Platform.isAndroid) {
      map["rumAppId"] = androidAppId;
    } else if (Platform.isIOS) {
      map["rumAppId"] = iOSAppId;
    }
    map["sampleRate"] = sampleRate;
    map["enableUserAction"] = enableNativeUserAction;
    map["enableUserView"] = enableNativeUserView;
    map["enableUserResource"] = enableNativeUserResource;
    map["enableAppUIBlock"] = enableNativeAppUIBlock;
    map["uiBlockDurationMS"] = uiBlockDurationMS;
    map["enableTrackNativeAppANR"] = enableTrackNativeAppANR;
    map["enableTrackNativeCrash"] = enableTrackNativeCrash;
    map["errorMonitorType"] = errorMonitorType;
    map["deviceMetricsMonitorType"] = deviceMetricsMonitorType;
    map["detectFrequency"] = detectFrequency?.index;
    map["globalContext"] = globalContext;
    internalConfig.traceResource = enableUserResource;
    await channel.invokeMethod(methodRumConfig, map);
  }

  /// 添加 action
  /// [actionName] action 名称
  /// [actionType] action 类型
  /// [property] 附加属性参数(可选)
  Future<void> startAction(String actionName, String actionType,
      {Map<String, String>? property}) async {
    Map<String, dynamic> map = {};
    map["actionName"] = actionName;
    map["actionType"] = actionType;
    map["property"] = property;
    await channel.invokeMethod(methodRumAddAction, map);
  }

  /// view 开始
  /// [viewName] 界面名称
  /// [viewReferer] 前一个界面名称
  /// [property] 附加属性参数(可选)
  Future<void> starView(String viewName,
      {Map<String, String>? property}) async {
    Map<String, dynamic> map = {};
    map["viewName"] = viewName;
    map["property"] = property;
    await channel.invokeMethod(methodRumStartView, map);
  }

  /// view 创建,这个方法需要在 [starView] 之前被调用，目前 flutter route 中未有
  /// [viewName] 界面名称
  /// [duration]
  Future<void> createView(String viewName, int duration) async {
    Map<String, dynamic> map = {};
    map["viewName"] = viewName;
    map["duration"] = duration;
    await channel.invokeMethod(methodRumCreateView, map);
  }

  /// view 结束
  /// [property] 附加属性参数(可选)
  Future<void> stopView({Map<String, String>? property}) async {
    Map<String, dynamic> map = {};
    map["property"] = property;
    await channel.invokeMethod(methodRumStopView, map);
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
  /// [stack] 堆栈日志
  /// [message] 错误信息
  /// [appState] 应用状态
  /// [errorType] 自定义 errorType
  /// [property] 附加属性参数(可选)
  Future<void> addCustomError(String stack, String message,
      {Map<String, String>? property, String? errorType}) async {
    Map<String, dynamic> map = {};
    map["stack"] = stack;
    map["message"] = message;
    map["appState"] = appState.index;
    map["errorType"] = errorType;
    map["property"] = property;
    await channel.invokeMethod(methodRumAddError, map);
  }

  ///开始资源请求
  /// [key] 唯一 id
  /// [property] 附加属性参数(可选)
  Future<void> startResource(String key,
      {Map<String, String>? property}) async {
    Map<String, dynamic> map = {};
    map["key"] = key;
    map["property"] = property;
    await channel.invokeMethod(methodRumStartResource, map);
  }

  ///结束资源请求
  /// [key] 唯一 id
  /// [property] 附加属性参数(可选)
  Future<void> stopResource(String key, {Map<String, String>? property}) async {
    Map<String, dynamic> map = {};
    map["key"] = key;
    map["property"] = property;
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
      required Map<String, dynamic> requestHeader,
      Map<String, dynamic>? responseHeader,
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
  ///未知
  unknown,

  ///启动
  startup,

  ///正在运行
  run
}

/// 设置辅助监控信息，添加附加监控数据到 `RUM` Error 数据中
enum ErrorMonitorType {
  /// 所有数据
  all,

  /// 电池余量
  battery,

  /// 内存用量
  memory,

  /// CPU 占有率
  cpu
}

extension ErrorMonitorTypeExt on ErrorMonitorType {
  int get value {
    switch (this) {
      case ErrorMonitorType.all:
        return 0xffffffff;
      case ErrorMonitorType.battery:
        return 1 << 1;
      case ErrorMonitorType.memory:
        return 1 << 2;
      case ErrorMonitorType.cpu:
        return 1 << 3;
    }
  }
}

/// 在 View 周期中，添加监控数据
enum DeviceMetricsMonitorType {
  /// 所有数据
  all,

  /// 监控当前页的最高输出电流输出情况
  battery,

  /// 监控当前应用使用内存情况
  memory,

  /// 监控 CPU 跳动次数
  cpu,

  /// 监控屏幕帧率
  fps
}

extension DeviceMetricsMonitorTypeExt on DeviceMetricsMonitorType {
  int get value {
    switch (this) {
      case DeviceMetricsMonitorType.all:
        return 0xffffffff;
      case DeviceMetricsMonitorType.battery:
        return 1 << 1;
      case DeviceMetricsMonitorType.memory:
        return 1 << 2;
      case DeviceMetricsMonitorType.cpu:
        return 1 << 3;
      case DeviceMetricsMonitorType.fps:
        return 1 << 4;
    }
  }
}

///
///  检测周期，单位毫秒 MS
///
enum DetectFrequency {
  /// 默认检测频率 500 ms 一次
  normal,

  /// 高频采集，100 ms 一次
  frequent,

  /// 低频率采集 1000 ms 一次
  rare
}
