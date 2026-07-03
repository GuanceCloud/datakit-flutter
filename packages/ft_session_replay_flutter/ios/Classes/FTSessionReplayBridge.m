#import "FTSessionReplayBridge.h"
#import <Flutter/Flutter.h>
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>
#import <FTMobileSDK/FTConstants.h>
#import <FTMobileSDK/FTInnerLog.h>
#import <FTMobileSDK/FTMessageReceiver.h>
#import <FTMobileSDK/FTModuleManager.h>

#if __has_include(<FTMobileSDK/FTRemoteConfigManager.h>) && __has_include(<FTMobileSDK/FTRemoteConfigModel.h>)
#import <FTMobileSDK/FTRemoteConfigManager.h>
#import <FTMobileSDK/FTRemoteConfigModel.h>
#define FT_FLUTTER_SR_REMOTE_CONFIG_AVAILABLE 1
#elif __has_include(<FTMobileSDK/FTSDKCore/RemoteConfig/FTRemoteConfigManager.h>) && __has_include(<FTMobileSDK/FTSDKCore/RemoteConfig/FTRemoteConfigModel.h>)
#import <FTMobileSDK/FTSDKCore/RemoteConfig/FTRemoteConfigManager.h>
#import <FTMobileSDK/FTSDKCore/RemoteConfig/FTRemoteConfigModel.h>
#define FT_FLUTTER_SR_REMOTE_CONFIG_AVAILABLE 1
#else
#define FT_FLUTTER_SR_REMOTE_CONFIG_AVAILABLE 0
#endif

#if __has_include(<FTMobileSDK/FTCoreDirectory.h>) && __has_include(<FTMobileSDK/FTDirectory.h>) && __has_include(<FTMobileSDK/FTFeature.h>) && __has_include(<FTMobileSDK/FTFeatureDataStore.h>) && __has_include(<FTMobileSDK/FTFeatureDirectories.h>) && __has_include(<FTMobileSDK/FTFeatureScope.h>) && __has_include(<FTMobileSDK/FTFeatureStorage.h>) && __has_include(<FTMobileSDK/FTFeatureUpload.h>) && __has_include(<FTMobileSDK/FTFileWriter.h>) && __has_include(<FTMobileSDK/FTPerformancePreset.h>) && __has_include(<FTMobileSDK/FTPerformancePresetOverride.h>) && __has_include(<FTMobileSDK/FTPresetProperty.h>) && __has_include(<FTMobileSDK/FTResourcesFeature.h>) && __has_include(<FTMobileSDK/FTResourcesWriter.h>) && __has_include(<FTMobileSDK/FTSRRecord.h>) && __has_include(<FTMobileSDK/FTTLV.h>)
#import <FTMobileSDK/FTCoreDirectory.h>
#import <FTMobileSDK/FTDirectory.h>
#import <FTMobileSDK/FTFeature.h>
#import <FTMobileSDK/FTFeatureDataStore.h>
#import <FTMobileSDK/FTFeatureDirectories.h>
#import <FTMobileSDK/FTFeatureScope.h>
#import <FTMobileSDK/FTFeatureStorage.h>
#import <FTMobileSDK/FTFeatureUpload.h>
#import <FTMobileSDK/FTFileWriter.h>
#import <FTMobileSDK/FTPerformancePreset.h>
#import <FTMobileSDK/FTPerformancePresetOverride.h>
#import <FTMobileSDK/FTPresetProperty.h>
#import <FTMobileSDK/FTResourcesFeature.h>
#import <FTMobileSDK/FTResourcesWriter.h>
#import <FTMobileSDK/FTSRRecord.h>
#import <FTMobileSDK/FTTLV.h>
#define FT_FLUTTER_SR_WRITER_AVAILABLE 1
#else
#define FT_FLUTTER_SR_WRITER_AVAILABLE 0
@protocol FTWriter;
#endif

#if FT_FLUTTER_SR_WRITER_AVAILABLE
@interface FTFlutterSessionReplayFeatureStore : NSObject
@property (nonatomic, strong) FTFeatureStorage *storage;
@property (nonatomic, strong) FTFeatureUpload *upload;
- (instancetype)initWithStorage:(FTFeatureStorage *)storage upload:(FTFeatureUpload *)upload;
@end

@implementation FTFlutterSessionReplayFeatureStore
- (instancetype)initWithStorage:(FTFeatureStorage *)storage upload:(FTFeatureUpload *)upload {
    self = [super init];
    if (self) {
        _storage = storage;
        _upload = upload;
    }
    return self;
}
@end

@interface FTFlutterSessionReplayRemoteFeature : NSObject <FTRemoteFeature>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) FTPerformancePresetOverride *performanceOverride;
@property (nonatomic, strong) id<FTFeatureRequestBuilder> requestBuilder;
- (instancetype)initWithName:(NSString *)name
              requestBuilder:(id<FTFeatureRequestBuilder>)requestBuilder
         performanceOverride:(FTPerformancePresetOverride *)performanceOverride;
