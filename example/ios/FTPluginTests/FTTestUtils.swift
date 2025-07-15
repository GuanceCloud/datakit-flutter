//
//  FTTestUtils.swift
//  FTPluginTests
//
//  Created by hulilei on 2025/6/24.
//

import Foundation
@testable import FTTest

class FTTestUtils {
    static let fakeUrl = "http://fake.url"
    static func sdkConfigDict()->[String:Any]{
        return [
            // String type
            Constants.Base.datakitUrl: fakeUrl,
            Constants.Base.datawayUrl: fakeUrl,
            Constants.Base.cliToken: "token",
            Constants.Base.env: "test",
            Constants.Base.serviceName: "testService",
            Constants.Base.pkgInfo: "0.0.1",
            // Boolean type
            Constants.Base.debug: NSNumber(value: true),
            Constants.Base.autoSync: NSNumber(value: false),
            Constants.Base.compressIntakeRequests: NSNumber(value: true),
            Constants.Base.enableDataIntegerCompatible:  NSNumber(value: true),
            Constants.Base.enableLimitWithDbSize:NSNumber(value: true),
            
            // Numeric type
            Constants.Base.syncPageSize: NSNumber(value: 1),
            Constants.Base.customSyncPageSize: NSNumber(value: 100),
            Constants.Base.syncSleepTime: NSNumber(value: 100),
            Constants.Base.dbCacheLimit: NSNumber(value: 60 * 1024 * 1024),
            Constants.Base.dbCacheDiscard:NSNumber(value: 1),
            
            // Collection type
            Constants.Base.groupIdentifiers: ["com.fake.identifier1", "com.fake.identifier2"],
            // Dictionary type
            Constants.Base.dataModifier: ["device_uuid": "xxx"],
            Constants.Base.lineDataModifier: ["view_url": "xxx"],
            Constants.Base.globalContext: ["test_key": "test_value"],
            Constants.Base.enableRemoteConfiguration: NSNumber(value: true),
            Constants.Base.remoteConfigMiniUpdateInterval: NSNumber(value: 200)
        ]
    }
    static func sdkConfigSpecialKeyDict()->[String:Any]{
        let keysToDeleteValue: Set<String> = [Constants.Base.datakitUrl,Constants.Base.customSyncPageSize]
        return Dictionary(uniqueKeysWithValues:FTTestUtils.sdkConfigDict().map { key, value in
            if keysToDeleteValue.contains(key) {
                return (key, NSNull())
            } else {
                return (key, value)
            }
        })
    }
    static  func sdkConfigEmptyDict()->[String:Any]{
        let keysToKeepValue: Set<String> = [Constants.Base.datakitUrl]
        return Dictionary(uniqueKeysWithValues:FTTestUtils.sdkConfigDict().map { key, value in
            if keysToKeepValue.contains(key) {
                return (key, value)
            } else {
                return (key, NSNull())
            }
        })
    }
    
    static func rumConfigDict()->[String:Any]{
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
            Constants.RUM.rumCacheDiscard: NSNumber(value: 0),
            Constants.RUM.enableTraceWebView: NSNumber(value: true),
            Constants.RUM.allowWebViewHost: ["fake1.host.com", "fake2.host.com"],
        ]
    }
    
    static func rumConfigEmptyDict()->[String:Any]{
        let keysToKeepValue: Set<String> = [Constants.RUM.rumAppId]
        return Dictionary(uniqueKeysWithValues:FTTestUtils.rumConfigDict().map { key, value in
            if keysToKeepValue.contains(key) {
                return (key, value)
            } else {
                return (key, NSNull())
            }
        })
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
        return Dictionary(uniqueKeysWithValues:FTTestUtils.logConfigDict().keys.map { key in
            return (key, NSNull())
        })
    }
    
    static func traceConfigDict()->[String:Any]{
        return [
            Constants.Trace.sampleRate: NSNumber(value: 0.5),
            Constants.Trace.enableLinkRUMData: NSNumber(value: true),
            Constants.Trace.enableNativeAutoTrace: NSNumber(value: true),
            Constants.Trace.traceType: NSNumber(value: 1),
        ]
    }
    static func traceConfigEmptyDict() -> [String: Any] {
        return Dictionary(uniqueKeysWithValues:
            FTTestUtils.traceConfigDict().keys.map { key in
                (key, NSNull())
            }
        )
    }
    
}
