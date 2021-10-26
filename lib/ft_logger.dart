import 'const.dart';

class FTLogger {

  static final FTLogger _singleton = FTLogger._internal();

  factory FTLogger() {
    return _singleton;
  }

  FTLogger._internal();

  ///输出日志
  Future<void> logging(String content, FTLogStatus status) async {
    Map<String, dynamic> map = {};
    map["content"] = content;
    map["status"] = status.index;
    await channel.invokeMethod(methodLog, map);
  }

  Future<void> logConfig(
      {double? sampleRate,
      String? serviceName,
      bool? enableLinkRumData,
      bool? enableCustomLog,
      FTLogCacheDiscard? discardStrategy,
      List<FTLogStatus>? logLevelFilters}) async {
    Map<String, dynamic> map = {};
    map["sampleRate"] = sampleRate;
    map["serviceName"] = serviceName;
    map["logType"] = logLevelFilters?.map((e) => e.index).toList();
    map["enableLinkRumData"] = enableLinkRumData;
    map["enableCustomLog"] = enableCustomLog;
    await channel.invokeMethod(methodLogConfig, map);
  }
}

enum FTLogStatus {
  info,
  warning,
  error,
  critical,
  ok,
}

enum FTLogCacheDiscard { discard, discardOldest }
