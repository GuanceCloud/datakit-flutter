//
//  FTTypeValidator.swift
//  ft_mobile_agent_flutter
//
//  Created by hulilei on 2025/6/17.
//
import FTMobileSDK
import Foundation
import os.log

protocol ConfigValidator:NSObject {
    func configurationIsCorrect(_ context:Dictionary<String, Any>)->[String]
    var specialKey:[String] { get }
    func validatorSpecialKey(_ key:String,_ value:Any,_ context:Dictionary<String, Any>)->Bool
    func configDescription() -> String
}
extension ConfigValidator{
    func configDescription() -> String{
        return self.debugDescription
    }
    var specialKey:[String] {
        return []
    }
    func validatorSpecialKey(_ key:String,_ value:Any,_ context:Dictionary<String, Any>)->Bool{
        return false
    }
    func configurationIsCorrect(_ context:Dictionary<String, Any>)->[String]{
        var mismatchedKeys: [String] = []
        for (key,value) in context {
            guard  value is NSNull == false  else {
                continue
            }
            if specialKey.contains(key) {
                if validatorSpecialKey(key,value,context) == false {
                    mismatchedKeys.append("\(key):value mismatch")
                }
            }else if self.responds(to: NSSelectorFromString(key)) {
                if let configValue = self.value(forKey: key){
                    if isEqual(configValue, value) == false {
                        mismatchedKeys.append("\(key): value mismatch:\(configValue):\(value)")
                    }
                }else{
                    mismatchedKeys.append("\(key): property set fail")
                }
            }else{
                mismatchedKeys.append("\(key): property not found")
            }
        }
        return mismatchedKeys
    }
    func isEqual(_ a: Any, _ b: Any) -> Bool {
        // Handle basic type comparison
        if let intA = a as? Int, let intB = b as? Int {
            return intA == intB
        }else if let doubleA = a as? Double, let doubleB = b as? Double {
            return doubleA == doubleB
        }else if let boolA = a as? Bool, let boolB = b as? Bool {
            return boolA == boolB
        } else if let stringA = a as? String, let stringB = b as? String {
            return stringA == stringB
        }else if let arrayA = a as? NSArray, let arrayB = b as? NSArray {
            return arrayA == arrayB
        }else if let dictA = a as? Dictionary<String,String>, let dictB = b as? Dictionary<String,String> {
            return dictA == dictB
        }
        // Handle other types or custom types
        return false
    }
}
extension FTMobileConfig:ConfigValidator {
    
    @objc var debug: Bool {
        return enableSDKDebugLog
    }
    @objc var dbCacheDiscard:Int {
        return dbDiscardType.rawValue
    }
    @objc var customSyncPageSize:Int {
        return Int(syncPageSize)
    }
    @objc var serviceName:String{
        return service
    }
    @objc var cliToken:String{
        return clientToken
    }
    
    @objc var enableRemoteConfiguration:Bool{
        return remoteConfiguration
    }

