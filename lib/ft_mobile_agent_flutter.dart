import 'dart:io';

import 'package:ft_mobile_agent_flutter/version.dart';

import 'const.dart';

export 'ft_http_client.dart';
export 'ft_logger.dart';
export 'ft_route_observer.dart';
export 'ft_rum.dart';
export 'ft_tracing.dart';

class FTMobileFlutter {
  /// Configuration
  /// [serverUrl] datakit access URL address, example: http://10.0.0.1:9529, default port 9529. deprecated
  /// [datakitUrl] datakit access URL address, example: http://10.0.0.1:9529, default port 9529. Choose one between datakit and dataway configuration
  /// [datawayUrl] dataway access URL address, example: http://10.0.0.1:9528, default port 9528, Note: SDK installation device must be able to access this address. Note: Choose one between datakit and dataway configuration
  /// [cliToken] dataway authentication token, needs to be configured together with [datawayUrl]
  /// [debug] defaults to false, SDK runtime logs can be printed after enabling
  /// [serviceName] application service name
  /// [envType] defaults to EnvType.PROD, choose one between envType and env
  /// [env] defaults to prod, choose one between envType and env
  /// [enableAccessAndroidID] enable Android ID acquisition, default is true, set to false, then device_uuid field data will not be collected, market privacy review related see here
  /// [globalContext] SDK global properties
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

  /// Bind user
  ///
  /// [userid] user id
  /// [userName] username
  /// [userEmail] user email
  /// [userExt] extended data
  static Future<void> bindRUMUserData(String userId,
      {String? userName, String? userEmail, Map<String, String>? ext}) async {
    Map<String, dynamic> map = {};
    map["userId"] = userId;
    map["userName"] = userName;
    map["userEmail"] = userEmail;
    map["userExt"] = ext;
    return await channel.invokeMethod(methodBindUser, map);
  }

  /// Unbind user
  static Future<void> unbindRUMUserData() async {
    return await channel.invokeMethod(methodUnbindUser);
  }

  ///
  /// Whether to enable accessAndroidID, only supports Android
  /// [enableAccessAndroidID] true to enable, false to disable
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
  /// Synchronize events from iOS extension, only supports iOS
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
  /// Log callback object
  ///
  /// [level] log level
  /// [tag] log tag
  /// [message] log content
  static void Function(String level, String tag, String message)?
      innerLogHandler;

  /// Set internal log takeover object
  /// [handler] callback object
  static Future<void> registerInnerLogHandler(
      void Function(String level, String tag, String message) handler) async {
    if (!Platform.isAndroid) return null;
    FTMobileFlutter.innerLogHandler = handler;
    return await channel.invokeMethod(methodSetInnerLogHandler);
  }

  /// Immediately sync data
  static Future<void> flushSyncData() async {
    return await channel.invokeMethod(methodFlushSyncData);
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

/// [prod] production
/// [gray] gray
/// [pre] pre-release
/// [common] common
/// [local] local
enum EnvType { prod, gray, pre, common, local }

///
/// [mini] 5 items
/// [medium] 10 items
/// [large] 50 items
enum SyncPageSize { mini, medium, large }
