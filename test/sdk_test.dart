import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ft_mobile_agent_flutter/const.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
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
    lastMethodArguments = null;
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
    FTSessionReplay.resetForTesting();
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
