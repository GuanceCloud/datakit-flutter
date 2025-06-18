//
//  FTTypeValidator.swift
//  ft_mobile_agent_flutter
//
//  Created by hulilei on 2025/6/17.
//
#if FTTesting
import Foundation
import os.log

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
    let logger = Logger(subsystem: "com.example.app", category: "network")
struct FTTypeValidator {
    /// 校验字典中指定 key 的 value 类型
    static func validate<T>(_ context: [String: Any], key: String, type: T.Type) -> Bool {
        return context[key] is T
    }
    
    /// 批量校验字典中的类型
    static func validateAll(_ context: Dictionary<String, Any>, rules: [String: Any.Type],type:String){
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
            // 处理特殊桥接类型
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
                validate = value is [String: String] ||
                value is NSDictionary
            case is [String:Any].Type:
                validate = value is [String: Any] ||
                value is NSDictionary
            case is [Int].Type:
                validate = value is [Int] ||
                value is NSArray
            case is [String].Type:
                validate = value is [String] ||
                value is NSArray
            default:
                validate = false
            }
            result[key] = "Type (\(expectedType)) is \(validate)"
        }
        if #available(iOS 14.0, *) {
            logger.info("[TEST] \(type) Parameter type verification result :\n \(result)")
            logger.info("[TEST] \(type) Unset parameters :\n \(empty)")
        }
    }
    
    static func validateRUM(_ context:[String: Any]){
        let rules:[String : Any.Type] = [
            "rumAppId":String.self,
            "sampleRate":Double.self,
            "sessionOnErrorSampleRate":Double.self,
            "enableUserAction":Bool.self,
            "enableUserView":Bool.self,
            "enableUserResource":Bool.self,
            "enableTrackNativeAppANR":Bool.self,
            "enableTrackNativeCrash":Bool.self,
            "nativeUiBlockDurationMS":Int.self,
            "enableAppUIBlock":Bool.self,
            "errorMonitorType":Int.self,
            "globalContext":Dictionary<String, String>.self,
            "deviceMetricsMonitorType":Int.self,
            "detectFrequency":Int.self,
            "rumCacheLimitCount":Int.self,
            "rumCacheDiscard":Int.self,
        ]
        validateAll(context, rules: rules,type: "RUM")
    }
    static func validateLog(_ context:[String: Any]){
        let rules:[String : Any.Type] = [
            "sampleRate":Double.self,
            "logCacheDiscard":Int.self,
            "logType":[Int].self,
            "enableLinkRumData":Bool.self,
            "enableCustomLog":Bool.self,
            "printCustomLogToConsole":Bool.self,
            "logCacheLimitCount":Int.self,
            "globalContext":Dictionary<String, String>.self,
        ]
        validateAll(context, rules: rules, type: "Log")
    }
    static func validateTrace(_ context:[String: Any]){
        let rules:[String : Any.Type] = [
            "sampleRate":Double.self,
            "enableLinkRUMData":Bool.self,
            "enableNativeAutoTrace":Bool.self,
            "traceType":Int.self,
        ]
        validateAll(context, rules: rules, type: "Trace")
    }
    static func validateBase(_ context:[String: Any]){
        let rules:[String : Any.Type] = [
            "datakitUrl":String.self,
            "datawayUrl":String.self,
            "cliToken":String.self,
            "debug":Bool.self,
            "env":String.self,
            "serviceName":String.self,
            "autoSync":Bool.self,
            "syncPageSize":Int.self,
            "customSyncPageSize":Int.self,
            "syncSleepTime":Int.self,
            "compressIntakeRequests":Bool.self,
            "enableDataIntegerCompatible":Bool.self,
            "dbCacheDiscard":Int.self,
            "groupIdentifiers":[String].self,
            "enableLimitWithDbSize":Bool.self,
            "dbCacheLimit":Int.self,
            "dataModifier":[String:Any].self,
            "lineDataModifier":[String:Any].self,
            "pkgInfo":String.self,
            "globalContext":Dictionary<String, String>.self,
        ]
        validateAll(context, rules: rules, type: "SDK")
    }
}
#endif
