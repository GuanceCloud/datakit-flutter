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
  Future<void> logging(String content, FTLogStatus status) async {
    Map<String, dynamic> map = {};
    map["content"] = content;
    map["status"] = status.index;
    await channel.invokeMethod(methodLog, map);
  }

  /// 配置日志输出配置
  /// [sampleRate] 采样率
  /// [serviceName] 服务名
  /// [enableLinkRumData] 是否与 RUM 关联
  /// [enableCustomLog] 是否开启自定义日志
  /// [discardStrategy] 日志丢弃策略
  /// [logLevelFilters] 日志等级过滤
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