@end

@implementation FTFlutterSessionReplayRemoteFeature
- (instancetype)initWithName:(NSString *)name
              requestBuilder:(id<FTFeatureRequestBuilder>)requestBuilder
         performanceOverride:(FTPerformancePresetOverride *)performanceOverride {
    self = [super init];
    if (self) {
        _name = [name copy];
        _requestBuilder = requestBuilder;
        _performanceOverride = performanceOverride;
    }
    return self;
}
@end
#endif

@interface FTDefaultSessionReplayBridge () <FTMessageReceiver>
@property (nonatomic, strong) NSDictionary<NSString *, id> *currentContext;
@property (nonatomic, strong) NSDictionary<NSString *, id> *lastRUMContext;
@property (nonatomic, strong) NSObject *contextLock;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary<NSString *, NSNumber *> *> *recordsCountByViewID;
@property (nonatomic, strong) dispatch_queue_t readWriteQueue;
@property (atomic, assign) int sampleRate;
@property (atomic, assign) int sessionReplayOnErrorSampleRate;
@property (nonatomic, assign) FTFlutterSessionReplaySampleState sampleState;
@property (nonatomic, assign) BOOL sampleStateEvaluated;
@property (nonatomic, copy) NSString *sampleStateSessionID;
@property (nonatomic, assign) BOOL hasReplayRequested;
@property (nonatomic, copy) NSString *hasReplayViewID;
@property (nonatomic, copy) NSString *lastSegmentViewID;
@property (nonatomic, copy) FTSessionReplaySampleStateChangedHandler sampleStateChangedHandler;
@property (nonatomic, assign) BOOL configured;
@property (atomic, copy) NSArray<NSString *> *enableLinkRUMKeys;
#if FT_FLUTTER_SR_WRITER_AVAILABLE
@property (nonatomic, strong) FTCoreDirectory *coreDirectory;
@property (nonatomic, strong) FTPerformancePreset *performancePreset;
@property (nonatomic, strong) NSMutableDictionary<NSString *, FTFlutterSessionReplayFeatureStore *> *stores;
@property (nonatomic, strong) FTFeatureStorage *recordStorage;
@property (nonatomic, strong) FTFeatureScope *recordScope;
@property (nonatomic, strong) FTFeatureScope *resourceScope;
@property (nonatomic, strong) id<FTResourcesWriting> resourceWriter;
#endif
@end

@implementation FTDefaultSessionReplayBridge

- (instancetype)init {
    self = [super init];
    if (self) {
        _contextLock = [NSObject new];
        _recordsCountByViewID = [NSMutableDictionary new];
        _readWriteQueue = dispatch_queue_create("com.ft.flutter.session-replay.readwrite", DISPATCH_QUEUE_SERIAL);
        _sampleRate = 100;
        _sessionReplayOnErrorSampleRate = 0;
        _sampleState = FTFlutterSessionReplaySampleStateNone;
        _sampleStateEvaluated = NO;
        _hasReplayRequested = NO;
        _configured = NO;
        _enableLinkRUMKeys = @[];
#if FT_FLUTTER_SR_WRITER_AVAILABLE
        _performancePreset = [[FTPerformancePreset alloc] init];
        _stores = [NSMutableDictionary new];
#endif
        [[FTModuleManager sharedInstance] addMessageReceiver:self];
    }
    return self;
}

- (void)dealloc {
    [[FTModuleManager sharedInstance] removeMessageReceiver:self];
}

- (void)config:(NSDictionary<NSString *, id> *)context {
    NSNumber *sampleRate = [self numberForKey:@"sampleRate" inContext:context];
    if (sampleRate) {
        self.sampleRate = (int)(sampleRate.doubleValue * 100);
    }
    NSNumber *sessionReplayOnErrorSampleRate = [self numberForKey:@"sessionReplayOnErrorSampleRate" inContext:context];
    if (sessionReplayOnErrorSampleRate) {
        self.sessionReplayOnErrorSampleRate = (int)(sessionReplayOnErrorSampleRate.doubleValue * 100);
    }
    self.enableLinkRUMKeys = [self stringArrayFromValue:context[@"enableLinkRUMKeys"]];
    [self mergeRemoteSessionReplaySampleRates];
#if FT_FLUTTER_SR_WRITER_AVAILABLE
    [self ensureNativeSessionReplayFeatures];
#endif
    @synchronized (self.contextLock) {
        self.configured = YES;
    }
    NSDictionary *currentContext = [self lastRUMContextSnapshot] ?: [self currentContextSnapshot];
    if (currentContext) {
        @synchronized (self.contextLock) {
            self.currentContext = [self contextByFilteringLinkRUMKeys:currentContext];
        }
        [self updateSampleStateWithRUMContext:currentContext force:YES];
    }
    FTInnerLogDebug(@"[Flutter Session Replay] bridge configured, sampleRate:%d sessionReplayOnErrorSampleRate:%d",
                    self.sampleRate,
                    self.sessionReplayOnErrorSampleRate);
}

