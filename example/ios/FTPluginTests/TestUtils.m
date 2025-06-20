//
//  TestUtils.m
//  FTTests
//
//  Created by hulilei on 2025/6/19.
//

#import "TestUtils.h"

@implementation TestUtils


+ (NSDictionary *)sdkConfigDict{
    
    return @{@"datakitUrl":@"aaa",
             @"datawayUrl":@"bbb",
             @"cliToken":@"token",
             @"debug":@(YES),
             @"env":@"test",
             @"serviceName":@"testServic",
             @"autoSync":@(NO),
             @"syncPageSize":@(1),
             @"syncSleepTime":@(100),
             @"customSyncPageSize":@(100),
             @"compressIntakeRequests":@(YES),
             @"enableDataIntegerCompatible":@(YES),
             @"dbCacheDiscard":@(1),
             @"groupIdentifiers":@[@"111",@"222"],
             @"enableLimitWithDbSize":@(YES),
             @"dbCacheLimit":@(60*1024*1024),
             @"dataModifier":@{@"device_uuid":@"xxx"},
             @"lineDataModifier":@{@"view_url":@"xxx"},
             @"pkgInfo":@"0.0.1",
             @"globalContext":@{@"test_key":@"test_value"},
    };
}
+ (NSDictionary *)sdkConfigEmptyDict{
    
    return @{@"datakitUrl":@"aaa",
             @"datawayUrl":[NSNull new],
             @"cliToken":[NSNull new],
             @"debug":[NSNull new],
             @"env":[NSNull new],
             @"serviceName":[NSNull new],
             @"autoSync":[NSNull new],
             @"syncPageSize":[NSNull new],
             @"customSyncPageSize":[NSNull new],
             @"enableDataIntegerCompatible":[NSNull new],
             @"dbCacheDiscard":[NSNull new],
             @"groupIdentifiers":[NSNull new],
             @"enableLimitWithDbSize":[NSNull new],
             @"dbCacheLimit":[NSNull new],
             @"dataModifier":[NSNull new],
             @"lineDataModifier":[NSNull new],
             @"pkgInfo":[NSNull new],
             @"globalContext":[NSNull new],
    };
}

+ (NSDictionary *)rumConfigDict{
    
    return @{@"rumAppId":@"app_id",
             @"sampleRate":@(0.7),
             @"sessionOnErrorSampleRate":@(1),
             @"enableUserAction":@(YES),
             @"enableUserView":@(YES),
             @"enableUserResource":@(YES),
             @"enableTrackNativeAppANR":@(YES),
             @"enableTrackNativeCrash":@(YES),
             @"nativeUiBlockDurationMS":@(YES),
             @"enableAppUIBlock":@(YES),
             @"errorMonitorType":@(2),
             @"globalContext":@{@"rum_key":@"rum_value"},
             @"deviceMetricsMonitorType":@(1),
             @"detectFrequency":@(1),
             @"rumCacheLimitCount":@(10000),
             @"rumCacheDiscard":@(0),
    };
}
+ (NSDictionary *)rumConfigEmptyDict{
    
    return @{@"rumAppId":@"id",
             @"sampleRate":[NSNull new],
             @"sessionOnErrorSampleRate":[NSNull new],
             @"enableUserAction":[NSNull new],
             @"enableUserView":[NSNull new],
             @"enableUserResource":[NSNull new],
             @"enableTrackNativeAppANR":[NSNull new],
             @"enableTrackNativeCrash":[NSNull new],
             @"nativeUiBlockDurationMS":[NSNull new],
             @"enableAppUIBlock":[NSNull new],
             @"errorMonitorType":[NSNull new],
             @"globalContext":[NSNull new],
             @"deviceMetricsMonitorType":[NSNull new],
             @"detectFrequency":[NSNull new],
             @"rumCacheLimitCount":[NSNull new],
             @"rumCacheDiscard":[NSNull new],
    };
}

+ (NSDictionary *)logConfigDict{
    
    return @{@"sampleRate":@(0.4),
             @"logCacheDiscard":@(1),
             @"logType":@[@(0),@(1)],
             @"enableLinkRumData":@(YES),
             @"enableCustomLog":@(YES),
             @"printCustomLogToConsole":@(YES),
             @"logCacheLimitCount":@(10000),
             @"globalContext":@{@"log_key":@"log_value"},
    };
}
+ (NSDictionary *)logConfigEmptyDict{
    
    return @{@"sampleRate":[NSNull new],
             @"logCacheDiscard":[NSNull new],
             @"logType":[NSNull new],
             @"enableLinkRumData":[NSNull new],
             @"enableCustomLog":[NSNull new],
             @"printCustomLogToConsole":[NSNull new],
             @"logCacheLimitCount":[NSNull new],
             @"globalContext":[NSNull new],
    };
}

+ (NSDictionary *)traceConfigDict{
    return @{@"sampleRate":@(0.5),
             @"enableLinkRUMData":@(YES),
             @"enableNativeAutoTrace":@(YES),
             @"traceType":@(1)
    };
}
+ (NSDictionary *)traceConfigEmptyDict{
    
    return @{@"sampleRate":[NSNull new],
             @"enableLinkRUMData":[NSNull new],
             @"enableNativeAutoTrace":[NSNull new],
             @"traceType":[NSNull new]
    };
}
@end
