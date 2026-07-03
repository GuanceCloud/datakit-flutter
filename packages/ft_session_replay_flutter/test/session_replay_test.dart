import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ft_session_replay_flutter/ft_session_replay_flutter.dart';
import 'package:ft_session_replay_flutter/src/const.dart';
import 'package:ft_session_replay_flutter/src/rum_context.dart';
import 'package:ft_session_replay_flutter/src/session_replay_platform.dart';

void main() {
  const MethodChannel channel = MethodChannel('ft_session_replay_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  final callResult = <String, bool>{};
  Map<String, dynamic>? lastMethodArguments;

  setUp(() {
    FTSessionReplayManager().resetForTesting();
    callResult.clear();
    lastMethodArguments = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.arguments is Map) {
        lastMethodArguments = Map<String, dynamic>.from(
          methodCall.arguments as Map<dynamic, dynamic>,
        );
      }
      switch (methodCall.method) {
        case methodSessionReplayConfig:
          callResult[methodCall.method] = true;
          return null;
        case methodSessionReplayGetRumContext:
          return <String, dynamic>{
            'applicationId': 'app-id',
            'sessionId': 'session-id',
            'viewId': 'view-id',
          };
        default:
          return null;
      }
    });
  });

  tearDown(() {
    FTSessionReplayManager().resetForTesting();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(sessionReplayStateChannel, null);
  });

  test('Session Replay config payload', () async {
    await FTSessionReplayManager().setConfig(FTSessionReplayConfig(
      sampleRate: 0.75,
      sessionReplayOnErrorSampleRate: 0.25,
      touchPrivacy: FTTouchPrivacyLevel.hide,
      textAndInputPrivacy: FTTextAndInputPrivacyLevel.maskAllInputs,
      imagePrivacy: FTImagePrivacyLevel.maskAll,
      enableLinkRUMKeys: const ['session_id', 'view_id'],
    ));

    expect(callResult[methodSessionReplayConfig], true);
    expect(lastMethodArguments, <String, dynamic>{
      'sampleRate': 0.75,
      'sessionReplayOnErrorSampleRate': 0.25,
      'touchPrivacy': FTTouchPrivacyLevel.hide.index,
      'textAndInputPrivacy': FTTextAndInputPrivacyLevel.maskAllInputs.index,
      'imagePrivacy': FTImagePrivacyLevel.maskAll.index,
      'enableLinkRUMKeys': const ['session_id', 'view_id'],
    });
  });

  test('Session Replay config boundary payload', () async {
    await FTSessionReplayManager().setConfig(FTSessionReplayConfig(
      sampleRate: 0.0,
      sessionReplayOnErrorSampleRate: 1.0,
    ));

    expect(callResult[methodSessionReplayConfig], true);
    expect(lastMethodArguments, <String, dynamic>{
      'sampleRate': 0.0,
      'sessionReplayOnErrorSampleRate': 1.0,
      'touchPrivacy': FTTouchPrivacyLevel.hide.index,
      'textAndInputPrivacy': FTTextAndInputPrivacyLevel.maskAll.index,
      'imagePrivacy': FTImagePrivacyLevel.maskAll.index,
      'enableLinkRUMKeys': null,
    });
  });

  test('Session Replay config still applies when both sample rates are zero',
      () async {
    await FTSessionReplayManager().setConfig(FTSessionReplayConfig(
      sampleRate: 0.0,
      sessionReplayOnErrorSampleRate: 0.0,
    ));

    expect(callResult[methodSessionReplayConfig], true);
    expect(lastMethodArguments, <String, dynamic>{
      'sampleRate': 0.0,
      'sessionReplayOnErrorSampleRate': 0.0,
      'touchPrivacy': FTTouchPrivacyLevel.hide.index,
      'textAndInputPrivacy': FTTextAndInputPrivacyLevel.maskAll.index,
      'imagePrivacy': FTImagePrivacyLevel.maskAll.index,
      'enableLinkRUMKeys': null,
    });
    expect(FTSessionReplay.instance, isNotNull);
  });

  test(
      'Session Replay config still applies when sample rate is zero and error rate uses default',
      () async {
    await FTSessionReplayManager().setConfig(FTSessionReplayConfig(
      sampleRate: 0.0,
    ));

    expect(callResult[methodSessionReplayConfig], true);
    expect(lastMethodArguments, <String, dynamic>{
      'sampleRate': 0.0,
      'sessionReplayOnErrorSampleRate': null,
      'touchPrivacy': FTTouchPrivacyLevel.hide.index,
      'textAndInputPrivacy': FTTextAndInputPrivacyLevel.maskAll.index,
      'imagePrivacy': FTImagePrivacyLevel.maskAll.index,
      'enableLinkRUMKeys': null,
    });
    expect(FTSessionReplay.instance, isNotNull);
  });

  test('Session Replay config only applies once', () async {
    await FTSessionReplayManager().setConfig(FTSessionReplayConfig(
      sampleRate: 0.0,
      sessionReplayOnErrorSampleRate: 0.0,
    ));
    final firstReplay = FTSessionReplay.instance;
    expect(callResult[methodSessionReplayConfig], true);
    expect(firstReplay, isNotNull);

    callResult.clear();
    lastMethodArguments = null;

    await FTSessionReplayManager().setConfig(FTSessionReplayConfig(
      sampleRate: 1.0,
      sessionReplayOnErrorSampleRate: 0.0,
    ));

    expect(callResult[methodSessionReplayConfig], isNull);
    expect(FTSessionReplay.instance, same(firstReplay));

    FTSessionReplayManager().resetForTesting();
    callResult.clear();
    lastMethodArguments = null;

    await FTSessionReplayManager().setConfig(FTSessionReplayConfig(
      sampleRate: 1.0,
      sessionReplayOnErrorSampleRate: 0.0,
    ));
    final replay = FTSessionReplay.instance;
    expect(callResult[methodSessionReplayConfig], true);
    expect(replay, isNotNull);

    callResult.clear();
    lastMethodArguments = null;
    await FTSessionReplayManager().setConfig(FTSessionReplayConfig(
      sampleRate: 0.0,
      sessionReplayOnErrorSampleRate: 0.0,
    ));

    expect(callResult[methodSessionReplayConfig], isNull);
    expect(lastMethodArguments, isNull);
    expect(FTSessionReplay.instance, same(replay));
  });

  test('Session Replay sample state malformed payload is not sampled',
      () async {
    final previousPlatform = FTSessionReplayPlatform.instance;
    final platform = FTMethodChannelSessionReplayPlatform();
    FTSessionReplayPlatform.instance = platform;
    addTearDown(() {
      FTSessionReplayPlatform.instance = previousPlatform;
    });

    final states = <FTSessionReplaySampleState>[];
    platform.setSampleStateChangedHandler(states.add);

    expect(platform.sessionReplaySampled, true);
    expect(platform.sessionReplaySampledForErrorReplay, false);

    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      'ft_session_replay_flutter/session_replay',
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall(
          methodSessionReplaySampleStateChanged,
          <String, dynamic>{},
        ),
      ),
      (_) {},
    );

    expect(platform.sessionReplaySampled, false);
    expect(platform.sessionReplaySampledForErrorReplay, false);
    expect(states, hasLength(1));
    expect(states.single.sampled, false);
    expect(states.single.sampledForErrorReplay, false);
  });

  test('Session Replay current context parses linked RUM keys', () async {
    final previousPlatform = FTSessionReplayPlatform.instance;
    final platform = FTMethodChannelSessionReplayPlatform();
    FTSessionReplayPlatform.instance = platform;
    var linkContextField = 'globalContext';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == methodSessionReplayGetRumContext) {
        return <String, dynamic>{
          'applicationId': 'app-id',
          'sessionId': 'session-id',
          'viewId': 'view-id',
          linkContextField: <String, dynamic>{
            'wgt_id': 'widget-id',
            'rum_key': 'rum-value',
          },
        };
      }
      return null;
    });
    addTearDown(() {
      FTSessionReplayPlatform.instance = previousPlatform;
    });

    for (final field in <String>['globalContext', 'bindInfo']) {
      linkContextField = field;
      final context = await platform.getCurrentContext();

      expect(context, isNotNull);
      expect(context!.globalContext, <String, Object?>{
        'wgt_id': 'widget-id',
        'rum_key': 'rum-value',
      });
    }
  });

  testWidgets('SessionReplayCapture records when config is applied after mount',
      (tester) async {
    final previousPlatform = FTSessionReplayPlatform.instance;
    final platform = _RecordingSessionReplayPlatform();
    FTSessionReplayPlatform.instance = platform;
    addTearDown(() {
      FTSessionReplayPlatform.instance = previousPlatform;
    });

    try {
      await tester.pumpWidget(
        SessionReplayCapture(
          key: const ValueKey<String>('session-replay-root'),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 100,
              height: 100,
              child: ColoredBox(
                color: Color(0xFFFFFFFF),
                child: Text('Replay me'),
              ),
            ),
          ),
        ),
      );

      await FTSessionReplayManager().setConfig(FTSessionReplayConfig());
      await tester.pump(FTSessionReplay.minCaptureTiming * 2);
      await tester.pump();

      expect(platform.segments, isNotEmpty);
    } finally {
      FTSessionReplayManager().resetForTesting();
    }
  });
}

class _RecordingSessionReplayPlatform extends FTSessionReplayPlatform {
  final List<String> segments = <String>[];

  @override
  Future<bool> enable(
    Map<String, dynamic> configuration,
    void Function(RUMContext p1) onContextChanged,
  ) async {
    return true;
  }

  @override
  Future<RUMContext?> getCurrentContext() async {
    return RUMContext(
      applicationId: 'app-id',
      sessionId: 'session-id',
      viewId: 'view-id',
    );
  }

  @override
  Future<void> writeSegment(String record, String viewId) async {
    segments.add(record);
  }
}
