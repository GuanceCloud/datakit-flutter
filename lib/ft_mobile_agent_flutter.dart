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

  ///绑定用户
  static Future<void> bindUser(String userId) async {
    Map<String, dynamic> map = {};
    map["userId"] = userId;
    return await channel.invokeMethod(methodBindUser, map);
  }

  ///解绑用户
  static Future<void> unbindUser() async {
    return await channel.invokeMethod(methodUnbindUser);
  }
}

enum EnvType { prod, gray, pre, common, local }
