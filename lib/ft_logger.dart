import 'const.dart';

class FTLogger {
  static final FTLogger _singleton = FTLogger._internal();

  factory FTLogger() {
    return _singleton;
  }

  FTLogger._internal();

  ///输出日志
  ///[content] 日志内容
  ///[status] 日志状态
  ///[property] 附加属性参数(可选)
  Future<void> logging(String content, FTLogStatus status,
      {Map<String, String>? property, bool? isSilence}) async {
    Map<String, dynamic> map = {};
    map["content"] = content;
    map["status"] = status.index;
    map["isSilence"] = isSilence;
    map["property"] = property;
    await channel.invokeMethod(methodLog, map);
  }

  /// 配置日志输出配置
  /// [sampleRate] 采样率
  /// [enableLinkRumData] 是否与 RUM 关联
  /// [enableCustomLog] 是否开启自定义日志
  /// [printCustomLogToConsole] 是否打印自定义到控制台
  /// [discardStrategy] 日志丢弃策略
  /// [logLevelFilters] 日志等级过滤
  /// [globalContext] 自定义全局参数
  Future<void> logConfig(
      {double? sampleRate,
      bool? enableLinkRumData,
      bool? enableCustomLog,
      bool? printCustomLogToConsole,
      FTLogCacheDiscard? discardStrategy,
      List<FTLogStatus>? logLevelFilters,
      Map<String, String>? globalContext}) async {
    Map<String, dynamic> map = {};
    map["sampleRate"] = sampleRate;
    map["logType"] = logLevelFilters?.map((e) => e.index).toList();
    map["enableLinkRumData"] = enableLinkRumData;
    map["enableCustomLog"] = enableCustomLog;
    map["logCacheDiscard"] = discardStrategy;
    map["printCustomLogToConsole"] = printCustomLogToConsole;
    map["globalContext"] = globalContext;
    await channel.invokeMethod(methodLogConfig, map);
  }
}

/// 设置日志等级
enum FTLogStatus {
  info,
  warning,
  error,
  critical,
  ok,
}

/// 日志丢弃方式
enum FTLogCacheDiscard { discard, discardOldest }
