import Flutter
import UIKit
import FTMobileAgent

public class SwiftAgentPlugin: NSObject, FlutterPlugin {

    static let METHOD_CONFIG = "ftConfig"
    static let METHOD_TRACK = "ftTrack"
    static let METHOD_TRACK_LIST = "ftTrackList"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ft_mobile_agent_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftAgentPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }


    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(call.arguments is Dictionary<String, Any>){
            let args = call.arguments as! Dictionary<String, Any>
            if (call.method == SwiftAgentPlugin.METHOD_CONFIG) {
                self.ftConfig(metricsUrl: args["serverUrl"] as! String, akId: args["akId"] as? String, akSecret:(args["akSecret"] as? String),datakitUUID: args["datakitUUID"] as? String )
                result(nil)
            } else if (call.method == SwiftAgentPlugin.METHOD_TRACK) {
                result(self.ftTrack(measurement: args["measurement"] as! String, tags: args["tags"] as? Dictionary<String, Any>, fields: args["fields"] as! Dictionary<String, Any>))
            }else if(call.method == SwiftAgentPlugin.METHOD_TRACK_LIST){
                let list = args["list"] as! Array<Dictionary<String,Any?>>
                result(self.ftTrackList(items: list))
            }
            
            else{
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
    private func ftConfig(metricsUrl:String,akId:String?,akSecret:String?,datakitUUID:String?) {
        let enableRequestSigning = akId != nil && akSecret != nil
        let config: FTMobileConfig = FTMobileConfig(metricsUrl: metricsUrl, akId: akId!, akSecret: akSecret!, enableRequestSigning: enableRequestSigning)
        
//        config.enableAutoTrack = true
        config.enableLog = true
        if(datakitUUID != nil){
          config.xDataKitUUID = datakitUUID!
        }
        FTMobileAgent.start(withConfigOptions: config)

    }
    
    
    /// 上报数据
    /// - Parameters:
    ///   - measurement: 指标类型
    ///   - tags: 标签
    ///   - fields: 值
    private func ftTrack(measurement:String,tags:Dictionary<String, Any>?,fields:Dictionary<String, Any>) ->Dictionary<String,Any>{
        
        let group = DispatchGroup()
        var result:Dictionary<String,Any>?=nil;
        group.enter()
        if(tags != nil){
            FTMobileAgent.sharedInstance().trackImmediate(measurement, tags: tags!,field: fields){
              (code,response) -> () in
            result = ["code":code,"response":response]
            group.leave()
             
          }
        }else{
          FTMobileAgent.sharedInstance().trackImmediate(measurement,field: fields){
              (code,response) -> () in
            result = ["code":code,"response":response]
            group.leave()
          }
        }
        group.wait()
        return result!
    }
    
    private func ftTrackList(items:Array<Dictionary<String,Any?>>) ->Dictionary<String,Any>{
        
        
        let group = DispatchGroup()
        var result:Dictionary<String,Any>?=nil;
        group.enter()
        
        let beans:NSMutableArray = []
        for dic in items{
            let bean = FTTrackBean()
            bean.measurement = dic["measurement"] as! String
            if(dic["tags"] != nil){
                bean.tags = dic["tags"] as! Dictionary
            }

            bean.field = dic["fields"] as! Dictionary
            beans.add(bean)

        }
        
        FTMobileAgent.sharedInstance().trackImmediateList(beans as! [FTTrackBean]){
                     (code,response) -> () in
            result = ["code":code,"response":response]
                   group.leave()
                    
                 }
        group.wait()
        
        return result!
    }


}
