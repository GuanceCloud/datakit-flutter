import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ft_mobile_agent_flutter/const.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('ft_mobile_agent_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  const List<String> list = [
    methodConfig,
    methodBindUser,
    methodUnbindUser,
    methodLogConfig,
    methodLog,
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
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case methodConfig:
        case methodBindUser:
        case methodUnbindUser:
        case methodLogConfig:
        case methodLog:
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

  test('invoke all channel ', () async {
    await FTMobileFlutter.sdkConfig(serverUrl: "http://test.url");
    await FTMobileFlutter.bindRUMUserData("userid");
    await FTMobileFlutter.unbindRUMUserData();

    await FTLogger().logConfig();
    await FTLogger().logging("content", FTLogStatus.info);

    await FTRUMManager().setConfig();
    await FTRUMManager().startAction("click", "click action");
    await FTRUMManager().createView("viewName", 1000);
    await FTRUMManager().starView("viewName");
    await FTRUMManager().stopView();
    await FTRUMManager().addCustomError("stack", "message");
    await FTRUMManager().startResource("key");
    await FTRUMManager().stopResource("key");
    await FTRUMManager().addResource(
        key: "key",
        url: "http://test.url",
        httpMethod: "post",
        requestHeader: {});

    await FTTracer().setConfig();
    await FTTracer().getTraceHeader("key", "http://test.url");

    list.forEach((element) async {
      print("$element:${callResult[element]}");
      expect(callResult[element], true);
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
