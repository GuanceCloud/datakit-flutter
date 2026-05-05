#import "FTFlutterLogBridge.h"
#import <FTMobileSDK/FTLogger+Private.h>

@implementation FTFlutterLogBridge
+ (void)log:(NSString *)content status:(NSString *)status property:(NSDictionary *)property {
    [[FTLogger sharedInstance] log:content status:status property:property];
}
@end
