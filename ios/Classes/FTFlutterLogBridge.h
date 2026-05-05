#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FTFlutterLogBridge : NSObject
+ (void)log:(NSString *)content status:(NSString *)status property:(nullable NSDictionary *)property;
@end

NS_ASSUME_NONNULL_END
