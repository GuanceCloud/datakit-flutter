import Flutter
import UIKit
import FTMobileAgent

public class SwiftAgentPlugin: NSObject, FlutterPlugin {

    static let METHOD_CONFIG = "ft_config"
    static let METHOD_TRACK = "ft_track"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ft_mobile_agent_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftAgentPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }


    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(call.arguments is Dictionary<String, Any>){
            let args = call.arguments as! Dictionary<String, Any>
            if (call.method == SwiftAgentPlugin.METHOD_CONFIG) {
                self.ft_config(metricsUrl: args["serverUrl"] as! String, akId: args["akId"] as? String, akSecret:(args["akSecret"] as! String) )
                result(nil)
            } else if (call.method == SwiftAgentPlugin.METHOD_TRACK) {
                result(self.ft_track(field: args["field"] as! String, tags: args["tags"] as? Dictionary<String, Any>, values: args["values"] as! Dictionary<String, Any>))
            }else{
                result(FlutterMethodNotImplemented)
            }
        }else{
           result(FlutterMethodNotImplemented)
        }
    }

    private func ft_config(metricsUrl:String,akId:String?,akSecret:String?) {
        let enableRequestSigning = akId != nil && akSecret != nil
        let config: FTMobileConfig = FTMobileConfig(metricsUrl: metricsUrl, akId: akId!, akSecret: akSecret!, enableRequestSigning: enableRequestSigning)
        FTMobileAgent.start(withConfigOptions: config)

    }
    
    private func ft_track(field:String,tags:Dictionary<String, Any>?,values:Dictionary<String, Any>) ->Bool{
        if(tags != nil){
            FTMobileAgent.sharedInstance().track(field, tags: tags ,values: values)
        }else{
            FTMobileAgent.sharedInstance().track(field,values: values)
        }
        return true
    }


}
