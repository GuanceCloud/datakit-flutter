import Flutter
import UIKit
import FTMobileSDK

public class SwiftAgentPlugin: NSObject, FlutterPlugin {

    private var channel: FlutterMethodChannel?
    private var remoteConfigurationEnabled = false
    private var remoteConfigMiniUpdateInterval = 12 * 60 * 60
    private var remoteConfigOverrideRules: [[String: Any]]?

    static let METHOD_CONFIG = "ftConfig"
    static let METHOD_FLUSH_SYNC_DATA = "ftFlushSyncData"
    static let METHOD_SET_DATAKIT_URL = "ftSetDatakitUrl"
    static let METHOD_SET_DATAWAY_URL = "ftSetDatawayUrl"
    static let METHOD_UPDATE_REMOTE_CONFIG = "ftUpdateRemoteConfig"
    static let METHOD_UPDATE_REMOTE_CONFIG_WITH_MINI_UPDATE_INTERVAL = "ftUpdateRemoteConfigWithMiniUpdateInterval"
    static let METHOD_REMOTE_CONFIG_CALLBACK = "ftRemoteConfigCallback"

    static let METHOD_BIND_USER = "ftBindUser"
    static let METHOD_UNBIND_USER = "ftUnBindUser"
    static let METHOD_TRACK_EVENT_FROM_EXTENSION = "ftTrackEventFromExtension"

    static let METHOD_APPEND_GLOBAL_CONTEXT = "ftAppendGlobalContext"
    static let METHOD_APPEND_RUM_GLOBAL_CONTEXT = "ftAppendRUMGlobalContext"
    static let METHOD_APPEND_LOG_GLOBAL_CONTEXT = "ftAppendLogGlobalContext"
    
    static let METHOD_CLEAR_ALL_DATA = "ftClearAllData"
    static let METHOD_SHUT_DOWN = "ftShutDown"

    static let METHOD_LOG_CONFIG = "ftLogConfig"
    static let METHOD_LOGGING = "ftLogging"
    static let METHOD_LOGGING_WITH_STATUS_STRING = "ftLoggingWithStatusString"

    static let METHOD_RUM_CONFIG = "ftRumConfig"
    static let METHOD_RUM_START_ACTION = "ftRumStartAction"
    static let METHOD_RUM_ADD_ACTION = "ftRumAddAction"
    static let METHOD_RUM_CREATE_VIEW = "ftRumCreateView"
    static let METHOD_RUM_START_VIEW = "ftRumStartView"
    static let METHOD_RUM_STOP_VIEW = "ftRumStopView"
    static let METHOD_RUM_ADD_ERROR = "ftRumAddError"
    static let METHOD_RUM_START_RESOURCE = "ftRumStartResource"
    static let METHOD_RUM_ADD_RESOURCE = "ftRumAddResource"
    static let METHOD_RUM_STOP_RESOURCE = "ftRumStopResource"

