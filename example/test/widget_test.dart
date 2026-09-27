import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';
import 'package:thinking_orbs/thinking_orbs.dart';

void main() {
  testWidgets('ThinkingOrbs gallery smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ThinkingOrbsDemoApp());
    expect(find.byType(ThinkingOrb), findsWidgets);
    expect(find.text('Thinking Orbs'), findsOneWidget);
  });
}
