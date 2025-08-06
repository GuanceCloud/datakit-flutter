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

const requestUrl = "https://docs.truewatch.com/";
const fakeToken = "fakeToken";

void main() {
  const MethodChannel channel = MethodChannel('ft_mobile_agent_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  const List<String> list = [
    methodConfig,
    methodBindUser,
    methodUnbindUser,
    methodLogConfig,
    methodLogging,
    methodRumConfig,
    methodRumAddAction,
    methodRumCreateView,
    methodRumStartView,
    methodRumStopView,
    methodRumAddError,
    methodRumStartResource,
    methodRumStopResource,
    methodRumAddResource,
    methodTraceConfig,
    methodGetTraceGetHeader,
  ];
  Map<String, bool> callResult = {};

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case methodConfig:
        case methodBindUser:
        case methodUnbindUser:
        case methodLogConfig:
        case methodLogging:
        case methodRumConfig:
        case methodRumAddAction:
        case methodRumCreateView:
        case methodRumStartView:
        case methodRumStopView:
        case methodRumAddError:
        case methodRumStartResource:
        case methodRumStopResource:
        case methodRumAddResource:
        case methodTraceConfig:
        case methodGetTraceGetHeader:
          callResult[methodCall.method] = true;
          return null;
        default:
          return null;
      }
    });
  });

  test('Invoke All Channel ', () async {
    await FTMobileFlutter.sdkConfig(datakitUrl: requestUrl);
    await FTMobileFlutter.sdkConfig(
        datawayUrl: requestUrl, cliToken: fakeToken);
    await FTMobileFlutter.bindRUMUserData("userid");
    await FTMobileFlutter.unbindRUMUserData();

    await FTLogger().logConfig();
    await FTLogger().logging("content", FTLogStatus.info);

    await FTRUMManager().setConfig();
    await FTRUMManager().startAction("click action", "click");
    await FTRUMManager().createView("viewName", 1000);
    await FTRUMManager().starView("viewName");
    await FTRUMManager().stopView();
    await FTRUMManager().addCustomError("stack", "message");
    await FTRUMManager().startResource("key");
    await FTRUMManager().stopResource("key");
    await FTRUMManager().addResource(
        key: "key", url: requestUrl, httpMethod: "post", requestHeader: {});

    await FTTracer().setConfig();
    await FTTracer().getTraceHeader(requestUrl, key: "key");

    list.forEach((element) async {
      expect(callResult[element], true);
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
    expect(callResult[methodRumAddAction], true);
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