- (nullable NSDictionary<NSString *, id> *)currentRUMContext {
    NSDictionary *currentContext = [self currentContextSnapshot];
    if (!currentContext) {
        return nil;
    }
    NSMutableDictionary *context = [currentContext mutableCopy];
    id appId = currentContext[FT_APP_ID];
    id sessionId = currentContext[FT_RUM_KEY_SESSION_ID];
    id viewId = currentContext[FT_KEY_VIEW_ID];
    if (appId) {
        context[@"applicationId"] = appId;
    }
    if (sessionId) {
        context[@"sessionId"] = sessionId;
    }
    if (viewId) {
        context[@"viewId"] = viewId;
    }
    return [context copy];
}

- (void)setSampleStateChangedHandler:(FTSessionReplaySampleStateChangedHandler)handler {
    BOOL shouldNotify = NO;
    @synchronized (self.contextLock) {
        _sampleStateChangedHandler = [handler copy];
        shouldNotify = handler != nil && (self.configured || self.sampleStateEvaluated);
    }
    if (shouldNotify) {
        [self notifySampleStateChanged];
    }
}

- (void)setHasReplay:(NSDictionary<NSString *, id> *)context {
    NSString *viewId = [self stringForKey:@"viewId" inContext:context];
    NSNumber *hasReplayNumber = [self numberForKey:@"hasReplay" inContext:context] ?: @(YES);
    @synchronized (self.contextLock) {
        self.hasReplayRequested = hasReplayNumber.boolValue;
        self.hasReplayViewID = viewId;
    }
    [self postHasReplay:hasReplayNumber.boolValue viewID:viewId];
}

- (void)postHasReplay:(BOOL)hasReplay viewID:(nullable NSString *)viewId {
    FTFlutterSessionReplaySampleState sampleState = [self sampleStateValue];
    BOOL sampledForErrorReplay = sampleState == FTFlutterSessionReplaySampleStateError;
    BOOL effectiveHasReplay = hasReplay && sampleState != FTFlutterSessionReplaySampleStateNone;
    NSMutableDictionary *message = [@{
        FT_SESSION_HAS_REPLAY: @(effectiveHasReplay),
        FT_RUM_SESSION_REPLAY_SAMPLE_RATE: @(self.sampleRate),
        FT_RUM_SESSION_REPLAY_ON_ERROR_SAMPLE_RATE: @(self.sessionReplayOnErrorSampleRate),
        FT_RUM_KEY_SAMPLED_FOR_ERROR_REPLAY: @(sampledForErrorReplay)
    } mutableCopy];
    if (viewId.length > 0) {
        message[FT_KEY_VIEW_ID] = viewId;
    }
    [[FTModuleManager sharedInstance] postMessageWithKey:FTMessageKeySessionHasReplay message:message];
}

- (void)setRecordCount:(NSDictionary<NSString *, id> *)context {
    NSString *viewId = [self stringForKey:@"viewId" inContext:context];
    NSNumber *count = [self numberForKey:@"count" inContext:context];
    if (viewId.length == 0 || !count) {
        return;
    }
    @synchronized (self.recordsCountByViewID) {
        self.recordsCountByViewID[viewId] = @{
            FT_RECORDS_COUNT: count
        };
        [[FTModuleManager sharedInstance] postMessageWithKey:FTMessageKeyRecordsCountByViewID message:[self.recordsCountByViewID copy]];
    }
}

- (void)writeSegment:(NSDictionary<NSString *, id> *)context {
    NSString *segment = [self stringForKey:@"segment" inContext:context];
    NSString *viewId = [self stringForKey:@"viewId" inContext:context];
    if (segment.length == 0) {
        return;
    }
    NSData *data = [self normalizedSegmentDataFromSegment:segment viewID:viewId];
    if (!data) {
        return;
    }
#if FT_FLUTTER_SR_WRITER_AVAILABLE
    [self ensureNativeSessionReplayFeatures];
    FTFeatureScope *recordScope = self.recordScope;
    if (!recordScope) {
        FTInnerLogError(@"[Flutter Session Replay] Native segment writer is unavailable.");
        return;
    }
    if ([self sampleStateValue] == FTFlutterSessionReplaySampleStateNone) {
        FTInnerLogDebug(@"[Flutter Session Replay] Segment writer skipped for sample state:%ld", (long)[self sampleStateValue]);
        return;
    }
    dispatch_async(self.readWriteQueue, ^{
        @try {
            if ([self sampleStateValue] == FTFlutterSessionReplaySampleStateNone) {
                return;
            }
            BOOL forceNewFile = viewId.length > 0 && self.lastSegmentViewID.length > 0 && ![viewId isEqualToString:self.lastSegmentViewID];
            if (viewId.length > 0) {
                self.lastSegmentViewID = viewId;
            }
            [recordScope eventWriteContext:^(FTFeatureContext *featureContext, id<FTWriter> writer) {
                if (featureContext.trackingConsent == FTTrackingConsentNotGranted) {
                    return;
                }
                [writer write:data forceNewFile:forceNewFile];
            }];
        } @catch (NSException *exception) {
            FTInnerLogError(@"[Flutter Session Replay] write segment exception: %@", exception);
        }
    });
#else
    FTInnerLogError(@"[Flutter Session Replay] Native session replay writer is unavailable.");
#endif
}

