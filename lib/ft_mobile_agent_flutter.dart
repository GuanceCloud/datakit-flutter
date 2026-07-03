import 'dart:io';

import 'package:ft_mobile_agent_flutter/version.dart';

import 'const.dart';
import 'ft_http_override_config.dart';

export 'ft_http_client.dart';
export 'ft_logger.dart';
export 'ft_route_observer.dart';
export 'ft_rum.dart';
export 'ft_tracing.dart';

typedef FTRemoteConfigListener = void Function(FTRemoteConfigResult result);

class FTRemoteConfigResult {
  FTRemoteConfigResult({
    required this.triggerType,
    required this.success,
    required this.platform,
    required this.timestamp,
    this.rawJson,
    this.errorCode,
    this.errorMessage,
    this.appliedOverrideRuleIds,
  });

  final String triggerType;
  final bool success;
  final String platform;
  final int timestamp;
  final String? rawJson;
  final Object? errorCode;
  final String? errorMessage;
  final List<String>? appliedOverrideRuleIds;

  factory FTRemoteConfigResult.fromMap(Map<dynamic, dynamic> map) {
    final ids = map['appliedOverrideRuleIds'];
    return FTRemoteConfigResult(
      triggerType: map['triggerType']?.toString() ?? '',
      success: map['success'] == true,
      platform: map['platform']?.toString() ?? '',
      timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
      rawJson: map['rawJson']?.toString(),
      errorCode: map['errorCode'],
      errorMessage: map['errorMessage']?.toString(),
      appliedOverrideRuleIds:
          ids is List ? ids.map((e) => e.toString()).toList() : null,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'triggerType': triggerType,
        'success': success,
        'platform': platform,
        'timestamp': timestamp,
        if (rawJson != null) 'rawJson': rawJson,
        if (errorCode != null) 'errorCode': errorCode,
        if (errorMessage != null) 'errorMessage': errorMessage,
        if (appliedOverrideRuleIds != null)
          'appliedOverrideRuleIds': appliedOverrideRuleIds,
      };
}

class FTMobileFlutter {
  /// Thread-safe global properties dictionary that will be automatically merged
  /// with properties passed to RUM and Logger methods
  static final Map<String, Object?> _globalProperties = <String, Object?>{
    'sdk_bridge_info': '{"flutter":"$packageVersion"}',
  };

  /// Thread-safe access to global properties
  static Map<String, Object?> get globalProperties =>
      Map.unmodifiable(_globalProperties);

  /// Append bridge context properties that will be automatically merged with all RUM and Logger calls
  /// [properties] Map of key-value pairs to be added as bridge context properties
  static void appendBridgeContext(Map<String, Object?> properties) {
    _globalProperties.addAll(properties);
  }

  /// Get a copy of current bridge context properties
  /// Returns an unmodifiable copy of the bridge context properties map
  static Map<String, Object?> getBridgeContext() {
    return Map.unmodifiable(_globalProperties);
  }

  /// Configuration
  /// [serverUrl] datakit access URL address, example: http://10.0.0.1:9529, default port 9529. deprecated
  /// [datakitUrl] datakit access URL address, example: http://10.0.0.1:9529, default port 9529. Choose between datakit and dataway configuration
  /// [datawayUrl] dataway access URL address, example: http://10.0.0.1:9528, default port 9528, note: SDK installation device needs to access this address. Note: Choose between datakit and dataway configuration
  /// [cliToken] dataway authentication token, needs to be configured together with [datawayUrl]
  /// [debug] Default is false, SDK runtime logs can be printed after enabling
  /// [serviceName] Application service name
  /// [envType] Default is EnvType.PROD, choose between envType and env
  /// [env] Default is prod, choose between envType and env
  /// [enableAccessAndroidID] Enable Android ID access, default is true, set to false to disable device_uuid field data collection, see here for market privacy review
  /// [globalContext] SDK global attributes
  /// [dataModifier] Data modifier, modify individual fields {key:value}, after setting SDK will replace original value with set value based on key
  /// [lineDataModifier] Data modifier, modify single data {"measurement":measurement,"data":{key:value}}, after setting SDK will replace original value with set value based on key
  /// [iOSGroupIdentifiers]
  /// [dataSyncRetryCount] Android only
  /// [customHttpOverrides] Custom HttpOverrides object, used when enabling HTTP tracing
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
      HttpOverrides? customHttpOverrides,
      SyncPageSize? syncPageSize,
      int? customSyncPageSize,
      int? syncSleepTime,
      bool? compressIntakeRequests,
      bool? enableLimitWithDbSize,
      int? dbCacheLimit,
      FTDBCacheDiscard? dbCacheDiscard,
      bool? enableDataIntegerCompatible,
      Map<String, String>? globalContext,
      Map<String, Object>? dataModifier,
      Map<String, Map<String, Object>>? lineDataModifier,
      bool? enableRemoteConfiguration,
      int? remoteConfigMiniUpdateInterval,
      List<Map<String, Object?>>? remoteConfigOverrideRules,
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
    map["compressIntakeRequests"] = compressIntakeRequests;
    map["enableDataIntegerCompatible"] = enableDataIntegerCompatible;
    map["groupIdentifiers"] = iOSGroupIdentifiers;
    if (globalContext == null) {
      globalContext = {};
    }
    map["globalContext"] = globalContext;
    map["enableLimitWithDbSize"] = enableLimitWithDbSize;
    map["dbCacheLimit"] = dbCacheLimit;
    map["dbCacheDiscard"] = dbCacheDiscard?.index;
    if (Platform.isAndroid) {
      map["dataSyncRetryCount"] = dataSyncRetryCount;
      map["enableAccessAndroidID"] = enableAccessAndroidID;
    }
    map["dataModifier"] = dataModifier;
    map["lineDataModifier"] = lineDataModifier;
    map["enableRemoteConfiguration"] = enableRemoteConfiguration;
    map["remoteConfigMiniUpdateInterval"] = remoteConfigMiniUpdateInterval;
    map["remoteConfigOverrideRules"] = remoteConfigOverrideRules;
    map["pkgInfo"] = packageVersion;

