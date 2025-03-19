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
        var args = Dictionary<String, Any>()
        if (call.arguments is Dictionary<String, Any>) {
            args = call.arguments as! Dictionary<String, Any>
        }
        switch call.method {
        case SwiftAgentPlugin.METHOD_CONFIG:
            let datakitUrl = args["datakitUrl"] as? String
            let datawayUrl = args["datawayUrl"] as? String
            let cliToken = args["cliToken"] as? String
            let config: FTMobileConfig
            if let datakitUrl = datakitUrl {
                config = FTMobileConfig(datakitUrl: datakitUrl)
            } else  {
                config = FTMobileConfig(datawayUrl: datawayUrl!, clientToken: cliToken!)
            }
            
            
            if let debug = args["debug"] as? Bool {
                config.enableSDKDebugLog = debug
            }
            if let env = args["env"] as? String {
                config.env = env
            }
            if let serviceName = args["serviceName"] as? String {
                config.service = serviceName
            }
            if let globalContext = args["globalContext"] as? Dictionary<String, String> {
                config.globalContext = globalContext
            }
            if let groupIdentifiers = args["groupIdentifiers"] as? Array<String>{
                config.groupIdentifiers = groupIdentifiers
            }
            
            if let autoSync = args["autoSync"] as? Bool{
                config.autoSync = autoSync
            }
            
            if let syncPageSize = args["syncPageSize"] as? Int{
                config.setSyncPageSizeWithType(FTSyncPageSize.init(rawValue: UInt(syncPageSize))!)
            }
            
            if let customSyncPageSize = args["customSyncPageSize"] as? Int{
                config.syncPageSize = Int32(customSyncPageSize)
            }
            
            if let syncSleepTime = args["syncSleepTime"] as? Int{
                config.syncSleepTime = Int32(syncSleepTime)
            }

            if let compressIntakeRequests = args["compressIntakeRequests"] as? Bool{
               config.compressIntakeRequests = compressIntakeRequests
            }

             if let enableDataIntegerCompatible = args["enableDataIntegerCompatible"] as? Bool{
               config.enableDataIntegerCompatible = enableDataIntegerCompatible
             }

            if let dbCacheDiscardType = args["dbCacheDiscard"] as? Int {
                let dbCacheDiscard = FTDBCacheDiscard.init(rawValue: dbCacheDiscardType)
                config.dbDiscardType = dbCacheDiscard ?? FTDBCacheDiscard.discard
            }
            
            if let enableLimitWithDbSize = args["enableLimitWithDbSize"] as? Bool{
                config.enableLimitWithDbSize = enableLimitWithDbSize
            }
            
            if let dbCacheLimit = args["dbCacheLimit"] as? Int{
                config.dbCacheLimit = dbCacheLimit
            }
            
            if let pkgInfo = args["pkgInfo"] as? String {
                config.addPkgInfo("flutter", value: pkgInfo)
            }

            FTMobileAgent.start(withConfigOptions: config)
            result(nil)
        case SwiftAgentPlugin.METHOD_FLUSH_SYNC_DATA:
            FTMobileAgent.sharedInstance().flushSyncData()
            result(nil)
        case SwiftAgentPlugin.METHOD_BIND_USER:
            if let userId = args["userId"] as? String {
                let userName = args["userName"] as? String
                let userEmail = args["userEmail"] as? String
                let userExt = args["userExt"] as? [AnyHashable: Any]
                FTMobileAgent.sharedInstance().bindUser(withUserID: userId, userName: userName, userEmail: userEmail, extra: userExt)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_UNBIND_USER:
            FTMobileAgent.sharedInstance().unbindUser()
            result(nil)
        case SwiftAgentPlugin.METHOD_TRACK_EVENT_FROM_EXTENSION:
            if let groupIdentifier = args["groupIdentifier"] as? String{
                FTMobileAgent.sharedInstance().trackEventFromExtension(withGroupIdentifier: groupIdentifier) { groupId, datas in
                    result(["groupIdentifier":groupId,"datas":datas] as [String : Any])
                }
            }

        case SwiftAgentPlugin.METHOD_APPEND_GLOBAL_CONTEXT:
            if let globalContext = args["globalContext"] as? Dictionary<String, Any> {
                FTMobileAgent.appendGlobalContext(globalContext)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_APPEND_LOG_GLOBAL_CONTEXT:
            if let globalContext = args["globalContext"] as? Dictionary<String, Any> {
                FTMobileAgent.appendGlobalContext(globalContext)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_APPEND_RUM_GLOBAL_CONTEXT:
            if let globalContext = args["globalContext"] as? Dictionary<String, Any> {
                FTMobileAgent.appendGlobalContext(globalContext)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_CLEAR_ALL_DATA:
            FTMobileAgent.clearAllData()
            result(nil)
        case SwiftAgentPlugin.METHOD_LOG_CONFIG:

            let logConfig = FTLoggerConfig()
            if let logCacheDiscardType = args["logCacheDiscard"] as? Int {
                let logCacheDiscard = FTLogCacheDiscard.init(rawValue: logCacheDiscardType)
                logConfig.discardType = logCacheDiscard ?? FTLogCacheDiscard.discard
            }

            if let sampleRate = args["sampleRate"] as? Float {
                logConfig.samplerate = Int32(Int(sampleRate * 100))
            }
            if let logTypeArr = args["logType"] as? [Int] {
                logConfig.logLevelFilter = logTypeArr.map { number in
                    NSNumber.init(integerLiteral: number)
                }
            }
            if let enableLinkRumData = args["enableLinkRumData"] as? Bool {
                logConfig.enableLinkRumData = enableLinkRumData
            }
            if let enableCustomLog = args["enableCustomLog"] as? Bool {
                logConfig.enableCustomLog = enableCustomLog
            }
            if let printCustomLogToConsole = args["printCustomLogToConsole"] as? Bool {
                logConfig.printCustomLogToConsole = printCustomLogToConsole
            }
            
            if let logCacheLimitCount = args["logCacheLimitCount"] as? Int {
                logConfig.logCacheLimitCount = Int32(logCacheLimitCount)
            }
            
            if let globalContext = args["globalContext"] as? Dictionary<String, String> {
                logConfig.globalContext = globalContext
            }
            FTMobileAgent.sharedInstance().startLogger(withConfigOptions: logConfig)

            result(nil)
        case SwiftAgentPlugin.METHOD_LOGGING:
            if let content = args["content"] as? String {
                let status = args["status"] as? Int ?? 0
                let property = args["property"] as? Dictionary<String, Any> ?? nil
                FTMobileAgent.sharedInstance().logging(content, status: FTLogStatus.init(rawValue: status)!,property: property)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_TRACE_CONFIG:
            let traceConfig = FTTraceConfig()
            if let sampleRate = args["sampleRate"] as? Float {
                traceConfig.samplerate = Int32(Int(sampleRate * 100))
            }
            if let enableLinkRUMData = args["enableLinkRUMData"] as? Bool {
                traceConfig.enableLinkRumData = enableLinkRUMData
            }
            if let enableAutoTrace = args["enableNativeAutoTrace"] as? Bool {
                traceConfig.enableAutoTrace = enableAutoTrace
            }
            if let traceType = args["traceType"] as? Int {
                traceConfig.networkTraceType = FTNetworkTraceType.init(rawValue: UInt(traceType))!
            }
            FTMobileAgent.sharedInstance().startTrace(withConfigOptions: traceConfig)
            result(nil)
        case SwiftAgentPlugin.METHOD_GET_TRACE_HEADER:
            let urlStr = args["url"] as! String
            let key = args["key"] as? String
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
            if let rumAppId = args["rumAppId"] as? String {
                let rumConfig = FTRumConfig(appid: rumAppId)
                if let sampleRate = args["sampleRate"] as? Float {
                    rumConfig.samplerate = Int32(Int(sampleRate * 100))
                }
                if let enableUserAction = args["enableUserAction"] as? Bool {
                    rumConfig.enableTraceUserAction = enableUserAction
                }
                if let enableUserView = args["enableUserView"] as? Bool {
                    rumConfig.enableTraceUserView = enableUserView
                }
                if let enableUserResource = args["enableUserResource"] as? Bool {
                    rumConfig.enableTraceUserResource = enableUserResource
                }
                if let enableTrackNativeAppANR = args["enableTrackNativeAppANR"] as? Bool {
                    rumConfig.enableTrackAppANR = enableTrackNativeAppANR
                }
                if let enableTrackNativeCrash = args["enableTrackNativeCrash"] as? Bool {
                    rumConfig.enableTrackAppCrash = enableTrackNativeCrash
                }
                if let uiBlockDurationMS = args["nativeUiBlockDurationMS"] as? Int {
                    rumConfig.freezeDurationMs = uiBlockDurationMS
                }
                if let enableAppUIBlock = args["enableAppUIBlock"] as? Bool {
                    rumConfig.enableTrackAppFreeze = enableAppUIBlock
                }
                if let monitorType = args["errorMonitorType"] as? Int {
                    rumConfig.errorMonitorType =  FTErrorMonitorType.init(rawValue: UInt(monitorType))
                }
                if let globalContext = args["globalContext"] as? Dictionary<String, String> {
                    rumConfig.globalContext = globalContext
                }
                if let deviceMetricsMonitorType = args["deviceMetricsMonitorType"] as? Int {
                     rumConfig.deviceMetricsMonitorType = FTDeviceMetricsMonitorType(rawValue:UInt(deviceMetricsMonitorType))
                }
                if let detectFrequency = args["detectFrequency"] as? Int {
                    rumConfig.monitorFrequency = FTMonitorFrequency.init(rawValue: UInt(detectFrequency))!
                }

                if let rumCacheLimitCount = args["rumCacheLimitCount"] as? Int {
                    rumConfig.rumCacheLimitCount = Int32(rumCacheLimitCount)
                }
                
                if let rumDiscardType = args["rumCacheDiscard"] as? Int {
                    let rumCacheDiscard = FTRUMCacheDiscard.init(rawValue: rumDiscardType)
                    rumConfig.rumDiscardType = rumCacheDiscard ?? FTRUMCacheDiscard.discard
                }
                FTMobileAgent.sharedInstance().startRum(withConfigOptions: rumConfig)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_ADD_ACTION:
            let actionName = args["actionName"] as! String
            let actionType = args["actionType"] as! String
            let property = args["property"] as? Dictionary<String, Any> ?? nil
            FTExternalDataManager.shared().addActionName(actionName, actionType: actionType,property: property)
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_CREATE_VIEW:
            if let viewName = args["viewName"] as? String {
                let loadDuration = args["duration"] as? Int ?? -1
                FTExternalDataManager.shared().onCreateView(viewName, loadTime: NSNumber.init(value: loadDuration))
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_START_VIEW:
            if let viewName = args["viewName"] as? String {
                let property = args["property"] as? Dictionary<String, Any> ?? nil
                FTExternalDataManager.shared().startView(withName: viewName,property: property)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_STOP_VIEW:
            let property = args["property"] as? Dictionary<String, Any> ?? nil
            FTExternalDataManager.shared().stopView(withProperty: property)
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_ADD_ERROR:
            let stack = args["stack"] as? String ?? ""
            let message = args["message"] as? String ?? ""
            var errorType = args["errorType"] as? String ?? ""
            let property = args["property"] as? Dictionary<String, Any> ?? nil
            
            if(errorType.isEmpty){
                errorType = "flutter_crash"
            }
            
            FTExternalDataManager.shared().addError(withType: errorType, message: message, stack: stack,property: property)
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_START_RESOURCE:
            let key = args["key"] as! String
            let property = args["property"] as? Dictionary<String, Any> ?? nil
            FTExternalDataManager.shared().startResource(withKey: key,property: property)
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_ADD_RESOURCE:
            let key = args["key"] as! String
            let urlStr = args["url"] as! String
            let resourceMethod = args["resourceMethod"] as! String
            let requestHeader = args["requestHeader"] as! Dictionary<String, Any>

            if let url = URL.init(string: urlStr) {
                let content = FTResourceContentModel.init()
                content.url = url
                content.httpMethod = resourceMethod
                content.requestHeader = requestHeader
                if let responseHeader = args["responseHeader"] as? Dictionary<String, Any> {
                    content.responseHeader = responseHeader
                }
                if let responseBody = args["responseBody"] as? String {
                    content.responseBody = responseBody
                }
                if let resourceStatus = args["resourceStatus"] as? Int {
                    content.httpStatusCode = resourceStatus
                }
                let metrics = FTResourceMetricsModel.init()
                if let resourceSize = args["resourceSize"] as? Int {
                    metrics.responseSize = NSNumber.init(value: resourceSize)
                }

                FTExternalDataManager.shared().addResource(withKey: key, metrics: nil, content: content)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_STOP_RESOURCE:
            let key = args["key"] as! String
            let property = args["property"] as? Dictionary<String, Any> ?? nil
            FTExternalDataManager.shared().stopResource(withKey: key,property: property)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

}