- (void)telemetryDebug:(NSDictionary<NSString *, id> *)context {
    NSString *identifier = [self stringForKey:@"id" inContext:context] ?: @"debug";
    NSString *message = [self stringForKey:@"message" inContext:context] ?: @"";
    FTInnerLogDebug(@"[Flutter Session Replay][%@] %@", identifier, message);
}

- (void)telemetryError:(NSDictionary<NSString *, id> *)context {
    NSString *message = [self stringForKey:@"message" inContext:context] ?: @"";
    NSString *kind = [self stringForKey:@"kind" inContext:context] ?: @"error";
    NSString *stack = [self stringForKey:@"stack" inContext:context];
    if (stack.length > 0) {
        FTInnerLogError(@"[Flutter Session Replay][%@] %@\n%@", kind, message, stack);
    } else {
        FTInnerLogError(@"[Flutter Session Replay][%@] %@", kind, message);
    }
}

- (nullable id)saveImageResource:(NSDictionary<NSString *, id> *)context {
#if FT_FLUTTER_SR_WRITER_AVAILABLE
    if ([self sampleStateValue] == FTFlutterSessionReplaySampleStateNone) {
        return nil;
    }
#endif
    NSData *rgbaData = [self dataForKey:@"bytes" inContext:context];
    NSNumber *width = [self numberForKey:@"width" inContext:context];
    NSNumber *height = [self numberForKey:@"height" inContext:context];
    if (!rgbaData || !width || !height) {
        return nil;
    }
    NSData *pngData = [self pngDataFromRGBAData:rgbaData width:width.integerValue height:height.integerValue];
    if (!pngData) {
        FTInnerLogError(@"[Flutter Session Replay] Failed to encode image resource.");
        return nil;
    }
    NSString *resourceId = [self resourceIdentifierForData:pngData];
#if FT_FLUTTER_SR_WRITER_AVAILABLE
    [self ensureNativeSessionReplayFeatures];
    id<FTResourcesWriting> resourceWriter = self.resourceWriter;
    if (!resourceWriter) {
        FTInnerLogError(@"[Flutter Session Replay] Native resource writer is unavailable.");
        return resourceId;
    }
    NSDictionary *currentContext = [self currentRUMContext] ?: [self currentContextSnapshot];
    dispatch_async(self.readWriteQueue, ^{
        @try {
            FTEnrichedResource *resource = [[FTEnrichedResource alloc] init];
            resource.identifier = resourceId;
            resource.data = pngData;
            resource.mimeType = @"image/png";
            resource.appId = currentContext[FT_APP_ID] ?: currentContext[@"applicationId"];
            resource.bindInfo = currentContext[@"globalContext"] ?: currentContext[FT_LINK_RUM_KEYS];
            [resourceWriter write:@[resource]];
        } @catch (NSException *exception) {
            FTInnerLogError(@"[Flutter Session Replay] save image resource exception: %@", exception);
        }
    });
#endif
    return resourceId;
}

#pragma mark - FTMessageReceiver

- (void)receive:(NSString *)key message:(NSDictionary *)message {
    if ([key isEqualToString:FTMessageKeyRUMContext]) {
        NSDictionary *currentContext = [message copy];
        if (![self updateSampleStateWithRUMContext:currentContext force:NO]) {
            return;
        }
        NSDictionary *filteredContext = [self contextByFilteringLinkRUMKeys:currentContext];
        @synchronized (self.contextLock) {
            self.lastRUMContext = currentContext;
            self.currentContext = filteredContext;
        }
    } else if ([key isEqualToString:FTMessageKeySRSampleRateUpdate]) {
        [self handleSRSampleRateUpdateMessage];
    }
}

#pragma mark - Writer

