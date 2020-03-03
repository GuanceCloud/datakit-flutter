import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent.dart';

void main() {
  const MethodChannel channel = MethodChannel('agent');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
//    expect(await FTMobileAgentFlutter.platformVersion, '42');
  });
}
