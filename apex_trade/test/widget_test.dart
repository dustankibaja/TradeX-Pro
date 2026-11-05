import 'package:apex_trade/features/engine_status/engine_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('single-screen DEMO bot console starts disconnected',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: EngineStatusScreen()),
    );
    // Startup checks encrypted local storage before showing the pairing form.
    await tester.pumpAndSettle();

    expect(find.text('Emtifize AI'), findsOneWidget);
    expect(find.text('Private bot control center'), findsOneWidget);
    expect(find.text('Connect securely'), findsOneWidget);
    expect(find.text('DISCONNECTED'), findsOneWidget);
    expect(find.text('Signals'), findsNothing);
    expect(find.text('Subscription'), findsNothing);
    expect(find.text('Trade now'), findsNothing);
  });
}
