//
//  FTTestUtils.swift
//  FTPluginTests
//
//  Created by hulilei on 2025/6/24.
//

import Foundation
@testable import FTTest

class FTTestUtils {
    static func sdkConfigDict()->[String:Any]{
        return [
            // 字符串类型
            Constants.Base.datakitUrl: "aaa",
            Constants.Base.datawayUrl: "bbb",
            Constants.Base.cliToken: "token",
            Constants.Base.env: "test",
            Constants.Base.serviceName: "testService",
            Constants.Base.pkgInfo: "0.0.1",
            // 布尔类型
            Constants.Base.debug: NSNumber(value: true),
            Constants.Base.autoSync: NSNumber(value: false),
            Constants.Base.compressIntakeRequests: NSNumber(value: true),
            Constants.Base.enableDataIntegerCompatible:  NSNumber(value: true),
            Constants.Base.enableLimitWithDbSize:NSNumber(value: true),
            
            // 数值类型
            Constants.Base.syncPageSize: NSNumber(value: 1),
            Constants.Base.customSyncPageSize: NSNumber(value: 100),
            Constants.Base.syncSleepTime: NSNumber(value: 100),
            Constants.Base.dbCacheLimit: NSNumber(value: 60 * 1024 * 1024),
            Constants.Base.dbCacheDiscard:NSNumber(value: 1),
            
            // 集合类型
            Constants.Base.groupIdentifiers: ["111", "222"],
            // 字典类型
            Constants.Base.dataModifier: ["device_uuid": "xxx"],
            Constants.Base.lineDataModifier: ["view_url": "xxx"],
            Constants.Base.globalContext: ["test_key": "test_value"]
        ]
    }
    
    static  func sdkConfigEmptyDict()->[String:Any]{
        return [
            // 字符串类型
            Constants.Base.datakitUrl: "aaa",
            Constants.Base.datawayUrl: NSNull(),
            Constants.Base.cliToken: NSNull(),
            Constants.Base.env: NSNull(),
            Constants.Base.serviceName: NSNull(),
            Constants.Base.pkgInfo: NSNull(),
            // 布尔类型
            Constants.Base.debug: NSNull(),
            Constants.Base.autoSync: NSNull(),
            Constants.Base.compressIntakeRequests: NSNull(),
            Constants.Base.enableDataIntegerCompatible:  NSNull(),
            Constants.Base.enableLimitWithDbSize:NSNull(),
            
            // 数值类型
            Constants.Base.syncPageSize: NSNull(),
            Constants.Base.customSyncPageSize: NSNull(),
            Constants.Base.syncSleepTime: NSNull(),
            Constants.Base.dbCacheLimit: NSNull(),
            Constants.Base.dbCacheDiscard:NSNull(),
            
            // 集合类型
            Constants.Base.groupIdentifiers: NSNull(),
            // 字典类型
            Constants.Base.dataModifier: NSNull(),
            Constants.Base.lineDataModifier:NSNull(),
            Constants.Base.globalContext: NSNull()
        ]
    }
    
    
    static func rumConfigDict()->[String:Any]{
        return [
            Constants.RUM.rumAppId: "app_id",
            Constants.RUM.sampleRate: NSNull(),
            Constants.RUM.sessionOnErrorSampleRate: NSNull(),
            Constants.RUM.enableUserAction: NSNull(),
            Constants.RUM.enableUserView: NSNull(),
            Constants.RUM.enableUserResource: NSNull(),
            Constants.RUM.enableTrackNativeAppANR: NSNull(),
            Constants.RUM.enableTrackNativeCrash: NSNull(),
            Constants.RUM.nativeUiBlockDurationMS: NSNull(),
            Constants.RUM.enableAppUIBlock: NSNull(),
            Constants.RUM.errorMonitorType: NSNull(),
            Constants.RUM.globalContext: NSNull(),
            Constants.RUM.deviceMetricsMonitorType: NSNull(),
            Constants.RUM.detectFrequency: NSNull(),
            Constants.RUM.rumCacheLimitCount: NSNull(),
            Constants.RUM.rumCacheDiscard: NSNull()
        ]
    }
    
    static func rumConfigEmptyDict()->[String:Any]{
        return [
            Constants.RUM.rumAppId: "app_id",
            Constants.RUM.sampleRate: NSNumber(value: 0.7),
            Constants.RUM.sessionOnErrorSampleRate: NSNumber(value: 1),
            Constants.RUM.enableUserAction: NSNumber(value: true),
            Constants.RUM.enableUserView: NSNumber(value: true),
            Constants.RUM.enableUserResource: NSNumber(value: true),
            Constants.RUM.enableTrackNativeAppANR: NSNumber(value: true),
            Constants.RUM.enableTrackNativeCrash: NSNumber(value: true),
            Constants.RUM.nativeUiBlockDurationMS: NSNumber(value: 1000),
            Constants.RUM.enableAppUIBlock: NSNumber(value: true),
            Constants.RUM.errorMonitorType: NSNumber(value: 2),
            Constants.RUM.globalContext: ["rum_key": "rum_value"],
            Constants.RUM.deviceMetricsMonitorType: NSNumber(value: 1),
            Constants.RUM.detectFrequency: NSNumber(value: 1),
            Constants.RUM.rumCacheLimitCount: NSNumber(value: 10000),
            Constants.RUM.rumCacheDiscard: NSNumber(value: 0)
        ]
    }
    static func logConfigDict()->[String:Any]{
        return [
            Constants.Log.sampleRate: NSNumber(value: 0.4),
            Constants.Log.logCacheDiscard: NSNumber(value: 1),
            Constants.Log.logType: [NSNumber(value: 1),NSNumber(value: 0)],
            Constants.Log.enableLinkRumData: NSNumber(value: true),
            Constants.Log.enableCustomLog: NSNumber(value: true),
            Constants.Log.printCustomLogToConsole: NSNumber(value: true),
            Constants.Log.logCacheLimitCount: NSNumber(value: 10000),
            Constants.Log.globalContext: ["log_key":"log_value"],
        ]
    }
    static func logConfigEmptyDict()->[String:Any]{
        return [
            Constants.Log.sampleRate: NSNull(),
            Constants.Log.logCacheDiscard: NSNull(),
            Constants.Log.logType: NSNull(),
            Constants.Log.enableLinkRumData: NSNull(),
            Constants.Log.enableCustomLog: NSNull(),
            Constants.Log.printCustomLogToConsole: NSNull(),
            Constants.Log.logCacheLimitCount: NSNull(),
            Constants.Log.globalContext: NSNull(),
        ]
    }
    
    static func traceConfigDict()->[String:Any]{
        return [
            Constants.Trace.sampleRate: NSNumber(value: 0.5),
            Constants.Trace.enableLinkRUMData: NSNumber(value: true),
            Constants.Trace.enableNativeAutoTrace: NSNumber(value: true),
            Constants.Trace.traceType: NSNumber(value: 1),
        ]
    }
    static func traceConfigEmptyDict()->[String:Any]{
        return [
            Constants.Trace.sampleRate: NSNull(),
            Constants.Trace.enableLinkRUMData: NSNull(),
            Constants.Trace.enableNativeAutoTrace: NSNull(),
            Constants.Trace.traceType: NSNull(),
        ]
    }
    
}