    var specialKey: [String]{
        return [Constants.Base.dataModifier,
                Constants.Base.lineDataModifier,
                Constants.Base.syncPageSize,
                Constants.Base.pkgInfo,
                Constants.Base.cliToken,
                Constants.Base.datawayUrl]
    }
    func validatorSpecialKey(_ key:String,_ value:Any,_ context:Dictionary<String, Any>)->Bool{
        switch key{
        case Constants.Base.dataModifier,Constants.Base.lineDataModifier:
            return true
        case Constants.Base.pkgInfo:
            return value as! String == self.pkgInfo()["flutter"] as! String
        case Constants.Base.syncPageSize:
            if let customSyncPageSize = context[Constants.Base.customSyncPageSize] as? Int {
                return self.syncPageSize == customSyncPageSize
            }else if let value = value as? Int,let syncType = FTSyncPageSize(rawValue: UInt(value)){
                switch syncType{
                case .mini:
                    return self.syncPageSize == 5
                case .medium:
                    return self.syncPageSize == 10
                case .max:
                    return self.syncPageSize == 50
                @unknown default:
                    return self.syncPageSize == 10
                }
            }
            return false
        case Constants.Base.cliToken,Constants.Base.datawayUrl:
            if datakitUrl.count>0 {
                return true
            }else{
                return isEqual(value, self.value(forKey: key) ?? "")
            }
        default:
            return false
        }
    
    }
}
extension FTLoggerConfig:ConfigValidator{
    @objc var sampleRate: Double {
        return Double(samplerate) / 100
    }
    @objc var logCacheDiscard:Int{
        return Int(discardType.rawValue)
    }
    @objc var logType:[Any]{
        return logLevelFilter
    }
}
extension FTRumConfig:ConfigValidator{
    @objc var sampleRate: Double {
        return Double(samplerate) / 100
    }
    @objc var enableUserResource:Bool{
        return enableTraceUserResource
    }
    @objc var enableAppUIBlock:Bool{
        return enableTrackAppFreeze
    }
    @objc var enableTrackNativeCrash:Bool{
        return enableTrackAppCrash
    }
    @objc var rumAppId:String{
        return appid
    }
    @objc var enableUserView:Bool{
        return enableTraceUserView
    }
    @objc var detectFrequency:Int{
        return Int(monitorFrequency.rawValue)
    }
    @objc var rumCacheDiscard:Int{
        return Int(rumDiscardType.rawValue)
    }
    @objc var nativeUiBlockDurationMS:Int{
        return freezeDurationMs
    }
    @objc var enableUserAction:Bool{
        return enableTraceUserAction
    }
    @objc var enableTrackNativeAppANR:Bool{
        return enableTrackAppANR
    }
    var specialKey: [String]{
        return [Constants.RUM.sessionOnErrorSampleRate,
                Constants.RUM.enableUserViewInFragment]
    }
    func validatorSpecialKey(_ key: String, _ value: Any, _ context: Dictionary<String, Any>) -> Bool {
        switch key{
        case Constants.RUM.enableUserViewInFragment:
            return true
        case Constants.RUM.sessionOnErrorSampleRate:
            return Double(sessionOnErrorSampleRate) / 100 == value as! Double
        default:
            return false
        }
    
    }
}
extension FTTraceConfig:ConfigValidator{
    @objc var sampleRate: Double {
        return Double(samplerate) / 100
    }
    @objc var traceType:Int {
        return Int(networkTraceType.rawValue)
    }
    @objc var enableLinkRUMData:Bool{
        return enableLinkRumData
    }
    @objc var enableNativeAutoTrace:Bool{
        return enableAutoTrace
    }
}
extension NSNumber {
    var isStoredAsDouble: Bool {
        String(cString: self.objCType) == "d" || (self as? Double) != nil
    }
    
    var isStoredAsInt: Bool {
        String(cString: self.objCType) == "i" || (self as? Int) != nil
    }
    var isStoredAsBool: Bool {
        String(cString: self.objCType) == "c" || (self as? Int) != nil
    }
}
    @available(iOS 14.0, *)
    let logger = Logger(subsystem: "com.example.app", category: "test")

@objc class FTTypeValidator:NSObject {
    /// Validate the value type of the specified key in the dictionary
    static func validate<T>(_ context: [String: Any], key: String, type: T.Type) -> Bool {
        return context[key] is T
    }
    