    // set custom HttpOverrides for HTTP tracing if provided
    FTHttpOverrideConfig.global.customHttpOverrides = customHttpOverrides;
    await channel.invokeMethod(methodConfig, map);
    if (Platform.isAndroid) {
      _configChannel();
    }
  }

  /// Dynamically set the Datakit upload URL after SDK initialization.
  static Future<void> setDatakitURL(String datakitUrl) async {
    return await channel.invokeMethod(
        methodSetDatakitUrl, <String, dynamic>{'datakitUrl': datakitUrl});
  }

  /// Dynamically set the Dataway upload URL and client token after SDK initialization.
  static Future<void> setDatawayURL(String datawayUrl, String cliToken) async {
    return await channel.invokeMethod(methodSetDatawayUrl,
        <String, dynamic>{'datawayUrl': datawayUrl, 'cliToken': cliToken});
  }

  /// Update remote configuration with the SDK configured minimum interval.
  static Future<FTRemoteConfigResult> updateRemoteConfig() async {
    final Map<dynamic, dynamic> data =
        await channel.invokeMethod(methodUpdateRemoteConfig);
    return FTRemoteConfigResult.fromMap(data);
  }

  /// Update remote configuration with a custom minimum interval.
  static Future<FTRemoteConfigResult> updateRemoteConfigWithMiniUpdateInterval(
      int interval,
      {List<Map<String, Object?>>? remoteConfigOverrideRules}) async {
    final Map<dynamic, dynamic> data = await channel.invokeMethod(
        methodUpdateRemoteConfigWithMiniUpdateInterval, <String, dynamic>{
      'interval': interval,
      'remoteConfigOverrideRules': remoteConfigOverrideRules,
    });
    return FTRemoteConfigResult.fromMap(data);
  }

  static final List<FTRemoteConfigListener> _remoteConfigListeners =
      <FTRemoteConfigListener>[];

  /// Listen for automatic remote configuration updates triggered by native SDK.
  static void addRemoteConfigListener(FTRemoteConfigListener listener) {
    _remoteConfigListeners.add(listener);
    _configChannel();
  }

  static void removeRemoteConfigListener(FTRemoteConfigListener listener) {
    _remoteConfigListeners.remove(listener);
  }

  /// Bind user
  ///
  /// [userid] User id
  /// [userName] Username
  /// [userEmail] User email
  /// [userExt] Extended data
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
  /// Whether to enable accessAndroidID, Android only
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
  /// Sync events from iOS extension, iOS only
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
  /// [level] Log level
  /// [tag] Log tag
  /// [message] Log content
  static void Function(String level, String tag, String message)?
      innerLogHandler;

  /// Set internal log handler object
  /// [handler] Callback object
  static Future<void> registerInnerLogHandler(
      void Function(String level, String tag, String message) handler) async {
    if (!Platform.isAndroid) return null;
    FTMobileFlutter.innerLogHandler = handler;
    _configChannel();
    return await channel.invokeMethod(methodSetInnerLogHandler);
  }

  /// Sync data immediately
  static Future<void> flushSyncData() async {
    return await channel.invokeMethod(methodFlushSyncData);
  }

  /// Dynamically set global tags
  static Future<void> appendGlobalContext(
      Map<String, dynamic> globalContext) async {
    Map<String, dynamic> map = {};
    map["globalContext"] = globalContext;
    return await channel.invokeMethod(methodAppendGlobalContext, map);
  }

  /// Dynamically set RUM global tags
  static Future<void> appendRUMGlobalContext(
      Map<String, String> globalContext) async {
    Map<String, Object> map = {};
    map["globalContext"] = globalContext;
    return await channel.invokeMethod(methodAppendRUMGlobalContext, map);
  }

  /// Dynamically set log global tags
  static Future<void> appendLogGlobalContext(
      Map<String, Object> globalContext) async {
    Map<String, dynamic> map = {};
    map["globalContext"] = globalContext;
    return await channel.invokeMethod(methodAppendLogGlobalContext, map);
  }

  /// Clear cache
  static Future<void> clearAllData() async {
    return await channel.invokeMethod(methodClearAllData);
  }

  /// ShutDown SDK
  static Future<void> shutDown() async {
    return await channel.invokeMethod(methodShutDown);
  }

  /// Set custom HttpOverrides
  /// [httpOverrides] Custom HttpOverrides object, if null, will use default FTHttpOverrides()
  static void setCustomHttpOverrides(HttpOverrides? httpOverrides) {
    FTHttpOverrideConfig.global.customHttpOverrides = httpOverrides;
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
        case methodRemoteConfigCallback:
          if (args is Map) {
            final result = FTRemoteConfigResult.fromMap(args);
            for (final listener
                in List<FTRemoteConfigListener>.from(_remoteConfigListeners)) {
              listener(result);
            }
          }
          break;
        default:
          print('no method handler for method ${call.method}');
      }
    });
  }
}

/// [prod] Production
/// [gray] Gray
/// [pre] Pre-release
/// [common]
/// [local] Local
enum EnvType { prod, gray, pre, common, local }

///
/// [mini] 5 items
/// [medium] 10 items
/// [large] 50 items
enum SyncPageSize { mini, medium, large }

/// DB discard method
enum FTDBCacheDiscard {
  /// Discard new logs
  discard,

  /// Discard old logs
  discardOldest
}
