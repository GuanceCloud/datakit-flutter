import Flutter
import UIKit
import FTMobileSDK

public class SwiftAgentPlugin: NSObject, FlutterPlugin {

    static let METHOD_CONFIG = "ftConfig"


    static let METHOD_BIND_USER = "ftBindUser"
    static let METHOD_UNBIND_USER = "ftUnBindUser"
    static let METHOD_TRACK_EVENT_FROM_EXTENSION = "ftTrackEventFromExtension"

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
            if let metricsUrl = args["metricsUrl"] {
                let config: FTMobileConfig = FTMobileConfig(metricsUrl: metricsUrl as! String)
                if let debug = args["debug"] as? Bool {
                    config.enableSDKDebugLog = debug
                }
                if let datakitUUID = args["datakitUUID"] as? String {
                    config.xDataKitUUID = datakitUUID
                }
                if let env = args["env"] as? Int {
                    let entType: FTEnv? = FTEnv.init(rawValue: env)
                    config.env = entType ?? .prod
                }
                if let globalContext = args["globalContext"] as? Dictionary<String, String> {
                    config.globalContext = globalContext
                }
                if let groupIdentifiers = args["groupIdentifiers"] as? Array<String>{
                    config.groupIdentifiers = groupIdentifiers
                }
                FTMobileAgent.start(withConfigOptions: config)
            }

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
            FTMobileAgent.sharedInstance().logout()
            result(nil)
        case SwiftAgentPlugin.METHOD_TRACK_EVENT_FROM_EXTENSION:
            if let groupIdentifier = args["groupIdentifier"] as? String{
                FTMobileAgent.sharedInstance().trackEventFromExtension(withGroupIdentifier: groupIdentifier) { groupId, datas in
                    result(["groupIdentifier":groupId,"datas":datas])
                }
            }
        case SwiftAgentPlugin.METHOD_LOG_CONFIG:

            let logConfig = FTLoggerConfig()
            if let logCacheDiscardType = args["logCacheDiscard"] as? Int {
                let logCacheDiscard = FTLogCacheDiscard.init(rawValue: logCacheDiscardType)
                logConfig.discardType = logCacheDiscard ?? FTLogCacheDiscard.discard
            }

            if let sampleRate = args["sampleRate"] as? Float {
                logConfig.samplerate = Int32(Int(sampleRate * 100))
            }
            if let serviceName = args["serviceName"] as? String {
                logConfig.service = serviceName
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
            if let globalContext = args["globalContext"] as? Dictionary<String, String> {
                logConfig.globalContext = globalContext
            }
            FTMobileAgent.sharedInstance().startLogger(withConfigOptions: logConfig)

            result(nil)
        case SwiftAgentPlugin.METHOD_LOGGING:
            if let content = args["content"] as? String {
                let status = args["status"] as? Int ?? 0
                FTMobileAgent.sharedInstance().logging(content, status: FTLogStatus.init(rawValue: status)!)
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
                traceConfig.networkTraceType = FTNetworkTraceType.init(rawValue: traceType)!
            }
            FTMobileAgent.sharedInstance().startTrace(withConfigOptions: traceConfig)
            result(nil)
        case SwiftAgentPlugin.METHOD_GET_TRACE_HEADER:
            let urlStr = args["url"] as! String
            let key = args["key"] as! String
            if let url = URL.init(string: urlStr) {
                let header = FTExternalDataManager.shared().getTraceHeader(withKey: key, url: url)
                result(header)
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
                FTMobileAgent.sharedInstance().startRum(withConfigOptions: rumConfig)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_ADD_ACTION:
            let actionName = args["actionName"] as! String
            let actionType = args["actionType"] as! String
            FTExternalDataManager.shared().addActionName(actionName, actionType: actionType)
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_CREATE_VIEW:
            if let viewName = args["viewName"] as? String {
                let loadDuration = args["duration"] as? Int ?? -1
                FTExternalDataManager.shared().onCreateView(viewName, loadTime: NSNumber.init(value: loadDuration))
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_START_VIEW:
            if let viewName = args["viewName"] as? String {
                FTExternalDataManager.shared().startView(withName: viewName)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_STOP_VIEW:
            FTExternalDataManager.shared().stopView()
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_ADD_ERROR:
            let stack = args["stack"] as? String ?? ""
            let message = args["message"] as? String ?? ""
            FTExternalDataManager.shared().addError(withType: "flutter", message: message, stack: stack)
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_START_RESOURCE:
            let key = args["key"] as! String
            FTExternalDataManager.shared().startResource(withKey: key)
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

                FTExternalDataManager.shared().addResource(withKey: key, metrics: nil, content: content)
            }
            result(nil)
        case SwiftAgentPlugin.METHOD_RUM_STOP_RESOURCE:
            let key = args["key"] as! String
            FTExternalDataManager.shared().stopResource(withKey: key)
            result(nil)
        default:
            result(FlutterMethodNotImplemented);
        }
    }

}
