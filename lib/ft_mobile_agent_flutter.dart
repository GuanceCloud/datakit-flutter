import 'const.dart';

export 'ft_logger.dart';
export 'ft_rum.dart';
export 'ft_tracing.dart';
class FTMobileFlutter {
  /// 配置
  static Future<void> sdkConfig(
      {required String serverUrl,
      bool? useOAID,
      bool? debug,
      String? datakitUUID,
      EnvType? envType}) async {
    Map<String, dynamic> map = {};
    map["metricsUrl"] = serverUrl;
    map["useOAID"] = useOAID;
    map["debug"] = debug;
    map["datakitUUID"] = datakitUUID;
    map["env"] = envType?.index;
    await channel.invokeMethod(methodConfig, map);
  }
}

enum EnvType { prod, gray, pre, common, local }
