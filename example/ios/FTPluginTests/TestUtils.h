//
//  TestUtils.h
//  FTTests
//
//  Created by hulilei on 2025/6/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestUtils : NSObject
+ (NSDictionary *)sdkConfigDict;
+ (NSDictionary *)sdkConfigEmptyDict;

+ (NSDictionary *)rumConfigDict;
+ (NSDictionary *)rumConfigEmptyDict;

+ (NSDictionary *)logConfigDict;
+ (NSDictionary *)logConfigEmptyDict;

+ (NSDictionary *)traceConfigDict;
+ (NSDictionary *)traceConfigEmptyDict;
@end

NS_ASSUME_NONNULL_END
