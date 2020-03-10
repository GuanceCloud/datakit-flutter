#import "FTMobileAgentFlutter.h"
#if __has_include(<ft_mobile_agent_flutter/ft_mobile_agent_flutter-Swift.h>)
#import <ft_mobile_agent_flutter/ft_mobile_agent_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ft_mobile_agent_flutter-Swift.h"
#endif

@implementation FTMobileAgentFlutter
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAgentPlugin registerWithRegistrar:registrar];
}
@end