    /// Batch validate types in dictionary
    static func validateAll(_ context: Dictionary<String, Any>, rules: [String: Any.Type],type:String,config:ConfigValidator) -> Bool{
        var result = [String: String]()
        var empty = [String]()
        for (key, expectedType) in rules {
            guard let value = context[key] else {
                empty.append(key)
                continue
            }
            if value is NSNull {
                empty.append(key)
                continue
            }
            // Handle special bridge types
            var validate = false
            switch expectedType {
            case is String.Type:
                validate = value is String || value is NSString
            case is Double.Type:
                validate = (value as? Double) != nil ||
                (value as? NSNumber)?.isStoredAsDouble == true
            case is Bool.Type:
                validate = value is Bool ||
                (value as? NSNumber)?.isStoredAsBool == true
            case is Int.Type:
                validate = value is Int ||
                (value as? NSNumber)?.isStoredAsInt == true
            case is Dictionary<String, String>.Type:
                validate = value is [String: String]
            case is [String:Any].Type:
                validate = value is [String: Any]
            case is [Any].Type:
                validate = value is [Any] ||
                value is NSArray
            case is [String].Type:
                validate = value is [String]
            default:
                validate = false
            }
            if validate == false {
                result[key] = "Type (\(expectedType)) is \(validate)"
            }
        }
        if #available(iOS 14.0, *) {
            let res = config.configurationIsCorrect(context)
            let str = res.count==0 ? "successful!":"failed with parameter:\(res)."
            let verificationStr = result.count>0 ? "----\nParameter type verification result :\n \(result)\n":""
            let unsetStr = empty.count == 0 ? "" : "----\n Unset parameters :\n \(empty)"
            logger.info("[TEST] \(type) Config \(str)\n\(verificationStr)\(unsetStr)")
            return res.count == 0
        }
    }
    
    @objc static func validateRUM(_ param:[String: Any])->NSNumber{
        let config = param["config"] as! FTRumConfig
        let context = param["context"] as! [String:Any]
        let rules:[String : Any.Type] = [
            Constants.RUM.rumAppId:String.self,
            Constants.RUM.sampleRate:Double.self,
            Constants.RUM.sessionOnErrorSampleRate:Double.self,
            Constants.RUM.enableUserAction:Bool.self,
            Constants.RUM.enableUserView:Bool.self,
            Constants.RUM.enableUserResource:Bool.self,
            Constants.RUM.enableTrackNativeAppANR:Bool.self,
            Constants.RUM.enableTrackNativeCrash:Bool.self,
            Constants.RUM.nativeUiBlockDurationMS:Int.self,
            Constants.RUM.enableAppUIBlock:Bool.self,
            Constants.RUM.errorMonitorType:Int.self,
            Constants.RUM.globalContext:Dictionary<String, String>.self,
            Constants.RUM.deviceMetricsMonitorType:Int.self,
            Constants.RUM.detectFrequency:Int.self,
            Constants.RUM.rumCacheLimitCount:Int.self,
            Constants.RUM.rumCacheDiscard:Int.self,
        ]
        return NSNumber(booleanLiteral:validateAll(context, rules: rules,type: "RUM",config:config ))
    }
    @objc static func validateLog(_ param:[String: Any])->NSNumber{
        let config = param["config"] as! FTLoggerConfig
        let context = param["context"] as! [String:Any]
        let rules:[String : Any.Type] = [
            Constants.Log.sampleRate:Double.self,
            Constants.Log.logCacheDiscard:Int.self,
            Constants.Log.logType:[Any].self,
            Constants.Log.enableLinkRumData:Bool.self,
            Constants.Log.enableCustomLog:Bool.self,
            Constants.Log.printCustomLogToConsole:Bool.self,
            Constants.Log.logCacheLimitCount:Int.self,
            Constants.Log.globalContext:Dictionary<String, String>.self,
        ]
        return  NSNumber(booleanLiteral:validateAll(context, rules: rules, type: "Log",config: config))
    }
    @objc static func validateTrace(_ param:[String: Any])->NSNumber{
        let config = param["config"] as! FTTraceConfig
        let context = param["context"] as! [String:Any]
        let rules:[String : Any.Type] = [
            Constants.Trace.sampleRate:Double.self,
            Constants.Trace.enableLinkRUMData:Bool.self,
            Constants.Trace.enableNativeAutoTrace:Bool.self,
            Constants.Trace.traceType:Int.self,
        ]
        return NSNumber(booleanLiteral:validateAll(context, rules: rules, type: "Trace",config: config))
    }
    @objc static func validateBase(_ param:[String: Any]) -> NSNumber{
        let config = param["config"] as! FTMobileConfig
        let context = param["context"] as! [String:Any]
        let rules:[String : Any.Type] = [
            Constants.Base.datakitUrl:String.self,
            Constants.Base.datawayUrl:String.self,
            Constants.Base.cliToken:String.self,
            Constants.Base.debug:Bool.self,
            Constants.Base.env:String.self,
            Constants.Base.serviceName:String.self,
            Constants.Base.autoSync:Bool.self,
            Constants.Base.syncPageSize:Int.self,
            Constants.Base.customSyncPageSize:Int.self,
            Constants.Base.syncSleepTime:Int.self,
            Constants.Base.compressIntakeRequests:Bool.self,
            Constants.Base.enableDataIntegerCompatible:Bool.self,
            Constants.Base.dbCacheDiscard:Int.self,
            Constants.Base.groupIdentifiers:[String].self,
            Constants.Base.enableLimitWithDbSize:Bool.self,
            Constants.Base.dbCacheLimit:Int.self,
            Constants.Base.dataModifier:[String:Any].self,
            Constants.Base.lineDataModifier:[String:Any].self,
            Constants.Base.pkgInfo:String.self,
            Constants.Base.globalContext:Dictionary<String, String>.self,
        ]
        return NSNumber(booleanLiteral:validateAll(context, rules: rules, type: "SDK",config:config))
    }
}
