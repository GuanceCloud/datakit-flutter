import Flutter
import UIKit
import FTMobileSDK

public class SwiftAgentPlugin: NSObject, FlutterPlugin {

    static let METHOD_CONFIG = "ftConfig"
    static let METHOD_LOGGING = "ftLogging"


    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ft_mobile_agent_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftAgentPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }


    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        var args = Dictionary<String,Any>()
        if(call.arguments is Dictionary<String, Any>){
            args = call.arguments as! Dictionary<String, Any>
        }
        
        if (call.method == SwiftAgentPlugin.METHOD_CONFIG) {
            let config: FTMobileConfig = FTMobileConfig(metricsUrl: args["metricsUrl"] as! String)
            config.enableSDKDebugLog = true
            FTMobileAgent.start(withConfigOptions: config)
            result(nil)
        } else if (call.method == SwiftAgentPlugin.METHOD_LOGGING) {
            let content = args["content"] as! String
            let status = args["status"] as! Int
            
            FTMobileAgent.sharedInstance().logging(content,status:FTStatus.init(rawValue: status)!)
            
            
        }else{
            result(FlutterMethodNotImplemented)
            
        }
    }
    
}
