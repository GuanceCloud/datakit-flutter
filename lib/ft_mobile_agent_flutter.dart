import 'dart:io';

import 'package:ft_mobile_agent_flutter/version.dart';

import 'const.dart';

export 'ft_http_client.dart';
export 'ft_logger.dart';
export 'ft_route_observer.dart';
export 'ft_rum.dart';
export 'ft_tracing.dart';

class FTMobileFlutter {
  /// 配置
  /// [serverUrl] datakit 访问 URL 地址，例子：http://10.0.0.1:9529，端口默认 9529。deprecated
  /// [datakitUrl] datakit 访问 URL 地址，例子：http://10.0.0.1:9529，端口默认 9529。 datakit 与 dataway 配置二选一
  /// [datawayUrl] dataway 访问 URL 地址，例子：http://10.0.0.1:9528，端口默认 9528，注意：安装 SDK 设备需能访问这地址.注意：datakit 和 dataway 配置两者二选一
  /// [cliToken] dataway 认证 token，需要与 [dataw] 同时配置
  /// [debug] 默认为 false，开启后方可打印 SDK 运行日志
  /// [serviceName] 应用服务名
  /// [envType] 默认为 EnvType.PROD，envType 与 env 二选一
  /// [env] 默认为 prod, envType 与 env 二选一
  /// [enableAccessAndroidID] 开启获取 Android ID，默认，为 true，设置为 false，则 device_uuid 字段数据将不进行采集,市场隐私审核相关查看这里
  /// [globalContext] SDK 全局属性
  ///
  /// [iOSGroupIdentifiers]
  /// [dataSyncRetryCount]
  ///
  static Future<void> sdkConfig(
      {@Deprecated('using datakitUrl instead') String? serverUrl,
      String? datakitUrl,
      String? datawayUrl,
      String? cliToken,
      bool? debug,
      String? serviceName,
      EnvType? envType,
      String? env,
      bool? enableAccessAndroidID,
      int? dataSyncRetryCount,
      bool? autoSync,
      SyncPageSize? syncPageSize,
      int? customSyncPageSize,
      int? syncSleepTime,
      Map<String, String>? globalContext,
      List<String>? iOSGroupIdentifiers}) async {
    Map<String, dynamic> map = {};
    map["datakitUrl"] = serverUrl;
    if (datakitUrl != null && datakitUrl.isNotEmpty) {
      map["datakitUrl"] = datakitUrl;
    }

    map["env"] = envType?.toString();
    if (env != null && env.isNotEmpty) {
      map["env"] = env;
    }
    map["datawayUrl"] = datawayUrl;
    map["cliToken"] = cliToken;
    map["debug"] = debug;
    map["serviceName"] = serviceName;
    map["autoSync"] = autoSync;
    map["syncPageSize"] = syncPageSize?.index;
    map["customSyncPageSize"] = customSyncPageSize;
    map["syncSleepTime"] = syncSleepTime;
    map["groupIdentifiers"] = iOSGroupIdentifiers;
    if (globalContext == null) {
      globalContext = {};
    }
    globalContext["sdk_package_flutter"] = "legacy_" + packageVersion;
    map["globalContext"] = globalContext;
    if (Platform.isAndroid) {
      map["dataSyncRetryCount"] = dataSyncRetryCount;
      map["enableAccessAndroidID"] = enableAccessAndroidID;
    }
    await channel.invokeMethod(methodConfig, map);
    if (Platform.isAndroid) {
      _configChannel();
    }
  }

  ///绑定用户
  ///
  ///[userid] 用户 id
  ///[userName] 用户名
  ///[userEmail] 用户邮箱
  ///[userExt] 扩展数据
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

  ///
  /// 日志回调对象
  ///
  ///[level]日志登记
  ///[tag] 日志 tag
  ///[message] 日志内容
  static void Function(String level, String tag, String message)?
      innerLogHandler;

  ///设置内部日志接管对象
  ///[handler] 回调对象
  static Future<void> registerInnerLogHandler(
      void Function(String level, String tag, String message) handler) async {
    if (!Platform.isAndroid) return null;
    FTMobileFlutter.innerLogHandler = handler;
    return await channel.invokeMethod(methodSetInnerLogHandler);
  }

  static _configChannel() {
    channel.setMethodCallHandler((call) async {
      var args = call.arguments;

      switch (call.method) {
        case methodInvokeInnerLog:
          String level = args["level"] ?? "";
          String tag = args["tag"] ?? "";
          String message = args["message"] ?? "";
          FTMobileFlutter.innerLogHandler?.call(level, tag, message);
          break;
        default:
          print('no method handler for method ${call.method}');
      }
    });
  }
}

///[prod] 生成
///[gray] 灰度
///[pre]  预发
///[common]
///[local] 本地
enum EnvType { prod, gray, pre, common, local }

///
///[mini]   5 条
///[medium] 10 条
///[large]  50 条
enum SyncPageSize { mini, medium, large }
