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
                self.ftConfig(metricsUrl: args["serverUrl"] as! String, akId: args["akId"] as? String, akSecret:(args["akSecret"] as! String) )
                result(nil)
            } else if (call.method == SwiftAgentPlugin.METHOD_TRACK) {
                result(self.ftTrack(field: args["field"] as! String, tags: args["tags"] as? Dictionary<String, Any>, values: args["values"] as! Dictionary<String, Any>))
            }else{
                result(FlutterMethodNotImplemented)
            }
        }else{
           result(FlutterMethodNotImplemented)
        }
    }

    
    /// 设置条件
    /// - Parameters:
    ///   - metricsUrl: 服务器地址
    ///   - akId: access key
    ///   - akSecret: access secret
    private func ftConfig(metricsUrl:String,akId:String?,akSecret:String?) {
        let enableRequestSigning = akId != nil && akSecret != nil
        let config: FTMobileConfig = FTMobileConfig(metricsUrl: metricsUrl, akId: akId!, akSecret: akSecret!, enableRequestSigning: enableRequestSigning)
        config.enableAutoTrack = true
        FTMobileAgent.start(withConfigOptions: config)

    }
    
    
    /// 上报数据
    /// - Parameters:
    ///   - field: 指标类型
    ///   - tags: 标签
    ///   - values: 值
    private func ftTrack(field:String,tags:Dictionary<String, Any>?,values:Dictionary<String, Any>) ->Bool{
        
        let group = DispatchGroup()
        var result = false
        group.enter()
        if(tags != nil){
          FTMobileAgent.sharedInstance().trackImmediate(field, tags: tags,values: values){
              (success) -> () in
            result = success
            group.leave()
             
          }
        }else{
          FTMobileAgent.sharedInstance().trackImmediate(field,values: values){
              (success) -> () in
            result = success
            group.leave()
          }
        }
        group.wait()
        
        return result
    }


}
