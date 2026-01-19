import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalby2heart/main.dart';

void main() {
  testWidgets(
      'Shows main UI in offline mode when Firebase is uninitialized (test-only flag)',
      (WidgetTester tester) async {
    // Pump just the AuthGate with forceOffline to simulate uninitialized Firebase.
    await tester
        .pumpWidget(const MaterialApp(home: AuthGate(forceOffline: true)));
    await tester.pumpAndSettle();

    // The main UI should render (AppBar title present) and the test should not crash.
    expect(find.widgetWithText(AppBar, 'Qalby2Heart'), findsOneWidget);

    // Offline banner should be visible
    expect(find.text('Offline: Firebase not configured'), findsOneWidget);

    // Verify that the Home tab label exists
    expect(find.text('Home'), findsOneWidget);
  });
}
