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
      MonitorType? monitorType}) async {
    Map<String, dynamic> map = {};
    map["rumAppId"] = rumAppId;
    map["sampleRate"] = sampleRate;
    map["enableUserAction"] = enableUserAction;
    map["monitorType"] = monitorType?.value;
    await channel.invokeMethod(methodRumConfig, map);
  }

  Future<void> startAction(String actionName, String actionType,
      {bool needWait = false}) async {
    Map<String, dynamic> map = {};
    map["actionName"] = actionName;
    map["actionType"] = actionType;
    await channel.invokeMethod(methodRumAddAction, map);
  }

  Future<void> starview(String viewName, String viewReferer) async {
    Map<String, dynamic> map = {};
    map["viewName"] = viewName;
    map["viewReferer"] = viewReferer;
    await channel.invokeMethod(methodRumStartView, map);
  }

  Future<void> stopView() async {
    await channel.invokeMethod(methodRumStopView);
  }

  Future<void> addError(String crash, String message, AppState state) async {
    Map<String, dynamic> map = {};
    map["crash"] = crash;
    map["message"] = message;
    map["appState"] = state.index;
    await channel.invokeMethod(methodRumAddError, map);
  }

  Future<void> startResource() async {
    await channel.invokeMethod(methodRumStartResource);
  }

  Future<void> stopResource() async {
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
