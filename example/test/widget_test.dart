import 'package:agent_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Example app shows SDK feature entries',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pump();

    expect(find.text('Plugin Example App'), findsOneWidget);
    expect(find.text('Log Output'), findsOneWidget);
    expect(find.text('RUM Data Collection'), findsOneWidget);
    expect(find.text('Session Replay'), findsOneWidget);
  });
}
