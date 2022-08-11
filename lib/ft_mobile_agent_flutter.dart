import 'dart:collection';

import 'package:ft_mobile_agent_flutter/version.dart';

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
      EnvType? envType,
      Map<String, String>? globalContext}) async {
    Map<String, dynamic> map = {};
    map["metricsUrl"] = serverUrl;
    map["useOAID"] = useOAID;
    map["debug"] = debug;
    map["datakitUUID"] = datakitUUID;
    map["env"] = envType?.index;
    if (globalContext == null) {
      globalContext = {};
    }
    globalContext["sdk_package_flutter"] = packageVersion;
    map["globalContext"] = globalContext;
    await channel.invokeMethod(methodConfig, map);
  }

  ///绑定用户
  static Future<void> bindRUMUserData(String userId,
      {String? userName,
      String? userEmail,
      Map<String, String>? ext}) async {
    Map<String, dynamic> map = {};
    map["userId"] = userId;
    map["userName"] = userName;
    map["userEmail"] = userEmail;
    map["userExt"] = ext;
    return await channel.invokeMethod(methodBindUser, map);
  }

  ///解绑用户
  static Future<void> unbindRUMUserData() async {
    return await channel.invokeMethod(methodUnbindUser);
  }
}

enum EnvType { prod, gray, pre, common, local }