#if FT_FLUTTER_SR_WRITER_AVAILABLE
- (void)ensureNativeSessionReplayFeatures {
    @synchronized (self) {
        if (self.recordScope && self.resourceWriter) {
            return;
        }
        FTTrackingConsentProvider trackingConsentProvider = [self trackingConsentProvider];
        if (!self.recordScope) {
            id<FTRemoteFeature> segmentFeature = [self segmentRemoteFeature];
            FTFlutterSessionReplayFeatureStore *segmentStore = [self registerFeature:segmentFeature];
            if (segmentStore.storage) {
                self.recordStorage = segmentStore.storage;
                self.recordScope = [[FTFeatureScope alloc] initWithStorage:segmentStore.storage
                                                    trackingConsentProvider:trackingConsentProvider];
                [self applySegmentWriterState];
            }
        }
        if (!self.resourceWriter) {
            FTResourcesFeature *resourcesFeature = [[FTResourcesFeature alloc] init];
            FTFlutterSessionReplayFeatureStore *resourceStore = [self registerFeature:resourcesFeature];
            if (resourceStore.storage) {
                FTFeatureDataStore *resourceDataStore = [[FTFeatureDataStore alloc] initWithFeature:resourcesFeature.name
                                                                                               queue:self.readWriteQueue
                                                                                           directory:self.coreDirectory.directory];
                self.resourceScope = [[FTFeatureScope alloc] initWithStorage:resourceStore.storage
                                                     trackingConsentProvider:trackingConsentProvider];
                self.resourceWriter = [[FTResourcesWriter alloc] initWithFeatureScope:self.resourceScope
                                                                            dataStore:resourceDataStore];
                [self applySegmentWriterState];
            }
        }
    }
}

- (FTTrackingConsentProvider)trackingConsentProvider {
    __weak typeof(self) weakSelf = self;
    return ^FTTrackingConsent {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return FTTrackingConsentNotGranted;
        }
        return [strongSelf trackingConsentForCurrentSampleState];
    };
}

- (FTTrackingConsent)trackingConsentForCurrentSampleState {
    FTFlutterSessionReplaySampleState sampleState = [self sampleStateValue];
    if (sampleState == FTFlutterSessionReplaySampleStateNormal) {
        return FTTrackingConsentGranted;
    }
    if (sampleState == FTFlutterSessionReplaySampleStateError) {
        return FTTrackingConsentErrorSampled;
    }
    return FTTrackingConsentNotGranted;
}

- (id<FTRemoteFeature>)segmentRemoteFeature {
    Class requestClass = NSClassFromString(@"FTSegmentRequest");
    id<FTFeatureRequestBuilder> requestBuilder = requestClass ? [[requestClass alloc] init] : nil;
    if (!requestBuilder) {
        FTInnerLogError(@"[Flutter Session Replay] FTSegmentRequest is unavailable.");
    }
    FTPerformancePresetOverride *override = [[FTPerformancePresetOverride alloc] initWithMeanFileAge:2 minUploadDelay:0.6];
    override.maxFileSize = FT_MAX_DATA_LENGTH;
    override.maxObjectSize = FT_MAX_DATA_LENGTH;
    override.initialUploadDelay = 1;
    override.uploadDelayChangeRate = 0.75;
    return [[FTFlutterSessionReplayRemoteFeature alloc] initWithName:@"session-replay"
                                                      requestBuilder:requestBuilder
                                                 performanceOverride:override];
}

- (nullable FTFlutterSessionReplayFeatureStore *)registerFeature:(id<FTRemoteFeature>)feature {
    if (!feature.name) {
        return nil;
    }
    FTFlutterSessionReplayFeatureStore *existingStore = self.stores[feature.name];
    if (existingStore) {
        return existingStore;
    }
    FTFeatureDirectories *directories = [self.coreDirectory featureDirectoriesForFeatureName:feature.name];
    if (!directories) {
        FTInnerLogError(@"[Flutter Session Replay] Failed to create feature directory: %@", feature.name);
        return nil;
    }
    FTPerformancePreset *performance = [self.performancePreset updateWithOverride:feature.performanceOverride];
    FTFeatureStorage *storage = [[FTFeatureStorage alloc] initWithFeatureName:feature.name
                                                                        queue:self.readWriteQueue
                                                                  directories:directories
                                                                  performance:performance];
    NSDictionary *context = [FTPresetProperty sharedInstance].sessionReplayTags ?: @{};
    if (!feature.requestBuilder) {
        FTInnerLogError(@"[Flutter Session Replay] Request builder is unavailable: %@", feature.name);
        return nil;
    }
    FTFeatureUpload *upload = [FTFeatureUpload createWithFeatureName:feature.name
                                                          fileReader:storage.reader
                                                         cacheWriter:storage.cacheWriter
                                                      requestBuilder:feature.requestBuilder
                                                 maxBatchesPerUpload:10
                                                         performance:performance
                                                             context:context];
    FTFlutterSessionReplayFeatureStore *store = [[FTFlutterSessionReplayFeatureStore alloc] initWithStorage:storage upload:upload];
    self.stores[feature.name] = store;
    return store;
}

