import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('ft_mobile_agent_flutter');
  TestWidgetsFlutterBinding.ensureInitialized();
  const METHOD_CONFIG = "ftConfig";
  const METHOD_BIND_USER = "ftBindUser";
  const METHOD_UNBIND_USER = "ftUnBindUser";
  const METHOD_UNBIND_LOGGING = "ftLogging";
  dynamic resultCode;
  setUp(() async {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case METHOD_CONFIG:
        case METHOD_BIND_USER:
        case METHOD_UNBIND_USER:
        case METHOD_UNBIND_LOGGING:
          resultCode = true;
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
