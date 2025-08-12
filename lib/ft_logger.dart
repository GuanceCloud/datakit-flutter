import 'const.dart';

class FTLogger {
  static final FTLogger _singleton = FTLogger._internal();

  factory FTLogger() {
    return _singleton;
  }

  FTLogger._internal();

  ///Output log
  ///[content] log content
  ///[status] log status
  ///[property] additional property parameters (optional)
  Future<void> logging(String content, FTLogStatus status,
      {Map<String, String>? property, bool? isSilence}) async {
    Map<String, dynamic> map = {};
    map["content"] = content;
    map["status"] = status.index;
    map["isSilence"] = isSilence;
    map["property"] = property;
    await channel.invokeMethod(methodLogging, map);
  }

  /// Configure log output configuration
  /// [sampleRate] sampling rate
  /// [enableLinkRumData] whether to associate with RUM
  /// [enableCustomLog] whether to enable custom logs
  /// [printCustomLogToConsole] whether to print custom logs to console
  /// [discardStrategy] log discard strategy
  /// [logLevelFilters] log level filters
  /// [globalContext] custom global parameters
  Future<void> logConfig(
      {double? sampleRate,
      bool? enableLinkRumData,
      bool? enableCustomLog,
      bool? printCustomLogToConsole,
      FTLogCacheDiscard? discardStrategy,
      int? logCacheLimitCount,
      List<FTLogStatus>? logLevelFilters,
      Map<String, String>? globalContext}) async {
    Map<String, dynamic> map = {};
    map["sampleRate"] = sampleRate;
    map["logType"] = logLevelFilters?.map((e) => e.index).toList();
    map["enableLinkRumData"] = enableLinkRumData;
    map["enableCustomLog"] = enableCustomLog;
    map["logCacheDiscard"] = discardStrategy;
    map["logCacheLimitCount"] = logCacheLimitCount;
    map["printCustomLogToConsole"] = printCustomLogToConsole;
    map["globalContext"] = globalContext;
    await channel.invokeMethod(methodLogConfig, map);
  }
}

/// Set log level
enum FTLogStatus {
  info,
  warning,
  error,
  critical,
  ok,
}

/// Log discard method
enum FTLogCacheDiscard { discard, discardOldest }
