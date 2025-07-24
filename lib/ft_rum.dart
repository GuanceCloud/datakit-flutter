library ft_mobile_agent_flutter;

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:ft_mobile_agent_flutter/ft_http_override_config.dart';

import 'const.dart';

class FTRUMManager {
  static final FTRUMManager _singleton = FTRUMManager._internal();
  AppState appState = AppState.run;

  factory FTRUMManager() {
    return _singleton;
  }

  FTRUMManager._internal();

  /// Set RUM tracking conditions
  /// [androidAppId] app_id, apply through application monitoring console
  /// [iOSAppId] app_id, apply through application monitoring console
  /// [sampleRate] Sampling rate, range [0,1], 0 means no collection, 1 means full collection, default value is 1. Scope is all View, Action, LongTask, Error data under the same session_id
  /// [sessionOnErrorSampleRate] Set error sampling rate, when session is not sampled by setSamplingRate, if error occurs during session, data from 1 minute before error can be collected, range [0,1], 0 means no collection, 1 means full collection, default value is 0. Scope is all View, Action, LongTask, Error data under the same session_id
  /// [enableNativeUserAction] Whether to perform Native Action tracking, Button click events, pure flutter applications recommend turning off
  /// [enableNativeUserView] Whether to perform Native View automatic tracking, pure Flutter applications recommend turning off
  /// [enableNativeUserViewInFragment] Whether to automatically track Native Fragment type page data, default is false. Android only
  /// [enableNativeUserResource] Whether to perform Native Resource automatic tracking, pure Flutter applications recommend turning off
  /// [enableNativeAppUIBlock] Whether to perform Native Freeze automatic tracking
  /// [uiBlockDurationMS] Whether to set time range for Freeze uiBlockDurationMS
  /// [enableTrackNativeAppANR] Whether to enable Native ANR monitoring
  /// [enableTrackNativeCrash] Whether to enable Android Java Crash and C/C++ crash monitoring
  /// [errorMonitorType] Monitoring supplement type
  /// [deviceMonitorType] Monitoring supplement type
  /// [globalContext] Custom global parameters
  /// [rumCacheLimitCount] RUM maximum cache amount, default 100_000
  /// [rumCacheDiscard] RUM data discard strategy
  /// [isInTakeUrl] RUM resource url filter, true means accept data collection
  Future<void> setConfig(
      {String? androidAppId,
      String? iOSAppId,
      double? sampleRate,
      double? sessionOnErrorSampleRate,
      bool enableUserResource = false,
      bool? enableNativeUserAction,
      bool? enableNativeUserView,
      bool? enableNativeUserViewInFragment,
      bool? enableNativeUserResource,
      bool? enableNativeAppUIBlock,
      int? nativeUiBlockDurationMS,
      bool? enableTrackNativeAppANR,
      bool? enableTrackNativeCrash,
      int? errorMonitorType,
      int? deviceMetricsMonitorType,
      DetectFrequency? detectFrequency,
      Map<String, String>? globalContext,
      int? rumCacheLimitCount,
      FTRUMCacheDiscard? rumCacheDiscard,
      bool Function(String url)? isInTakeUrl,
      bool? enableTraceWebView,
      List<String>? allowWebViewHost}) async {
    Map<String, dynamic> map = {};
    if (Platform.isAndroid) {
      map["rumAppId"] = androidAppId;
    } else if (Platform.isIOS) {
      map["rumAppId"] = iOSAppId;
    }
    map["sampleRate"] = sampleRate;
    map["sessionOnErrorSampleRate"] = sessionOnErrorSampleRate;
    map["enableUserAction"] = enableNativeUserAction;
    map["enableUserView"] = enableNativeUserView;
    map["enableUserViewInFragment"] = enableNativeUserViewInFragment;
    map["enableUserResource"] = enableNativeUserResource;
    map["enableAppUIBlock"] = enableNativeAppUIBlock;
    map["nativeUiBlockDurationMS"] = nativeUiBlockDurationMS;
    map["enableTrackNativeAppANR"] = enableTrackNativeAppANR;
    map["enableTrackNativeCrash"] = enableTrackNativeCrash;
    map["errorMonitorType"] = errorMonitorType;
    map["deviceMetricsMonitorType"] = deviceMetricsMonitorType;
    map["detectFrequency"] = detectFrequency?.index;
    map["globalContext"] = globalContext;
    map["rumCacheLimitCount"] = rumCacheLimitCount;
    map["rumCacheDiscard"] = rumCacheDiscard?.index;
    map["enableTraceWebView"] = enableTraceWebView;
    map["allowWebViewHost"] = allowWebViewHost;
    FTHttpOverrideConfig.global.traceResource = enableUserResource;
    FTHttpOverrideConfig.global.isInTakeUrl = isInTakeUrl;
    await channel.invokeMethod(methodRumConfig, map);
  }