- (FTCoreDirectory *)coreDirectory {
    if (!_coreDirectory) {
        _coreDirectory = [[FTCoreDirectory alloc] initWithSubdirectoryPath:@"com.ft"];
    }
    return _coreDirectory;
}
#endif

- (BOOL)updateSampleStateWithRUMContext:(NSDictionary<NSString *, id> *)context force:(BOOL)force {
    NSString *sessionID = [self stringForKey:FT_RUM_KEY_SESSION_ID inContext:context];
    NSDictionary *previousContext;
    NSString *previousSessionID;
    @synchronized (self.contextLock) {
        previousContext = self.lastRUMContext;
        previousSessionID = self.sampleStateSessionID;
    }
    if (!force && previousContext && [context isEqualToDictionary:previousContext]) {
        return NO;
    }
    if (!force && sessionID.length > 0 && [sessionID isEqualToString:previousSessionID]) {
        return YES;
    }
    BOOL isErrorSession = [context[FT_RUM_KEY_SAMPLED_FOR_ERROR_SESSION] boolValue];
    BOOL isNormalSampled = [self sampleRateAllows:self.sampleRate];
    BOOL isErrorSampled = isNormalSampled ? NO : [self sampleRateAllows:self.sessionReplayOnErrorSampleRate];
    BOOL needSampleForErrorReplay = (isErrorSession && isNormalSampled) || isErrorSampled;
    FTFlutterSessionReplaySampleState sampleState = needSampleForErrorReplay ? FTFlutterSessionReplaySampleStateError :
        (isNormalSampled ? FTFlutterSessionReplaySampleStateNormal : FTFlutterSessionReplaySampleStateNone);
    @synchronized (self.contextLock) {
        self.sampleStateSessionID = sessionID;
        self.sampleStateEvaluated = YES;
    }
    BOOL shouldNotify = force || sessionID.length == 0 || ![sessionID isEqualToString:previousSessionID];
    [self setSampleState:sampleState forceNotify:shouldNotify];
    return YES;
}

- (void)handleSRSampleRateUpdateMessage {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.readWriteQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        @try {
            [strongSelf evaluateSampleStateForSampleRateUpdate];
        } @catch (NSException *exception) {
            FTInnerLogError(@"[Flutter Session Replay] sample rate update exception: %@", exception);
        }
    });
}

- (void)evaluateSampleStateForSampleRateUpdate {
    [self mergeRemoteSessionReplaySampleRates];

    BOOL needUpdate = NO;
    FTFlutterSessionReplaySampleState sampleState = [self sampleStateValue];
    if (sampleState != FTFlutterSessionReplaySampleStateNone) {
        if (self.sampleRate == 0 && self.sessionReplayOnErrorSampleRate == 0) {
            needUpdate = YES;
        }
        if (sampleState == FTFlutterSessionReplaySampleStateError && self.sampleRate == 100) {
            needUpdate = YES;
        }
    } else {
        if (self.sampleRate == 100 || self.sessionReplayOnErrorSampleRate == 100) {
            needUpdate = YES;
        }
    }

    if (!needUpdate) {
        return;
    }

    NSDictionary *currentContext = [self currentContextSnapshot];
    if (currentContext) {
        [self updateSampleStateWithRUMContext:currentContext force:YES];
    }
    [self postStoredHasReplayState];
}

- (void)mergeRemoteSessionReplaySampleRates {
#if FT_FLUTTER_SR_REMOTE_CONFIG_AVAILABLE
    FTRemoteConfigModel *model = [FTRemoteConfigManager sharedInstance].lastRemoteModel;
    if (!model) {
        return;
    }

    NSNumber *remoteSampleRate = model.sessionReplaySampleRate;
    if (remoteSampleRate) {
        self.sampleRate = (int)(remoteSampleRate.doubleValue * 100);
    }
    NSNumber *remoteOnErrorSampleRate = model.sessionReplayOnErrorSampleRate;
    if (remoteOnErrorSampleRate) {
        self.sessionReplayOnErrorSampleRate = (int)(remoteOnErrorSampleRate.doubleValue * 100);
    }
#endif
}

- (void)postStoredHasReplayState {
    BOOL hasReplay = NO;
    NSString *viewID = nil;
    @synchronized (self.contextLock) {
        hasReplay = self.hasReplayRequested;
        viewID = self.hasReplayViewID;
    }
    if (viewID.length == 0) {
        viewID = [self stringForKey:FT_KEY_VIEW_ID inContext:[self currentContextSnapshot]];
    }
    [self postHasReplay:hasReplay viewID:viewID];
}

