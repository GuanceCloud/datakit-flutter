#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FTSessionReplaySampleStateChangedHandler)(NSDictionary<NSString *, id> *context);

typedef NS_ENUM(NSInteger, FTFlutterSessionReplaySampleState) {
    FTFlutterSessionReplaySampleStateNormal,
    FTFlutterSessionReplaySampleStateError,
    FTFlutterSessionReplaySampleStateNone
};

@protocol FTSessionReplayBridge <NSObject>
- (void)config:(NSDictionary<NSString *, id> *)context;
- (nullable NSDictionary<NSString *, id> *)currentRUMContext;
- (void)setSampleStateChangedHandler:(nullable FTSessionReplaySampleStateChangedHandler)handler;
- (void)setHasReplay:(NSDictionary<NSString *, id> *)context;
- (void)setRecordCount:(NSDictionary<NSString *, id> *)context;
- (void)writeSegment:(NSDictionary<NSString *, id> *)context;
- (void)telemetryDebug:(NSDictionary<NSString *, id> *)context;
- (void)telemetryError:(NSDictionary<NSString *, id> *)context;
- (nullable id)saveImageResource:(NSDictionary<NSString *, id> *)context;
@end

@interface FTDefaultSessionReplayBridge : NSObject <FTSessionReplayBridge>

- (FTFlutterSessionReplaySampleState)sampleStateValue;

@end

NS_ASSUME_NONNULL_END
