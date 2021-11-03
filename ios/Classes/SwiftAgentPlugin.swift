import Flutter
import UIKit
import FTMobileSDK

public class SwiftAgentPlugin: NSObject, FlutterPlugin {

    static let METHOD_CONFIG = "ftConfig"


    static let METHOD_BIND_USER = "ftBindUser"
    static let METHOD_UNBIND_USER = "ftUnBindUser"

    static let METHOD_LOG_CONFIG = "ftLogConfig"
    static let METHOD_LOGGING = "ftLogging"

    static let METHOD_RUM_CONFIG = "ftRumConfig"
    static let METHOD_RUM_ADD_ACTION = "ftRumAddAction"
    static let METHOD_RUM_START_VIEW = "ftRumStartView"
    static let METHOD_RUM_STOP_VIEW = "ftRumStopView"
    static let METHOD_RUM_ADD_ERROR = "ftRumAddError"
    static let METHOD_RUM_START_RESOURCE = "ftRumStartResource"
    static let METHOD_RUM_STOP_RESOURCE = "ftRumStopResource"
    static let METHOD_RUM_RESOURCE_CONTENT = "ftRumResourceContent"

    static let METHOD_TRACE_CONFIG = "ftTraceConfig"
    static let METHOD_TRACE = "ftTrace"
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

        if (call.method == SwiftAgentPlugin.METHOD_CONFIG) {
            let metricsUrl = args["metricsUrl"] as! String
            let debug = args["debug"] as? Bool
            let datakitUUID = args["datakitUUID"] as? String
            let env = args["env"] as? Int

            let config: FTMobileConfig = FTMobileConfig(metricsUrl: metricsUrl)
            if (debug ?? false) {
                config.enableSDKDebugLog = debug!
            }
            if (datakitUUID != nil) {
                config.xDataKitUUID = datakitUUID!
            }

            if (env != nil) {
                let entType: FTEnv? = FTEnv.init(rawValue: env!)
                config.env = entType!
            }

            FTMobileAgent.start(withConfigOptions: config)
            result(nil)
        } else if (call.method == SwiftAgentPlugin.METHOD_LOGGING) {
            let content = args["content"] as! String
            let status = args["status"] as! Int
            FTMobileAgent.sharedInstance().logging(content, status: FTStatus.init(rawValue: status)!)
            result(nil)
        } else if (call.method == SwiftAgentPlugin.METHOD_RUM_CONFIG) {
            let rumAppId = args["rumAppId"] as! String
            let sampleRate = args["sampleRate"] as? Float
            let enableUserAction = args["enableUserAction"] as? Bool
            let monitorType = args["monitorType"] as? Int

            let rumConfig = FTRumConfig(appid: rumAppId)
            if (sampleRate != nil) {
                rumConfig.samplerate = Int32(Int(sampleRate! * 100))
            }
            if (enableUserAction != nil) {
                rumConfig.enableTraceUserAction = enableUserAction!
            }
            if (monitorType != nil) {
                rumConfig.monitorInfoType = FTMonitorInfoType.init(rawValue: UInt(monitorType!))
            }
            FTMobileAgent.sharedInstance().startRum(withConfigOptions: rumConfig)
            result(nil)

        } else if (call.method == SwiftAgentPlugin.METHOD_RUM_ADD_ACTION) {
            let actionName = args["actionName"] as! String
            FTMonitorManager.sharedInstance().rumManger.addClickAction(withName: actionName)
        } else if (call.method == SwiftAgentPlugin.METHOD_RUM_START_VIEW) {
            let viewName = args["viewName"] as! String
            let viewReferrer = args["viewReferrer"] as! String
            let loadDuration = args["loadDuration"] as! Int
            FTMonitorManager.sharedInstance().rumManger.startView(withName: viewName, viewReferrer: viewReferrer, loadDuration: NSNumber.init(value: loadDuration))

        } else if (call.method == SwiftAgentPlugin.METHOD_RUM_STOP_VIEW) {
            FTMonitorManager.sharedInstance().rumManger.stopView()
        } else if (call.method == SwiftAgentPlugin.METHOD_RUM_ADD_ERROR) {
            let stack = args["stack"] as! String
            let message = args["message"] as! String
            let appState = args["appState"] as! Int
            FTMonitorManager.sharedInstance().rumManger.addError(withType: "flutter", situation: "", message: message, stack: stack)
        } else if (call.method == SwiftAgentPlugin.METHOD_RUM_START_RESOURCE) {

        } else if (call.method == SwiftAgentPlugin.METHOD_RUM_STOP_RESOURCE) {

        } else if (call.method == SwiftAgentPlugin.METHOD_LOG_CONFIG) {
            let sampleRate = args["sampleRate"] as? Float
            let serviceName = args["serviceName"] as? String
            let logTypeArr = args["logType"] as? [Int]
            let enableLinkRumData = args["enableLinkRumData"] as? Bool
            let enableCustomLog = args["enableCustomLog"] as? Bool
            let logCacheDiscardType = args["logCacheDiscard"] as? Int

            let logConfig = FTLoggerConfig()

            if (logCacheDiscardType != nil) {
                let logCacheDiscard = FTLogCacheDiscard.init(rawValue: logCacheDiscardType!)
                logConfig.discardType = logCacheDiscard!
            }

            if (sampleRate != nil) {
                logConfig.samplerate = Int32(Int(sampleRate! * 100))
            }
            if (serviceName != nil) {
                logConfig.service = serviceName!
            }
            if (logTypeArr != nil) {
                logConfig.logLevelFilter = logTypeArr!.map { number in
                    NSNumber.init(integerLiteral: number)
                }
            }
            if (enableLinkRumData != nil) {
                logConfig.enableLinkRumData = enableLinkRumData!
            }
            if (enableCustomLog != nil) {
                logConfig.enableCustomLog = enableCustomLog!;
            }

            FTMobileAgent.sharedInstance().startLogger(withConfigOptions: logConfig)

            result(nil)

        } else if (call.method == SwiftAgentPlugin.METHOD_TRACE_CONFIG) {
            let sampleRate = args["sampleRate"] as? Float
            let traceType = args["traceType"] as? Int
            let enableLinkRUMData = args["enableLinkRUMData"] as? Bool

            let traceConfig = FTTraceConfig()
            traceConfig.samplerate = Int32(Int(sampleRate! * 100))
            if (enableLinkRUMData != nil) {
                traceConfig.enableLinkRumData = enableLinkRUMData!
            }
            traceConfig.networkTraceType = FTNetworkTraceType.init(rawValue: traceType!)!
            FTMobileAgent.sharedInstance().startTrace(withConfigOptions: traceConfig)
            result(nil)
        } else if (call.method == SwiftAgentPlugin.METHOD_TRACE) {
            result(nil)
        } else if (call.method == SwiftAgentPlugin.METHOD_GET_TRACE_HEADER) {

            result(nil)
        } else if (call.method == SwiftAgentPlugin.METHOD_BIND_USER) {
            let userId = args["userId"] as? String
            FTMobileAgent.sharedInstance().bindUser(withUserID: userId!)

        } else if (call.method == SwiftAgentPlugin.METHOD_UNBIND_USER) {
            FTMobileAgent.sharedInstance().logout()
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

}