- (void)setSampleState:(FTFlutterSessionReplaySampleState)sampleState {
    [self setSampleState:sampleState forceNotify:NO];
}

- (void)setSampleState:(FTFlutterSessionReplaySampleState)sampleState forceNotify:(BOOL)forceNotify {
    BOOL didChange = NO;
    @synchronized (self.contextLock) {
        if (_sampleState != sampleState) {
            _sampleState = sampleState;
            didChange = YES;
        }
    }
    if (!didChange && !forceNotify) {
        return;
    }
#if FT_FLUTTER_SR_WRITER_AVAILABLE
    [self applySegmentWriterState];
#endif
    [self notifySampleStateChanged];
}

- (FTFlutterSessionReplaySampleState)sampleStateValue {
    @synchronized (self.contextLock) {
        return _sampleState;
    }
}

- (void)notifySampleStateChanged {
    FTSessionReplaySampleStateChangedHandler handler = nil;
    FTFlutterSessionReplaySampleState sampleState = FTFlutterSessionReplaySampleStateNone;
    @synchronized (self.contextLock) {
        handler = _sampleStateChangedHandler;
        sampleState = _sampleState;
    }
    if (!handler) {
        return;
    }
    NSDictionary<NSString *, id> *context = @{
        @"sampled": @(sampleState != FTFlutterSessionReplaySampleStateNone),
        @"sampledForErrorReplay": @(sampleState == FTFlutterSessionReplaySampleStateError)
    };
    dispatch_async(dispatch_get_main_queue(), ^{
        handler(context);
    });
}

- (BOOL)sampleRateAllows:(int)sampleRate {
    if (sampleRate <= 0) {
        return NO;
    }
    if (sampleRate < 100) {
        return arc4random_uniform(100) + 1 <= sampleRate;
    }
    return YES;
}

#if FT_FLUTTER_SR_WRITER_AVAILABLE
- (void)applySegmentWriterState {
    [self.recordScope updateTrackingConsent];
    [self.resourceScope updateTrackingConsent];
}
#endif

#pragma mark - Helpers

- (nullable NSDictionary<NSString *, id> *)currentContextSnapshot {
    @synchronized (self.contextLock) {
        return [self.currentContext copy];
    }
}

- (nullable NSDictionary<NSString *, id> *)lastRUMContextSnapshot {
    @synchronized (self.contextLock) {
        return [self.lastRUMContext copy];
    }
}

- (NSDictionary<NSString *, id> *)contextByFilteringLinkRUMKeys:(NSDictionary<NSString *, id> *)context {
    NSMutableDictionary<NSString *, id> *filteredContext = [context mutableCopy];
    id bindInfo = context[FT_LINK_RUM_KEYS] ?: context[@"globalContext"];
    [filteredContext removeObjectForKey:FT_LINK_RUM_KEYS];
    [filteredContext removeObjectForKey:@"globalContext"];
    NSDictionary *filteredBindInfo = [self filteredBindInfoFromBindInfo:bindInfo];
    if (filteredBindInfo) {
        filteredContext[FT_LINK_RUM_KEYS] = filteredBindInfo;
        filteredContext[@"globalContext"] = filteredBindInfo;
    }
    return [filteredContext copy];
}

- (nullable NSData *)normalizedSegmentDataFromSegment:(NSString *)segment viewID:(NSString *)viewID {
    NSData *data = [segment dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return nil;
    }
    NSError *jsonError = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
    if (![object isKindOfClass:[NSDictionary class]]) {
        FTInnerLogError(@"[Flutter Session Replay] Segment payload is not a JSON object.");
        return nil;
    }
    NSMutableDictionary *segmentJSON = [(NSDictionary *)object mutableCopy];
    if (!segmentJSON[@"viewID"]) {
        if (viewID.length > 0) {
            segmentJSON[@"viewID"] = viewID;
        }
    }
    if (!segmentJSON[FT_LINK_RUM_KEYS]) {
        id segmentGlobalContext = segmentJSON[@"globalContext"];
        if ([segmentGlobalContext isKindOfClass:[NSDictionary class]]) {
            segmentJSON[FT_LINK_RUM_KEYS] = segmentGlobalContext;
        }
    }
    [segmentJSON removeObjectForKey:@"globalContext"];
    if (!segmentJSON[@"source"]) {
        segmentJSON[@"source"] = @"flutter";
    }
    if (![self isValidSegmentJSON:segmentJSON]) {
        return nil;
    }
    NSData *normalizedData = [NSJSONSerialization dataWithJSONObject:segmentJSON options:0 error:&jsonError];
    return normalizedData ?: data;
}

