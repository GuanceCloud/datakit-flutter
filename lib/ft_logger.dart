import 'const.dart';

class FTLogger {
  static final FTLogger _singleton = FTLogger._internal();

  factory FTLogger() {
    return _singleton;
  }

  FTLogger._internal();

  /// Output log
  /// [content] Log content
  /// [status] Log status
  /// [property] Additional property parameters (optional)
  /// [isSilence]
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
  /// [sampleRate] Sampling rate
  /// [enableLinkRumData] Whether to link with RUM
  /// [enableCustomLog] Whether to enable custom logs
  /// [printCustomLogToConsole] Whether to print custom logs to console
  /// [logCacheDiscard] Log discard strategy
  /// [logLevelFilters] Log level filters
  /// [globalContext] Custom global parameters
  Future<void> logConfig(
      {double? sampleRate,
      bool? enableLinkRumData,
      bool? enableCustomLog,
      bool? printCustomLogToConsole,
      FTLogCacheDiscard? logCacheDiscard,
      int? logCacheLimitCount,
      List<FTLogStatus>? logLevelFilters,
      Map<String, String>? globalContext}) async {
    Map<String, dynamic> map = {};
    map["sampleRate"] = sampleRate;
    map["logType"] = logLevelFilters?.map((e) => e.index).toList();
    map["enableLinkRumData"] = enableLinkRumData;
    map["enableCustomLog"] = enableCustomLog;
    map["logCacheDiscard"] = logCacheDiscard?.index;
    map["logCacheLimitCount"] = logCacheLimitCount;
    map["printCustomLogToConsole"] = printCustomLogToConsole;
    map["globalContext"] = globalContext;
    await channel.invokeMethod(methodLogConfig, map);
  }
}

/// Set log level
enum FTLogStatus {
  /// Info
  info,

  /// Warning
  warning,

  /// Error
  error,

  /// Critical
  critical,

  /// OK
  ok,
}

/// Log discard method
enum FTLogCacheDiscard {
  /// Discard new logs
  discard,

  /// Discard old logs
  discardOldest
}
