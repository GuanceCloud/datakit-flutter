import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ft_mobile_agent_flutter/const.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
import 'package:ft_mobile_agent_flutter/src/session_replay_platform.dart';
import 'package:http/io_client.dart';

/// flutter test --coverage
/// genhtml coverage/lcov.info -o coverage/html
///
/// report: coverage/html/lib/index.html
const initRouteName = "/";
const nextRouteName = "next_route";

const requestUrl = "https://docs.guance.com/";
const fakeToken = "fakeToken";

void main() {
  const MethodChannel channel = MethodChannel('ft_mobile_agent_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  const List<String> list = [
    methodConfig,
    methodSetDatakitUrl,
    methodSetDatawayUrl,
    methodUpdateRemoteConfig,
    methodUpdateRemoteConfigWithMiniUpdateInterval,
    methodBindUser,
    methodUnbindUser,
    methodLogConfig,
    methodLogging,
    methodLoggingWithStatusString,
    methodRumConfig,
    methodRumStartAction,
    methodRumAddAction,
    methodRumCreateView,
    methodRumStartView,
    methodRumStopView,
    methodRumAddError,
    methodRumStartResource,
    methodRumStopResource,
    methodRumAddResource,
    methodSessionReplayConfig,
    methodTraceConfig,
    methodGetTraceGetHeader,
  ];
  Map<String, bool> callResult = {};
  Map<String, dynamic>? lastMethodArguments;

  setUp(() async {
    FTSessionReplayManager().resetForTesting();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.arguments is Map) {
        lastMethodArguments = Map<String, dynamic>.from(
            methodCall.arguments as Map<dynamic, dynamic>);
      }
      switch (methodCall.method) {
        case methodConfig:
        case methodSetDatakitUrl:
        case methodSetDatawayUrl:
        case methodBindUser:
        case methodUnbindUser:
        case methodLogConfig:
        case methodLogging:
        case methodLoggingWithStatusString:
        case methodRumConfig:
        case methodRumStartAction:
        case methodRumAddAction:
        case methodRumCreateView:
        case methodRumStartView:
        case methodRumStopView:
        case methodRumAddError:
        case methodRumStartResource:
        case methodRumStopResource:
        case methodRumAddResource:
        case methodSessionReplayConfig:
        case methodTraceConfig:
        case methodGetTraceGetHeader:
          callResult[methodCall.method] = true;
          return null;
        case methodUpdateRemoteConfig:
        case methodUpdateRemoteConfigWithMiniUpdateInterval:
          callResult[methodCall.method] = true;
          return <String, dynamic>{
            'triggerType': 'manual',
            'success': true,
            'platform': 'android',
            'timestamp': 1,
          };
        default:
          return null;
      }
    });
  });

  test('Invoke All Channel ', () async {
    await FTMobileFlutter.sdkConfig(datakitUrl: requestUrl);
    await FTMobileFlutter.sdkConfig(
        datawayUrl: requestUrl, cliToken: fakeToken);
    await FTMobileFlutter.setDatakitURL(requestUrl);
    await FTMobileFlutter.setDatawayURL(requestUrl, fakeToken);
    await FTMobileFlutter.updateRemoteConfig();
    await FTMobileFlutter.updateRemoteConfigWithMiniUpdateInterval(0);
    await FTMobileFlutter.bindRUMUserData("userid");
    await FTMobileFlutter.unbindRUMUserData();

    await FTLogger().logConfig();
    await FTLogger().logging("content", FTLogStatus.info);
    await FTLogger().loggingWithStatusString("content", "custom");

    await FTRUMManager().setConfig();
    await FTRUMManager().startAction("click action", "click");
    await FTRUMManager().addAction("click action", "click");
    await FTRUMManager().createView("viewName", 1000);
    await FTRUMManager().starView("viewName");
    await FTRUMManager().stopView();
    await FTRUMManager().addCustomError("stack", "message");
    await FTRUMManager().startResource("key");
    await FTRUMManager().stopResource("key");
    await FTRUMManager().addResource(
        key: "key",
        url: requestUrl,
        httpMethod: "post",
        requestHeader: {},
        metrics: const FTRUMResourceMetrics(duration: 10));

    await FTSessionReplayManager().setConfig(FTSessionReplayConfig(
      sampleRate: 1.0,
      sessionReplayOnErrorSampleRate: 0.0,
      touchPrivacy: FTTouchPrivacyLevel.show,
      textAndInputPrivacy: FTTextAndInputPrivacyLevel.maskSensitiveInputs,
      imagePrivacy: FTImagePrivacyLevel.maskNone,
      enableLinkRUMKeys: const ["wgt_id"],
    ));

    await FTTracer().setConfig();
    await FTTracer().getTraceHeader(requestUrl, key: "key");

    for (final element in list) {
      expect(callResult[element], true);
    }
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
    final previousCallResult = Map<String, bool>.from(callResult);
    final previousArguments = lastMethodArguments;
    addTearDown(() {
      callResult
        ..clear()
        ..addAll(previousCallResult);
      lastMethodArguments = previousArguments;
    });

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
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(sessionReplayStateChannel, null);
    });

    final states = <FTSessionReplaySampleState>[];
    platform.setSampleStateChangedHandler(states.add);

    expect(platform.sessionReplaySampled, true);
    expect(platform.sessionReplaySampledForErrorReplay, false);

    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      'ft_mobile_agent_flutter/session_replay',
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

  test("Http Request Test", () async {
    await FTTracer().setConfig(enableAutoTrace: true);
    var httpClient = IOClient();

    final response = await httpClient.get(Uri.parse(requestUrl));
    expect(response.statusCode, 200);

    expect(callResult[methodTraceConfig], true);
    expect(callResult[methodGetTraceGetHeader], true);
    expect(callResult[methodRumStartResource], true);
    expect(callResult[methodRumStopResource], true);
    expect(callResult[methodRumAddResource], true);
  });

  test("LifeCycle Test", () {
    WidgetsBinding.instance
        .handleAppLifecycleStateChanged(AppLifecycleState.paused);

    expect(callResult[methodRumStopView], true);

    WidgetsBinding.instance
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    expect(callResult[methodRumStartView], true);

    callResult.clear();

    WidgetsBinding.instance
        .handleAppLifecycleStateChanged(AppLifecycleState.paused);

    WidgetsBinding.instance
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    expect(callResult.isEmpty, true);
  });

  testWidgets("Route Test", (widgetTester) async {
    await _buildRouteTestWidget(widgetTester);
    expect(callResult[methodRumStartView], true);
    expect(callResult[methodRumStopView], true);
  });

  testWidgets("Action Test", (widgetTester) async {
    await _buildActionTestWidget(widgetTester);
    expect(callResult[methodRumStartAction], true);
  });

  tearDown(() {
    FTSessionReplayManager().resetForTesting();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (null));
  });
}

Future<void> _buildRouteTestWidget(
  WidgetTester tester,
) async {
  await tester.pumpWidget(MaterialApp(
    navigatorObservers: [
      FTRouteObserver(),
    ],
    initialRoute: initRouteName,
    routes: {
      initRouteName: (context) => const MainPage(),
      nextRouteName: (context) => Container(),
    },
  ));
  var button = find.text('Navigate');

  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> _buildActionTestWidget(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    initialRoute: initRouteName,
    routes: {
      initRouteName: (context) => const MainPage(),
    },
  ));
  var button = find.text('Click');

  await tester.tap(button);
  await tester.pumpAndSettle();
}

class MainPage extends StatelessWidget {
  const MainPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          TextButton(
              onPressed: () {
                FTRUMManager().startAction("Action Name", "action_type");
              },
              child: const Text("Click")),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed(nextRouteName),
            child: const Text('Navigate'),
          )
        ],
      ),
    );
  }
}
