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
    methodRumAddLongTask,
    methodRumStartResource,
    methodRumStopResource,
    methodRumAddResource,
    methodTraceConfig,
    methodGetTraceGetHeader,
  ];
  Map<String, bool> callResult = {};
  List<MethodCall> calls = [];

  setUp(() async {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      calls.add(methodCall);
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
        case methodRumAddLongTask:
        case methodRumStartResource:
        case methodRumStopResource:
        case methodRumAddResource:
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
    await FTRUMManager().addLongTask("stack", 1000000);
    await FTRUMManager().startResource("key");
    await FTRUMManager().stopResource("key");
    await FTRUMManager().addResource(
        key: "key",
        url: requestUrl,
        httpMethod: "post",
        requestHeader: {},
        metrics: const FTRUMResourceMetrics(duration: 10));

    await FTTracer().setConfig();
    await FTTracer().getTraceHeader(requestUrl, key: "key");

    for (final element in list) {
      expect(callResult[element], true);
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

  test('addLongTask passes duration in nanoseconds', () async {
    await FTRUMManager().addLongTask("flutter_manual_long_task", 123000000);

    final call = calls.singleWhere(
      (call) => call.method == methodRumAddLongTask,
    );
    expect(call.arguments['stack'], 'flutter_manual_long_task');
    expect(call.arguments['duration'], 123000000);
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