    static let METHOD_TRACE_CONFIG = "ftTraceConfig"
    static let METHOD_GET_TRACE_HEADER = "ftTraceGetHeader"


    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ft_mobile_agent_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftAgentPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }


    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        var context = Dictionary<String, Any>()
        if (call.arguments is Dictionary<String, Any>) {
            context = call.arguments as! Dictionary<String, Any>
        }
        switch call.method {
        case SwiftAgentPlugin.METHOD_CONFIG:
            let datakitUrl = context["datakitUrl"] as? String
            let datawayUrl = context["datawayUrl"] as? String
            let cliToken = context["cliToken"] as? String
            let config: FTMobileConfig
            if let datakitUrl = datakitUrl {
                config = FTMobileConfig(datakitUrl: datakitUrl)
            } else if let datawayUrl = datawayUrl, let cliToken = cliToken{
                config = FTMobileConfig(datawayUrl: datawayUrl, clientToken: cliToken)
            }else {
                result(nil)
                return
            }
            
            if let debug = context["debug"] as? Bool {
                config.enableSDKDebugLog = debug
            }
            if let env = context["env"] as? String {
                config.env = env
            }
            if let serviceName = context["serviceName"] as? String {
                config.service = serviceName
            }
            if let globalContext = context["globalContext"] as? Dictionary<String, String> {
                config.globalContext = globalContext
            }
            if let groupIdentifiers = context["groupIdentifiers"] as? Array<String>{
                config.groupIdentifiers = groupIdentifiers
            }
            
            if let autoSync = context["autoSync"] as? Bool {
                config.autoSync = autoSync
            }
            
            if let syncPageSize = context["syncPageSize"] as? NSNumber{
                if let syncPageSizeType = FTSyncPageSize(rawValue: syncPageSize.uintValue) {
                    config.setSyncPageSizeWithType(syncPageSizeType)
                }
            }
            
            if let customSyncPageSize = context["customSyncPageSize"] as? NSNumber{
                config.syncPageSize = customSyncPageSize.int32Value
            }
            
            if let syncSleepTime = context["syncSleepTime"] as? NSNumber{
                config.syncSleepTime = syncSleepTime.int32Value
            }

            if let compressIntakeRequests = context["compressIntakeRequests"] as? Bool{
                config.compressIntakeRequests = compressIntakeRequests
            }

             if let enableDataIntegerCompatible = context["enableDataIntegerCompatible"] as? Bool{
                 config.enableDataIntegerCompatible = enableDataIntegerCompatible
             }

            if let dbCacheDiscardType = context["dbCacheDiscard"] as? NSNumber {
                config.dbDiscardType = FTDBCacheDiscard(rawValue: dbCacheDiscardType.intValue) ?? .discard
            }
            
            if let enableLimitWithDbSize = context["enableLimitWithDbSize"] as? Bool{
                config.enableLimitWithDbSize = enableLimitWithDbSize
            }
            
            if let dbCacheLimit = context["dbCacheLimit"] as? NSNumber{
                config.dbCacheLimit = dbCacheLimit.intValue
            }

            if let dataModifierDict = context["dataModifier"] as? [String: Any] {
                config.dataModifier = { (key: String, value: Any) -> Any? in
                    return dataModifierDict[key] ?? value
                }
            }

            if let dataModifierDict = context["lineDataModifier"] as? [String: Any] {
                config.lineDataModifier = { (measurement: String, data: [String: Any]) -> [String: Any]? in
                    if measurement == FT_LOGGER_SOURCE || measurement == FT_LOGGER_TVOS_SOURCE {
                        return dataModifierDict["log"] as? [String: Any]
                    } else {
                        return dataModifierDict[measurement] as? [String: Any]
                    }
                }
            }
            
            if let enableRemoteConfiguration = context["enableRemoteConfiguration"] as? Bool{
                config.remoteConfiguration = enableRemoteConfiguration
            }
            
            if let remoteConfigMiniUpdateInterval = context["remoteConfigMiniUpdateInterval"] as? Int{
                config.remoteConfigMiniUpdateInterval = Int32(remoteConfigMiniUpdateInterval)
            }
            remoteConfigurationEnabled = config.remoteConfiguration
            remoteConfigMiniUpdateInterval = Int(config.remoteConfigMiniUpdateInterval)
            remoteConfigOverrideRules = context["remoteConfigOverrideRules"] as? [[String: Any]]
            if config.remoteConfiguration {
                config.remoteConfigFetchCompletionBlock = { [weak self] success, error, model, content in
                    guard let self = self else { return model }
                    let result = self.applyRemoteConfigOverrideRules(model: model, content: content, rules: self.remoteConfigOverrideRules)
                    self.emitRemoteConfigResult(self.remoteConfigResult(triggerType: "auto", success: success, content: content, error: error, appliedRuleIds: result.appliedRuleIds))
                    return result.model
                }
            }
            FTMobileAgent.start(withConfigOptions: config)
#if FT_SDK_TESTING
            result(test("validateBase:",context,config))
#else
            result(nil)
#endif
        case SwiftAgentPlugin.METHOD_FLUSH_SYNC_DATA:
            FTMobileAgent.sharedInstance().flushSyncData()
            result(nil)
        case SwiftAgentPlugin.METHOD_SET_DATAKIT_URL:
            if let datakitUrl = context["datakitUrl"] as? String {
                FTMobileAgent.setDatakitURL(datakitUrl)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_SET_DATAWAY_URL:
            if let datawayUrl = context["datawayUrl"] as? String, let cliToken = context["cliToken"] as? String {
                FTMobileAgent.setDatawayURL(datawayUrl, clientToken: cliToken)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_UPDATE_REMOTE_CONFIG:
            updateRemoteConfig(interval: remoteConfigMiniUpdateInterval, rules: remoteConfigOverrideRules, result: result)
        case SwiftAgentPlugin.METHOD_UPDATE_REMOTE_CONFIG_WITH_MINI_UPDATE_INTERVAL:
            let interval = context["interval"] as? Int ?? remoteConfigMiniUpdateInterval
            let rules = context["remoteConfigOverrideRules"] as? [[String: Any]] ?? remoteConfigOverrideRules
            updateRemoteConfig(interval: interval, rules: rules, result: result)
        case SwiftAgentPlugin.METHOD_BIND_USER:
            if let userId = context["userId"] as? String {
                let userName = context["userName"] as? String
                let userEmail = context["userEmail"] as? String
                let userExt = context["userExt"] as? [AnyHashable: Any]
                FTMobileAgent.sharedInstance().bindUser(withUserID: userId, userName: userName, userEmail: userEmail, extra: userExt)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_UNBIND_USER:
            FTMobileAgent.sharedInstance().unbindUser()
            result(nil)
        case SwiftAgentPlugin.METHOD_TRACK_EVENT_FROM_EXTENSION:
            if let groupIdentifier = context["groupIdentifier"] as? String{
                FTMobileAgent.sharedInstance().trackEventFromExtension(withGroupIdentifier: groupIdentifier) { groupId, datas in
                    result(["groupIdentifier":groupId,"datas":datas] as [String : Any])
                }
            }

        case SwiftAgentPlugin.METHOD_APPEND_GLOBAL_CONTEXT:
            if let globalContext = context["globalContext"] as? Dictionary<String, Any> {
                FTMobileAgent.appendGlobalContext(globalContext)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_APPEND_LOG_GLOBAL_CONTEXT:
            if let globalContext = context["globalContext"] as? Dictionary<String, Any> {
                FTMobileAgent.appendGlobalContext(globalContext)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_APPEND_RUM_GLOBAL_CONTEXT:
            if let globalContext = context["globalContext"] as? Dictionary<String, Any> {
                FTMobileAgent.appendGlobalContext(globalContext)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_CLEAR_ALL_DATA:
            FTMobileAgent.clearAllData()
            result(nil)
        case SwiftAgentPlugin.METHOD_SHUT_DOWN:
            FTMobileAgent.shutDown()
            result(nil)
        case SwiftAgentPlugin.METHOD_LOG_CONFIG:

            let logConfig = FTLoggerConfig()
            if let logCacheDiscardType = context["logCacheDiscard"] as? NSNumber {
                logConfig.discardType = FTLogCacheDiscard(rawValue: logCacheDiscardType.intValue) ?? .discard
            }

            if let sampleRate = context["sampleRate"] as? NSNumber {
                logConfig.samplerate = Int32(sampleRate.doubleValue * 100)
            }
            if let logTypeArr = context["logType"] as? [Any] {
                logConfig.logLevelFilter = logTypeArr
            }
            if let enableLinkRumData = context["enableLinkRumData"] as? Bool {
                logConfig.enableLinkRumData = enableLinkRumData
            }
            if let enableCustomLog = context["enableCustomLog"] as? Bool {
                logConfig.enableCustomLog = enableCustomLog
            }
            if let printCustomLogToConsole = context["printCustomLogToConsole"] as? Bool {
                logConfig.printCustomLogToConsole = printCustomLogToConsole
            }
            
            if let logCacheLimitCount = context["logCacheLimitCount"] as? NSNumber {
                logConfig.logCacheLimitCount = logCacheLimitCount.int32Value
            }
            
            if let globalContext = context["globalContext"] as? Dictionary<String, String> {
                logConfig.globalContext = globalContext
            }
            FTMobileAgent.sharedInstance().startLogger(withConfigOptions: logConfig)
#if FT_SDK_TESTING
            result(test("validateLog:",context,logConfig))
#else
            result(nil)
#endif
        case SwiftAgentPlugin.METHOD_LOGGING:
            if let content = context["content"] as? String {
                let status = context["status"] as? NSNumber ?? NSNumber(value: 0)
                let property = context["property"] as? Dictionary<String, Any> ?? nil
                FTMobileAgent.sharedInstance().logging(content, status: FTLogStatus.init(rawValue: status.intValue)!,property: property)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_LOGGING_WITH_STATUS_STRING:
            if let content = context["content"] as? String, let status = context["status"] as? String {
                let property = context["property"] as? Dictionary<String, Any> ?? nil
                FTLogger.shared().log(content, status: status, property: property)
            }
            result(nil)

        case SwiftAgentPlugin.METHOD_TRACE_CONFIG:
            let traceConfig = FTTraceConfig()
            if let sampleRate = context["sampleRate"] as? NSNumber {
                traceConfig.samplerate = Int32(sampleRate.doubleValue * 100)
            }
            if let enableLinkRUMData = context["enableLinkRUMData"] as? Bool {
                traceConfig.enableLinkRumData = enableLinkRUMData
            }
            if let enableAutoTrace = context["enableNativeAutoTrace"] as? Bool {
                traceConfig.enableAutoTrace = enableAutoTrace
            }
            if let traceType = context["traceType"] as? NSNumber {
                traceConfig.networkTraceType = FTNetworkTraceType(rawValue: traceType.uintValue)!
            }
            FTMobileAgent.sharedInstance().startTrace(withConfigOptions: traceConfig)
#if FT_SDK_TESTING
            result(test("validateTrace:",context,traceConfig))
#else
            result(nil)
#endif
        case SwiftAgentPlugin.METHOD_GET_TRACE_HEADER:
            let urlStr = context["url"] as! String
            let key = context["key"] as? String
            if let url = URL.init(string: urlStr) {
                if(key != nil){
                    result(FTExternalDataManager.shared().getTraceHeader(withKey: key!, url: url))
                }else{
                    result(FTExternalDataManager.shared().getTraceHeader(with: url))
                }
            } else {
                result(nil)
            }
        case SwiftAgentPlugin.METHOD_RUM_CONFIG:
            if let rumAppId = context["rumAppId"] as? String {
                let rumConfig = FTRumConfig(appid: rumAppId)
                if let sampleRate = context["sampleRate"] as? NSNumber {
                    rumConfig.samplerate = Int32(sampleRate.doubleValue * 100)
                }
                if let sessionOnErrorSampleRate = context["sessionOnErrorSampleRate"] as? NSNumber {
                    rumConfig.sessionOnErrorSampleRate = Int32(sessionOnErrorSampleRate.doubleValue * 100)
                }
                if let enableUserAction = context["enableUserAction"] as? Bool {
                    rumConfig.enableTraceUserAction = enableUserAction
                }
                if let enableUserView = context["enableUserView"] as? Bool {
                    rumConfig.enableTraceUserView = enableUserView
                }
                if let enableUserResource = context["enableUserResource"] as? Bool {
                    rumConfig.enableTraceUserResource = enableUserResource
                }
                if let enableTrackNativeAppANR = context["enableTrackNativeAppANR"] as? Bool {
                    rumConfig.enableTrackAppANR = enableTrackNativeAppANR
                }
                if let enableTrackNativeCrash = context["enableTrackNativeCrash"] as? Bool {
                    rumConfig.enableTrackAppCrash = enableTrackNativeCrash
                }
                if let uiBlockDurationMS = context["nativeUiBlockDurationMS"] as? NSNumber {
                    rumConfig.freezeDurationMs = uiBlockDurationMS.intValue
                }
                if let enableAppUIBlock = context["enableAppUIBlock"] as? Bool {
                    rumConfig.enableTrackAppFreeze = enableAppUIBlock
                }
                if let monitorType = context["errorMonitorType"] as? NSNumber {
                    rumConfig.errorMonitorType =  FTErrorMonitorType(rawValue: monitorType.uintValue)
                }
                if let globalContext = context["globalContext"] as? Dictionary<String, String> {
                    rumConfig.globalContext = globalContext
                }
                if let deviceMetricsMonitorType = context["deviceMetricsMonitorType"] as? NSNumber {
                    rumConfig.deviceMetricsMonitorType = FTDeviceMetricsMonitorType(rawValue:deviceMetricsMonitorType.uintValue)
                }
                if let detectFrequency = context["detectFrequency"] as? NSNumber {
                    if  let monitorFrequency = FTMonitorFrequency(rawValue: detectFrequency.uintValue) {
                        rumConfig.monitorFrequency = monitorFrequency
                    }
                }

                if let rumCacheLimitCount = context["rumCacheLimitCount"] as? NSNumber {
                    rumConfig.rumCacheLimitCount = rumCacheLimitCount.int32Value
                }
                
                if let rumDiscardType = context["rumCacheDiscard"] as? NSNumber {
                    rumConfig.rumDiscardType = FTRUMCacheDiscard(rawValue: rumDiscardType.intValue) ?? .discard
                }

                if let enableTraceWebView = context["enableTraceWebView"] as? Bool {
                    rumConfig.enableTraceWebView = enableTraceWebView
                }
                
                if let allowWebViewHost = context["allowWebViewHost"] as? Array<String> {
                    rumConfig.allowWebViewHost = allowWebViewHost
                }
                if let enableResourceHostIP = context["enableResourceHostIP"] as? Bool {
                    rumConfig.enableResourceHostIP = enableResourceHostIP
                }
                if let iosCrashMonitoringType = context["iosCrashMonitoringType"] as? NSNumber {
                    rumConfig.crashMonitoring = FTCrashMonitorType(rawValue: iosCrashMonitoringType.uintValue)
                }

                FTMobileAgent.sharedInstance().startRum(withConfigOptions: rumConfig)
#if FT_SDK_TESTING
                result(test("validateRUM:",context,rumConfig))
#else
                result(nil)
#endif
                return
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_START_ACTION:
            let actionName = context["actionName"] as! String
            let actionType = context["actionType"] as! String
            let property = context["property"] as? Dictionary<String, Any> ?? nil
            FTExternalDataManager.shared().startAction(actionName, actionType: actionType,property: property)
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_ADD_ACTION:
            let actionName = context["actionName"] as! String
            let actionType = context["actionType"] as! String
            let property = context["property"] as? Dictionary<String, Any> ?? nil
            FTExternalDataManager.shared().addAction(actionName, actionType: actionType,property: property)
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_CREATE_VIEW:
            if let viewName = context["viewName"] as? String {
                let loadDuration = context["duration"] as? NSNumber ?? NSNumber(value: -1)
                FTExternalDataManager.shared().onCreateView(viewName, loadTime: loadDuration)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_START_VIEW:
            if let viewName = context["viewName"] as? String {
                let property = context["property"] as? Dictionary<String, Any> ?? nil
                FTExternalDataManager.shared().startView(withName: viewName,property: property)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_STOP_VIEW:
            let property = context["property"] as? Dictionary<String, Any> ?? nil
            FTExternalDataManager.shared().stopView(withProperty: property)
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_ADD_ERROR:
            let stack = context["stack"] as? String ?? ""
            let message = context["message"] as? String ?? ""
            var errorType = context["errorType"] as? String ?? ""
            let property = context["property"] as? Dictionary<String, Any> ?? nil
            
            if(errorType.isEmpty){
                errorType = "flutter_crash"
            }
            
            FTExternalDataManager.shared().addError(withType: errorType, message: message, stack: stack,property: property)
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_START_RESOURCE:
            let key = context["key"] as! String
            let property = context["property"] as? Dictionary<String, Any> ?? nil
            FTExternalDataManager.shared().startResource(withKey: key,property: property)
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_ADD_RESOURCE:
            let key = context["key"] as! String
            let urlStr = context["url"] as! String
            let resourceMethod = context["resourceMethod"] as! String
            let requestHeader = context["requestHeader"] as! Dictionary<String, Any>

            if let url = URL.init(string: urlStr) {
                let content = FTResourceContentModel.init()
                content.url = url
                content.httpMethod = resourceMethod
                content.requestHeader = requestHeader
                if let responseHeader = context["responseHeader"] as? Dictionary<String, Any> {
                    content.responseHeader = responseHeader
                }
                if let responseBody = context["responseBody"] as? String {
                    content.responseBody = responseBody
                }
                if let resourceStatus = context["resourceStatus"] as? NSNumber {
                    content.httpStatusCode = resourceStatus.intValue
                }
                var metrics: FTResourceMetricsModel? = nil
                if let metricsContext = context["metrics"] as? Dictionary<String, Any>, !metricsContext.isEmpty {
                    metrics = FTResourceMetricsModel.init()
                    if let duration = metricsContext["duration"] as? NSNumber { metrics?.duration = duration }
                    if let dns = metricsContext["resource_dns"] as? NSNumber { metrics?.resource_dns = dns }
                    if let tcp = metricsContext["resource_tcp"] as? NSNumber { metrics?.resource_tcp = tcp }
                    if let ssl = metricsContext["resource_ssl"] as? NSNumber { metrics?.resource_ssl = ssl }
                    if let ttfb = metricsContext["resource_ttfb"] as? NSNumber { metrics?.resource_ttfb = ttfb }
                    if let trans = metricsContext["resource_trans"] as? NSNumber { metrics?.resource_trans = trans }
                    if let firstByte = metricsContext["resource_first_byte"] as? NSNumber { metrics?.resource_first_byte = firstByte }
                }
                if let resourceSize = context["resourceSize"] as? NSNumber {
                    if metrics == nil { metrics = FTResourceMetricsModel.init() }
                    metrics?.responseSize = resourceSize
                }

                FTExternalDataManager.shared().addResource(withKey: key, metrics: metrics, content: content)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_STOP_RESOURCE:
            let key = context["key"] as! String
            let property = context["property"] as? Dictionary<String, Any> ?? nil
            FTExternalDataManager.shared().stopResource(withKey: key,property: property)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }


    private func updateRemoteConfig(interval: Int, rules: [[String: Any]]?, result: @escaping FlutterResult) {
        if !remoteConfigurationEnabled {
            result(remoteConfigResult(triggerType: "manual", success: false, content: nil, errorCode: "remote_configuration_disabled", errorMessage: "Remote configuration is not enabled", appliedRuleIds: nil))
            return
        }
        FTMobileAgent.updateRemoteConfig(withMiniUpdateInterval: interval) { [weak self] success, error, model, content in
            guard let self = self else { return model }
            let overrideResult = self.applyRemoteConfigOverrideRules(model: model, content: content, rules: rules)
            result(self.remoteConfigResult(triggerType: "manual", success: success, content: content, error: error, appliedRuleIds: overrideResult.appliedRuleIds))
            return overrideResult.model
        }
    }

    private func emitRemoteConfigResult(_ payload: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            self?.channel?.invokeMethod(SwiftAgentPlugin.METHOD_REMOTE_CONFIG_CALLBACK, arguments: payload)
        }
    }

    private func remoteConfigResult(triggerType: String, success: Bool, content: [String: Any]?, error: Error?, appliedRuleIds: [String]?) -> [String: Any] {
        return remoteConfigResult(triggerType: triggerType, success: success, content: content, errorCode: (error as NSError?)?.code.description, errorMessage: error?.localizedDescription, appliedRuleIds: appliedRuleIds)
    }

    private func remoteConfigResult(triggerType: String, success: Bool, content: [String: Any]?, errorCode: String?, errorMessage: String?, appliedRuleIds: [String]?) -> [String: Any] {
        var payload: [String: Any] = [
            "triggerType": triggerType,
            "success": success,
            "platform": "ios",
            "timestamp": Int(Date().timeIntervalSince1970 * 1000)
        ]
        if let content = content,
           let data = try? JSONSerialization.data(withJSONObject: content, options: []),
           let json = String(data: data, encoding: .utf8) {
            payload["rawJson"] = json
        }
        if let appliedRuleIds = appliedRuleIds, !appliedRuleIds.isEmpty {
            payload["appliedOverrideRuleIds"] = appliedRuleIds
        }
        if let errorCode = errorCode { payload["errorCode"] = errorCode }
        if let errorMessage = errorMessage { payload["errorMessage"] = errorMessage }
        return payload
    }

    private func applyRemoteConfigOverrideRules(model: FTRemoteConfigModel?, content: [String: Any]?, rules: [[String: Any]]?) -> (model: FTRemoteConfigModel?, appliedRuleIds: [String]) {
        guard let model = model, let content = content, let rules = rules, !rules.isEmpty else {
            return (model, [])
        }
        var appliedIds: [String] = []
        for rule in rules {
            let enabled = rule["enabled"] as? Bool ?? true
            if !enabled { continue }
            guard let match = rule["match"] as? [String: Any],
                  let customKeys = match["customKeys"] as? [String: Any],
                  matchesCustomKeys(content: content, customKeys: customKeys),
                  let override = rule["override"] as? [String: Any] else { continue }
            applyRemoteConfigOverride(model: model, override: override)
            if let id = rule["id"] as? String { appliedIds.append(id) }
        }
        return (model, appliedIds)
    }

    private func matchesCustomKeys(content: [String: Any], customKeys: [String: Any]) -> Bool {
        for (key, expected) in customKeys {
            guard let actualValue = content[key] else { return false }
            let actual = "\(actualValue)"
            if let expectedMap = expected as? [String: Any], let contains = expectedMap["contains"] {
                if !actual.contains("\(contains)") { return false }
            } else if actual != "\(expected)" {
                return false
            }
        }
        return true
    }

    private func applyRemoteConfigOverride(model: FTRemoteConfigModel, override: [String: Any]) {
        if let value = override["env"] as? String { model.env = value }
        if let value = override["serviceName"] as? String { model.serviceName = value }
        if let value = override["autoSync"] as? Bool { model.autoSync = NSNumber(value: value) }
        if let value = override["compressIntakeRequests"] as? Bool { model.compressIntakeRequests = NSNumber(value: value) }
        if let value = override["syncPageSize"] as? NSNumber { model.syncPageSize = value }
        if let value = override["syncSleepTime"] as? NSNumber { model.syncSleepTime = value }
        if let value = override["rumSampleRate"] as? NSNumber { model.rumSampleRate = value }
        if let value = override["rumSessionOnErrorSampleRate"] as? NSNumber { model.rumSessionOnErrorSampleRate = value }
        if let value = override["rumEnableTraceUserAction"] as? Bool { model.rumEnableTraceUserAction = NSNumber(value: value) }
        if let value = override["rumEnableTraceUserView"] as? Bool { model.rumEnableTraceUserView = NSNumber(value: value) }
        if let value = override["rumEnableTraceUserResource"] as? Bool { model.rumEnableTraceUserResource = NSNumber(value: value) }
        if let value = override["rumEnableResourceHostIP"] as? Bool { model.rumEnableResourceHostIP = NSNumber(value: value) }
        if let value = override["rumEnableTrackAppUIBlock"] as? Bool { model.rumEnableTrackAppUIBlock = NSNumber(value: value) }
        if let value = override["rumBlockDurationMs"] as? NSNumber { model.rumBlockDurationMs = value }
        if let value = override["rumEnableTrackAppCrash"] as? Bool { model.rumEnableTrackAppCrash = NSNumber(value: value) }
        if let value = override["rumEnableTrackAppANR"] as? Bool { model.rumEnableTrackAppANR = NSNumber(value: value) }
        if let value = override["rumEnableTraceWebView"] as? Bool { model.rumEnableTraceWebView = NSNumber(value: value) }
        if let value = override["rumAllowWebViewHost"] as? [String] { model.rumAllowWebViewHost = value }
        if let value = override["traceSampleRate"] as? NSNumber { model.traceSampleRate = value }
        if let value = override["traceEnableAutoTrace"] as? Bool { model.traceEnableAutoTrace = NSNumber(value: value) }
        if let value = override["traceType"] as? String { model.traceType = value }
        if let value = override["logSampleRate"] as? NSNumber { model.logSampleRate = value }
        if let value = override["logLevelFilters"] as? [String] { model.logLevelFilters = value }
        if let value = override["logEnableCustomLog"] as? Bool { model.logEnableCustomLog = NSNumber(value: value) }
    }
#if FT_SDK_TESTING
    func test(_ selectorName:String,_ context:[String:Any],_ config:Any)->Bool{
        if let validatorClass = NSClassFromString("FTTest.FTTypeValidator") as? NSObject.Type {
            let selector = NSSelectorFromString(selectorName)
            if validatorClass.responds(to: selector) {
                let param:[String : Any] = ["context":context,"config":config]
                let res = validatorClass.perform(selector, with: param)?
                    .takeUnretainedValue()
                if let res = res as? Bool {
                    return res
                }
            }
        }
        return false
    }
#endif

}
