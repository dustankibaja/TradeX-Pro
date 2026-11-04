import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_trade/features/engine_status/engine_status_screen.dart';

void main() {
  testWidgets('Emtifize engine pairing screen renders safely', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: EngineStatusScreen()),
    );
    expect(find.text('Connect your MT5 bot'), findsOneWidget);
    expect(find.text('Check connection'), findsOneWidget);
    expect(find.text('Not connected'), findsOneWidget);
  });
}
