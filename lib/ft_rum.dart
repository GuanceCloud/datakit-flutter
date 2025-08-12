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

  /// Set RUM tracking conditions
  /// [androidAppId] appId, apply in monitoring
  /// [iOSAppId] appId, apply in monitoring
  /// [sampleRate] sampling rate
  /// [enableNativeUserAction] whether to perform Native Action tracking, Button click events, pure flutter apps recommend to turn off
  /// [enableNativeUserView] whether to perform Native View auto-tracking, pure Flutter apps recommend to turn off
  /// [enableNativeUserResource] whether to perform Native Resource auto-tracking, pure Flutter apps recommend to turn off
  /// [errorMonitorType] monitoring supplement type
  /// [deviceMonitorType] monitoring supplement type
  /// [globalContext] custom global parameters
  Future<void> setConfig(
      {String? androidAppId,
      String? iOSAppId,
      double? sampleRate,
      bool enableUserResource = false,
      bool? enableNativeUserAction,
      bool? enableNativeUserView,
      bool? enableNativeUserResource,
      bool? enableNativeAppUIBlock,
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
    map["errorMonitorType"] = errorMonitorType;
    map["deviceMetricsMonitorType"] = deviceMetricsMonitorType;
    map["detectFrequency"] = detectFrequency?.index;
    map["globalContext"] = globalContext;
    internalConfig.traceResource = enableUserResource;
    await channel.invokeMethod(methodRumConfig, map);
  }

  /// Execute action
  /// [actionName] action name
  /// [actionType] action type
  /// [property] additional property parameters (optional)
  Future<void> startAction(String actionName, String actionType,
      {Map<String, String>? property}) async {
    Map<String, dynamic> map = {};
    map["actionName"] = actionName;
    map["actionType"] = actionType;
    map["property"] = property;
    await channel.invokeMethod(methodRumAddAction, map);
  }

  /// view start
  /// [viewName] interface name
  /// [viewReferer] previous interface name
  /// [property] additional property parameters (optional)
  Future<void> starView(String viewName,
      {Map<String, String>? property}) async {
    Map<String, dynamic> map = {};
    map["viewName"] = viewName;
    map["property"] = property;
    await channel.invokeMethod(methodRumStartView, map);
  }

  /// view creation, this method needs to be called before [starView], currently not available in flutter route
  /// [viewName] interface name
  /// [duration]
  Future<void> createView(String viewName, int duration) async {
    Map<String, dynamic> map = {};
    map["viewName"] = viewName;
    map["duration"] = duration;
    await channel.invokeMethod(methodRumCreateView, map);
  }

  /// view end
  /// [property] additional property parameters (optional)
  Future<void> stopView({Map<String, String>? property}) async {
    Map<String, dynamic> map = {};
    map["property"] = property;
    await channel.invokeMethod(methodRumStopView, map);
  }

  /// Other exception capture and log collection
  /// [obj] error content
  /// [stack] stack log
  void addError(Object obj, StackTrace stack) {
    if (obj is FlutterErrorDetails) {
      return addFlutterError(obj);
    }
    addCustomError(stack.toString(), obj.toString());
  }

  /// Flutter framework exception capture
  /// [error] error log
  void addFlutterError(FlutterErrorDetails error) {
    addCustomError(error.stack.toString(), error.exceptionAsString());
  }

  /// Add custom error
  /// [stack] stack log
  /// [message] error message
  /// [appState] application state
  /// [errorType] custom errorType
  /// [property] additional property parameters (optional)
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

  /// Start resource request
  /// [key] unique id
  /// [property] additional property parameters (optional)
  Future<void> startResource(String key,
      {Map<String, String>? property}) async {
    Map<String, dynamic> map = {};
    map["key"] = key;
    map["property"] = property;
    await channel.invokeMethod(methodRumStartResource, map);
  }

  /// End resource request
  /// [key] unique id
  /// [property] additional property parameters (optional)
  Future<void> stopResource(String key, {Map<String, String>? property}) async {
    Map<String, dynamic> map = {};
    map["key"] = key;
    map["property"] = property;
    await channel.invokeMethod(methodRumStopResource, map);
  }

  /// Send resource data metrics
  /// [key] unique id
  /// [url] request address
  /// [httpMethod] request method
  /// [requestHeader] request header parameters
  /// [responseHeader] response header parameters
  /// [responseBody] response content
  /// [resourceStatus] response status code
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

/// App running state
enum AppState {
  unknown, // unknown
  startup, // startup
  run // running
}

/// Monitoring type
enum ErrorMonitorType { all, battery, memory, cpu }

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

enum DeviceMetricsMonitorType { all, battery, memory, cpu, fps }

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

enum DetectFrequency { normal, frequent, rare }