  /// Add action
  ///
  /// The startAction method includes a duration calculation mechanism and attempts
  /// to associate data with nearby Resource, LongTask, and Error events during that period.
  /// It has a 100 ms frequency protection mechanism and is recommended for user interaction-type events.
  /// If you need to call actions frequently, please use addAction instead. This method does not conflict
  /// with startAction and does not associate with the current Resource, LongTask, or Error events.
  ///
  /// [actionName] Action name
  /// [actionType] Action type
  /// [property] Additional property parameters (optional)
  Future<void> startAction(String actionName, String actionType,
      {Map<String, String>? property}) async {
    Map<String, dynamic> map = {};
    map["actionName"] = actionName;
    map["actionType"] = actionType;
    map["property"] = property;
    await channel.invokeMethod(methodRumAddAction, map);
  }

  /// Add action，this type of data cannot be associated with Error, Resource, LongTask data
  /// [actionName] Action name
  /// [actionType] Action type
  /// [property] Additional property parameters (optional)
  Future<void> addAction(String actionName, String actionType,
      {Map<String, String>? property}) async {
    Map<String, dynamic> map = {};
    map["actionName"] = actionName;
    map["actionType"] = actionType;
    map["property"] = property;
    await channel.invokeMethod(methodRumAddAction, map);
  }

  /// View start
  /// [viewName] Interface name
  /// [viewReferer] Previous interface name
  /// [property] Additional property parameters (optional)
  Future<void> starView(String viewName,
      {Map<String, String>? property}) async {
    Map<String, dynamic> map = {};
    map["viewName"] = viewName;
    map["property"] = property;
    await channel.invokeMethod(methodRumStartView, map);
  }

  /// View creation, this method needs to be called before [starView], currently not available in flutter route
  /// [viewName] Interface name
  /// [duration] Creation time, nanoseconds
  Future<void> createView(String viewName, int duration) async {
    Map<String, dynamic> map = {};
    map["viewName"] = viewName;
    map["duration"] = duration;
    await channel.invokeMethod(methodRumCreateView, map);
  }

  /// View end
  /// [property] Additional property parameters (optional)
  Future<void> stopView({Map<String, String>? property}) async {
    Map<String, dynamic> map = {};
    map["property"] = property;
    await channel.invokeMethod(methodRumStopView, map);
  }

  /// Other exception capture and log collection
  /// [obj] Error content
  /// [stack] Stack log
  void addError(Object obj, StackTrace stack) {
    if (obj is FlutterErrorDetails) {
      return addFlutterError(obj);
    }
    addCustomError(stack.toString(), obj.toString());
  }

  /// Flutter framework exception capture
  /// [error] Error log
  void addFlutterError(FlutterErrorDetails error) {
    addCustomError(error.stack.toString(), error.exceptionAsString());
  }

  /// Add custom error
  /// [stack] Stack log
  /// [message] Error message
  /// [appState] Application state
  /// [errorType] Custom errorType
  /// [property] Additional property parameters (optional)
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
  /// [key] Unique id
  /// [property] Additional property parameters (optional)
  Future<void> startResource(String key,
      {Map<String, String>? property}) async {
    Map<String, dynamic> map = {};
    map["key"] = key;
    map["property"] = property;
    await channel.invokeMethod(methodRumStartResource, map);
  }

  /// End resource request
  /// [key] Unique id
  /// [property] Additional property parameters (optional)
  Future<void> stopResource(String key, {Map<String, String>? property}) async {
    Map<String, dynamic> map = {};
    map["key"] = key;
    map["property"] = property;
    await channel.invokeMethod(methodRumStopResource, map);
  }

  /// Send resource data metrics
  /// [key] Unique id
  /// [url] Request address
  /// [httpMethod] Request method
  /// [requestHeader] Request header parameters
  /// [responseHeader] Response header parameters
  /// [responseBody] Response content
  /// [resourceStatus] Response status code
  Future<void> addResource(
      {required String key,
      required String url,
      required String httpMethod,
      required Map<String, dynamic> requestHeader,
      Map<String, dynamic>? responseHeader,
      String? responseBody = "",
      int? resourceStatus,
      int? resourceSize}) async {
    Map<String, dynamic> map = {};
    map["key"] = key;
    map["url"] = url;
    map["resourceMethod"] = httpMethod;
    map["requestHeader"] = requestHeader;
    map["responseHeader"] = responseHeader;
    map["responseBody"] = responseBody;
    map["resourceStatus"] = resourceStatus;
    map["resourceSize"] = resourceSize;
    await channel.invokeMethod(methodRumAddResource, map);
  }
}

/// App running state
enum AppState {
  /// Unknown
  unknown,

  /// Startup
  startup,

  /// Running
  run
}

/// Set auxiliary monitoring information, add additional monitoring data to RUM Error data
enum ErrorMonitorType {
  /// All data
  all,

  /// Battery level
  battery,

  /// Memory usage
  memory,

  /// CPU usage
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

/// Add monitoring data during View cycle
enum DeviceMetricsMonitorType {
  /// All data
  all,

  /// Monitor current page's maximum current output
  battery,

  /// Monitor current application memory usage
  memory,

  /// Monitor CPU jump count
  cpu,

  /// Monitor screen frame rate
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
/// Detection cycle, unit milliseconds MS
///
enum DetectFrequency {
  /// Default detection frequency 500 ms once
  normal,

  /// High frequency collection, 100 ms once
  frequent,

  /// Low frequency collection 1000 ms once
  rare
}

/// RUM discard method
enum FTRUMCacheDiscard {
  /// Discard new logs
  discard,

  /// Discard old logs
  discardOldest
}
