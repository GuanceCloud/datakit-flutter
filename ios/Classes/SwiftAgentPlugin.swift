import Flutter
import UIKit
import FTMobileSDK

public class SwiftAgentPlugin: NSObject, FlutterPlugin {

    static let METHOD_CONFIG = "ftConfig"
    static let METHOD_TRACK = "ftTrack"
    static let METHOD_TRACK_LIST = "ftTrackList"
    static let METHOD_TRACK_FLOW_CHART = "ftTrackFlowChart"
    static let METHOD_BIND_USER = "ftBindUser"
    static let METHOD_UNBIND_USER = "ftUnBindUser"
    static let METHOD_STOP_SDK = "ftStopSdk"
    static let METHOD_TRACK_BACKGROUND = "ftTrackBackground"
    static let METHOD_START_LOCATION  = "ftStartLocation"
    static let METHOD_START_MONITOR = "ftStartMonitor"
    static let METHOD_STOP_MONITOR = "ftStopMonitor"

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
            self.ftConfig(metricsUrl: args["serverUrl"] as! String, akId: args["akId"] as? String, akSecret:(args["akSecret"] as? String),datakitUUID: args["datakitUUID"] as? String, enableLog: args["enableLog"] as? Bool, needBindUser: (args["needBindUser"] as? Bool),monitorType: (args["monitorType"] as? Int))
            result(nil)
        } else if (call.method == SwiftAgentPlugin.METHOD_TRACK) {
            DispatchQueue.global(qos: .userInitiated).async {
                
                let resultDic = self.ftTrack(measurement: args["measurement"] as! String, tags: args["tags"] as? Dictionary<String, Any>, fields: args["fields"] as! Dictionary<String, Any>)
                DispatchQueue.main.async {
                    result(resultDic)
                }
            }
            
        }else if(call.method == SwiftAgentPlugin.METHOD_TRACK_LIST){
            
            let list = args["list"] as! Array<Dictionary<String,Any?>>
            DispatchQueue.global(qos: .userInitiated).async {
                let resultDic = self.ftTrackList(items: list)
                DispatchQueue.main.async {
                    result(resultDic)
                }
            }
        }else if(call.method == SwiftAgentPlugin.METHOD_BIND_USER){
            self.ftBindUser(name: args["name"] as! String, id: args["id"] as! String, extras: args["extras"] as? Dictionary<String, Any>)
            result(nil)
        }else if(call.method == SwiftAgentPlugin.METHOD_TRACK_FLOW_CHART){
            self.ftTrackFlowChart(production: args["production"] as! String, traceId: args["production"] as! String, name: args["name"] as! String, parent: args["parent"] as? String, duration: args["duration"] as! Int, tags: args["tags"] as? Dictionary<String, Any>, fields: (args["fields"] as? Dictionary<String, Any>))
            result(nil)
        }else if(call.method == SwiftAgentPlugin.METHOD_TRACK_BACKGROUND){
            self.ftTrackBackground(measurement: args["measurement"] as! String, tags: args["tags"] as? Dictionary<String, Any>, fields: (args["fields"] as! Dictionary<String, Any>))
            result(nil)
        }else if(call.method == SwiftAgentPlugin.METHOD_START_LOCATION){
            FTMobileAgent.startLocation { (code, message) in
                var resultDic = Dictionary<String,Any>()
                resultDic = ["code":code,"response":message]
                result(resultDic)
            }
            
        }else if(call.method == SwiftAgentPlugin.METHOD_STOP_SDK){
            self.ftStopSdk()
            result(nil)
        }else if(call.method == SwiftAgentPlugin.METHOD_UNBIND_USER){
            self.ftUnBindUser()
            result(nil)
        }else if(call.method == SwiftAgentPlugin.METHOD_START_MONITOR){
            self.ftStartMonitor(period: args["period"] as? Int, monitorType: args["monitorType"] as? Int)
            result(nil)
        }else if(call.method == SwiftAgentPlugin.METHOD_STOP_MONITOR){
            self.ftStopMonitor()
            result(nil)
        }else{
            result(FlutterMethodNotImplemented)
        }
    }

    
    /// 设置条件
    /// - Parameters:
    ///   - metricsUrl: 服务器地址
    ///   - akId: access key
    ///   - akSecret: access secret
    private func ftConfig(metricsUrl:String,akId:String?,akSecret:String?,datakitUUID:String?,enableLog:Bool?,needBindUser:Bool?,monitorType:Int?) {
        let enableRequestSigning = akId != nil && akSecret != nil
        let config: FTMobileConfig = FTMobileConfig(metricsUrl: metricsUrl, akId: akId, akSecret: akSecret, enableRequestSigning: enableRequestSigning)
        
//        config.enableAutoTrack = true
        config.enableLog = true
        config.needBindUser = needBindUser ?? false
        if((monitorType) != nil){
            config.monitorInfoType = FTMonitorInfoType(rawValue: monitorType!);
        }
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
            if((dic["tags"] as? Dictionary<String,Any?>)  != nil){
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
    
    /// 上报流程图
    /// - Parameters:
    ///   - production: 指标类型
    ///   - traceId: 标签
    ///   - name:流程节点名称
    ///   - parent:当前流程节点的上一个流程节点的名称
    ///   - duration:持续时间
    ///   - tags:标签
    ///   - fields: 值
    private func ftTrackFlowChart(production:String,traceId:String,name:String,parent:String?,duration:Int,tags:Dictionary<String, Any>?,fields:Dictionary<String, Any>?){
        if(tags != nil){
            FTMobileAgent.sharedInstance().flowTrack(production,traceId:traceId,name:name,parent:parent,tags:tags, duration:duration,field:fields)
        }else{
            FTMobileAgent.sharedInstance().flowTrack(production,traceId:traceId,name:name,parent:parent, tags: tags,duration:duration,field:fields)
        }
    }
    
    /// 主动埋点后台上传
    /// - Parameters:
    ///   - measurement:指标类型
    ///   - tags:标签
    ///   - fields: 值
    private func ftTrackBackground(measurement:String,tags:Dictionary<String, Any>?,fields:Dictionary<String, Any>){
        if(tags != nil){
            FTMobileAgent.sharedInstance().trackBackground(measurement,tags:tags,field:fields)
        }else{
            FTMobileAgent.sharedInstance().trackBackground(measurement,field:fields)
        }
    }
    /// 绑定用户
    /// - Parameters:
    ///   - name:用户名
    ///   - id:用户id
    ///   - extras:用户其他信息
    private func ftBindUser(name:String,id:String,extras:Dictionary<String, Any>?){
        FTMobileAgent.sharedInstance().bindUser(withName: name,id:id,exts:extras)
    }
    /// 启动监控项周期上传
    private func ftStartMonitor(period:Int?,monitorType:Int?){
        if((monitorType) != nil){
            FTMobileAgent.sharedInstance().startMonitorFlush(withInterval: period ?? 10, monitorType: FTMonitorInfoType(rawValue: monitorType!))
        }else{
            FTMobileAgent.sharedInstance().setMonitorFlushInterval(period ?? 10)
            FTMobileAgent.sharedInstance().stopMonitorFlush()
        }
    }
    /// 关闭监控项周期上传
    private func ftStopMonitor(){
        FTMobileAgent.sharedInstance().stopMonitorFlush()
    }
    
    /// 用户登出
    private func ftUnBindUser(){
        FTMobileAgent.sharedInstance().logout()
    }
    
    /// 停止SDK后台正在执行的操作
    private func ftStopSdk(){
        FTMobileAgent.sharedInstance().resetInstance()
    }
    
}
