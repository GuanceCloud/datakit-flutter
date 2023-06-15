import 'dart:io';

import 'package:ft_mobile_agent_flutter/version.dart';

import 'const.dart';

export 'ft_http_client.dart';
export 'ft_logger.dart';
export 'ft_route_observer.dart';
export 'ft_rum.dart';
export 'ft_tracing.dart';

String _myInternalVariable = 'Internal Data';

class FTMobileFlutter {
  /// 配置
  static Future<void> sdkConfig(
      {required String serverUrl,
      bool? useOAID,
      bool? debug,
      String? serviceName,
      EnvType? envType,
      bool? enableAccessAndroidID,
      Map<String, String>? globalContext,
      List<String>? iOSGroupIdentifiers}) async {
    Map<String, dynamic> map = {};
    map["metricsUrl"] = serverUrl;
    map["useOAID"] = useOAID;
    map["debug"] = debug;
    map["serviceName"] = serviceName;
    map["env"] = envType?.index;
    map["groupIdentifiers"] = iOSGroupIdentifiers;
    if (globalContext == null) {
      globalContext = {};
    }
    globalContext["sdk_package_flutter"] = packageVersion;
    map["globalContext"] = globalContext;
    if (Platform.isAndroid) {
      map["enableAccessAndroidID"] = enableAccessAndroidID;
    }
    await channel.invokeMethod(methodConfig, map);
  }

  ///绑定用户
  static Future<void> bindRUMUserData(String userId,
      {String? userName, String? userEmail, Map<String, String>? ext}) async {
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

  ///
  /// 是否开启使用 accessAndroidID，仅支持 Android
  /// [enableAccessAndroidID] true 开启，false 不开启
  ///
  ///
  static Future<void> setEnableAccessAndroidID(
      bool enableAccessAndroidID) async {
    if (!Platform.isAndroid) return;

    Map<String, dynamic> map = {};
    map["enableAccessAndroidID"] = enableAccessAndroidID;
    return await channel.invokeMethod(methodEnableAccessAndroidID, map);
  }

  ///
  /// 同步 ios extension 中的事件，仅支持 iOS
  /// [groupIdentifier] app groupId
  ///
  static Future<Map<String, dynamic>> trackEventFromExtension(
      String groupIdentifier) async {
    if (!Platform.isIOS) return {};
    Map<String, dynamic> map = {};
    map["groupIdentifier"] = groupIdentifier;
    Map? data = await channel.invokeMethod(methodTrackEventFromExtension, map);
    if (data != null) {
      return new Map<String, dynamic>.from(data);
    } else {
      return <String, dynamic>{};
    }
  }
}

enum EnvType { prod, gray, pre, common, local }
