import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('ft_mobile_agent_flutter');
  TestWidgetsFlutterBinding.ensureInitialized();
  const METHOD_CONFIG = "ftConfig";
  const METHOD_BIND_USER = "ftBindUser";
  const METHOD_UNBIND_USER = "ftUnBindUser";
  const METHOD_UNBIND_LOGGING = "ftLogging";

  const METHOD_LOG_CONFIG = "ftLogConfig";
  const METHOD_LOGGING = "ftLogging";

  const METHOD_RUM_CONFIG = "ftRumConfig";
  const METHOD_RUM_ADD_ACTION = "ftRumAddAction";
  const METHOD_RUM_CREATE_VIEW = "ftRumCreateView";
  const METHOD_RUM_START_VIEW = "ftRumStartView";
  const METHOD_RUM_STOP_VIEW = "ftRumStopView";
  const METHOD_RUM_ADD_ERROR = "ftRumAddError";
  const METHOD_RUM_START_RESOURCE = "ftRumStartResource";
  const METHOD_RUM_STOP_RESOURCE = "ftRumStopResource";
  const METHOD_RUM_ADD_RESOURCE = "ftRumAddResource";

  const METHOD_TRACE_CONFIG = "ftTraceConfig";
  const METHOD_GET_TRACE_HEADER = "ftTraceGetHeader";

  const List<String> list = [
    METHOD_CONFIG,
    METHOD_BIND_USER,
    METHOD_UNBIND_USER,
    METHOD_UNBIND_LOGGING,
    METHOD_LOG_CONFIG,
    METHOD_LOGGING,
    METHOD_RUM_CONFIG,
    METHOD_RUM_ADD_ACTION,
    METHOD_RUM_CREATE_VIEW,
    METHOD_RUM_START_VIEW,
    METHOD_RUM_STOP_VIEW,
    METHOD_RUM_ADD_ERROR,
    METHOD_RUM_START_RESOURCE,
    METHOD_RUM_STOP_RESOURCE,
    METHOD_RUM_ADD_RESOURCE,
    METHOD_TRACE_CONFIG,
    METHOD_GET_TRACE_HEADER,
  ];
  Map<String, bool> callResult = {};

  setUp(() async {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case METHOD_CONFIG:
        case METHOD_BIND_USER:
        case METHOD_UNBIND_USER:
        case METHOD_UNBIND_LOGGING:
        case METHOD_LOG_CONFIG:
        case METHOD_LOGGING:
        case METHOD_RUM_CONFIG:
        case METHOD_RUM_ADD_ACTION:
        case METHOD_RUM_CREATE_VIEW:
        case METHOD_RUM_START_VIEW:
        case METHOD_RUM_STOP_VIEW:
        case METHOD_RUM_ADD_ERROR:
        case METHOD_RUM_START_RESOURCE:
        case METHOD_RUM_STOP_RESOURCE:
        case METHOD_RUM_ADD_RESOURCE:
        case METHOD_TRACE_CONFIG:
        case METHOD_GET_TRACE_HEADER:
          callResult[methodCall.method] = true;
          return null;
        default:
          return null;
      }
    });
  });

  test('test all channel available', () {
    list.forEach((element) async {
      await channel.invokeListMethod(element);
      expect(callResult[element], true);
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
