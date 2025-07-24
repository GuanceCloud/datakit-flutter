import Flutter
import UIKit
import FTMobileSDK

public class SwiftAgentPlugin: NSObject, FlutterPlugin {

    static let METHOD_CONFIG = "ftConfig"
    static let METHOD_FLUSH_SYNC_DATA = "ftFlushSyncData"

    static let METHOD_BIND_USER = "ftBindUser"
    static let METHOD_UNBIND_USER = "ftUnBindUser"
    static let METHOD_TRACK_EVENT_FROM_EXTENSION = "ftTrackEventFromExtension"

    static let METHOD_APPEND_GLOBAL_CONTEXT = "ftAppendGlobalContext"
    static let METHOD_APPEND_RUM_GLOBAL_CONTEXT = "ftAppendRUMGlobalContext"
    static let METHOD_APPEND_LOG_GLOBAL_CONTEXT = "ftAppendLogGlobalContext"
    
    static let METHOD_CLEAR_ALL_DATA = "ftClearAllData"

    static let METHOD_LOG_CONFIG = "ftLogConfig"
    static let METHOD_LOGGING = "ftLogging"

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

            if let pkgInfo = context["pkgInfo"] as? String {
                config.addPkgInfo("flutter", value: pkgInfo)
            }

            FTMobileAgent.start(withConfigOptions: config)
#if FT_SDK_TESTING
            result(test("validateBase:",context,config))
            return
#endif
            result(nil)
        case SwiftAgentPlugin.METHOD_FLUSH_SYNC_DATA:
            FTMobileAgent.sharedInstance().flushSyncData()
            result(nil)
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
            return
#endif
            result(nil)
        case SwiftAgentPlugin.METHOD_LOGGING:
            if let content = context["content"] as? String {
                let status = context["status"] as? NSNumber ?? NSNumber(value: 0)
                let property = context["property"] as? Dictionary<String, Any> ?? nil
                FTMobileAgent.sharedInstance().logging(content, status: FTLogStatus.init(rawValue: status.intValue)!,property: property)
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
            return
#endif
            result(nil)
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

                FTMobileAgent.sharedInstance().startRum(withConfigOptions: rumConfig)
#if FT_SDK_TESTING
                result(test("validateRUM:",context,rumConfig))
                return
#endif
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
                let metrics = FTResourceMetricsModel.init()
                if let resourceSize = context["resourceSize"] as? NSNumber {
                    metrics.responseSize = resourceSize
                }

                FTExternalDataManager.shared().addResource(withKey: key, metrics: nil, content: content)
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