- (BOOL)isValidSegmentJSON:(NSDictionary<NSString *, id> *)segmentJSON {
    if (![self isNonEmptyScalarValue:segmentJSON[@"applicationID"]] ||
        ![self isNonEmptyScalarValue:segmentJSON[@"sessionID"]] ||
        ![self isNonEmptyScalarValue:segmentJSON[@"viewID"]]) {
        FTInnerLogError(@"[Flutter Session Replay] Segment payload is missing applicationID, sessionID, or viewID.");
        return NO;
    }
    id recordsValue = segmentJSON[@"records"];
    if (![recordsValue isKindOfClass:[NSArray class]]) {
        FTInnerLogError(@"[Flutter Session Replay] Segment records payload is not an array.");
        return NO;
    }
    NSArray *records = (NSArray *)recordsValue;
    if (records.count == 0) {
        FTInnerLogError(@"[Flutter Session Replay] Segment records payload is empty.");
        return NO;
    }
    NSUInteger index = 0;
    for (id item in records) {
        if (![item isKindOfClass:[NSDictionary class]]) {
            FTInnerLogError(@"[Flutter Session Replay] Segment record at index %lu is not an object.", (unsigned long)index);
            return NO;
        }
        NSDictionary *record = (NSDictionary *)item;
        if (![self isNumberLikeValue:record[@"type"]] || ![self isNumberLikeValue:record[@"timestamp"]]) {
            FTInnerLogError(@"[Flutter Session Replay] Segment record at index %lu has invalid type or timestamp.", (unsigned long)index);
            return NO;
        }
        index++;
    }
    return YES;
}

- (BOOL)isNonEmptyScalarValue:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        return [(NSString *)value length] > 0;
    }
    if ([value respondsToSelector:@selector(stringValue)]) {
        return [[value stringValue] length] > 0;
    }
    return NO;
}

- (BOOL)isNumberLikeValue:(id)value {
    return [value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]];
}

- (nullable NSString *)stringForKey:(NSString *)key inContext:(NSDictionary<NSString *, id> *)context {
    id value = context[key];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    if ([value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    }
    return nil;
}

- (NSArray<NSString *> *)stringArrayFromValue:(id)value {
    if (![value isKindOfClass:[NSArray class]]) {
        return @[];
    }
    NSMutableArray<NSString *> *strings = [NSMutableArray array];
    for (id item in (NSArray *)value) {
        if ([item isKindOfClass:[NSString class]] && [(NSString *)item length] > 0) {
            [strings addObject:item];
        }
    }
    return [strings copy];
}

- (nullable NSDictionary<NSString *, id> *)filteredBindInfoFromBindInfo:(id)bindInfo {
    NSArray<NSString *> *linkKeys = self.enableLinkRUMKeys;
    if (linkKeys.count == 0 || ![bindInfo isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSDictionary *bindInfoDict = (NSDictionary *)bindInfo;
    NSMutableDictionary<NSString *, id> *filtered = [NSMutableDictionary dictionary];
    for (NSString *key in linkKeys) {
        id value = bindInfoDict[key];
        if (value) {
            filtered[key] = value;
        }
    }
    return filtered.count > 0 ? [filtered copy] : nil;
}

- (nullable NSNumber *)numberForKey:(NSString *)key inContext:(NSDictionary<NSString *, id> *)context {
    id value = context[key];
    if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    }
    if ([value isKindOfClass:[NSString class]]) {
        return @([(NSString *)value doubleValue]);
    }
    return nil;
}

- (nullable NSData *)dataForKey:(NSString *)key inContext:(NSDictionary<NSString *, id> *)context {
    id value = context[key];
    if ([value isKindOfClass:[FlutterStandardTypedData class]]) {
        return [(FlutterStandardTypedData *)value data];
    }
    if ([value isKindOfClass:[NSData class]]) {
        return value;
    }
    return nil;
}

- (nullable NSData *)pngDataFromRGBAData:(NSData *)rgbaData width:(NSInteger)width height:(NSInteger)height {
    if (width <= 0 || height <= 0) {
        return nil;
    }
    NSUInteger expectedLength = (NSUInteger)width * (NSUInteger)height * 4;
    if (rgbaData.length < expectedLength) {
        return nil;
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)rgbaData);
    if (!colorSpace || !provider) {
        if (provider) {
            CGDataProviderRelease(provider);
        }
        if (colorSpace) {
            CGColorSpaceRelease(colorSpace);
        }
        return nil;
    }
    CGImageRef imageRef = CGImageCreate((size_t)width,
                                        (size_t)height,
                                        8,
                                        32,
                                        (size_t)width * 4,
                                        colorSpace,
                                        kCGBitmapByteOrder32Big | kCGImageAlphaLast,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault);
    NSData *pngData = nil;
    if (imageRef) {
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        pngData = UIImagePNGRepresentation(image);
        CGImageRelease(imageRef);
    }
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return pngData;
}

- (NSString *)resourceIdentifierForData:(NSData *)data {
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString *hash = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", digest[i]];
    }
    return hash;
}

@end
