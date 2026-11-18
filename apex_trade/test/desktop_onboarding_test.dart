import 'package:apex_trade/features/desktop_onboarding/desktop_account_store.dart';
import 'package:apex_trade/features/desktop_onboarding/desktop_onboarding_screen.dart';
import 'package:apex_trade/features/desktop_onboarding/onboarding_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeClient implements OnboardingClient {
  @override
  Future<List<String>> detectTerminals() async => [
    r'C:\Program Files\MetaTrader 5\terminal64.exe',
  ];

  @override
  Future<DemoVerification> verifyDemo(
    String terminalPath,
  ) async => DemoVerification(
    verified: true,
    terminalPath: terminalPath,
    accountFingerprint: 'a' * 64,
    accountLabel: '••••5678',
    server: 'Broker-Demo',
    blockedReason: 'DEMO execution stays locked until safety review passes.',
    checks: const [
      OnboardingCheck(
        name: 'Account type',
        passed: true,
        detail: 'Verified DEMO',
      ),
      OnboardingCheck(
        name: 'Execution clock',
        passed: false,
        detail:
            'Quote-time certification is still required before DEMO execution',
      ),
    ],
  );
}

class MemoryStore implements DesktopAccountStore {
  DemoVerification? saved;

  @override
  Future<void> save(DemoVerification verification) async =>
      saved = verification;
}

void main() {
  testWidgets(
    'Windows first-run wizard verifies demo and keeps execution locked',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = MemoryStore();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          home: DesktopOnboardingScreen(client: FakeClient(), store: store),
        ),
      );

      expect(find.text('Welcome to Emtifize AI'), findsOneWidget);
      expect(find.text('DEMO accounts only'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Find MetaTrader 5'));
      await tester.pumpAndSettle();

      expect(find.text('Choose your MetaTrader 5 terminal'), findsOneWidget);
      await tester.tap(find.text('Verify my DEMO account'));
      await tester.pumpAndSettle();

      expect(find.text('Your DEMO account is connected'), findsOneWidget);
      expect(find.text('Verified DEMO'), findsOneWidget);
      expect(store.saved?.verified, isTrue);
      await tester.tap(find.text('Open dashboard'));
      await tester.pumpAndSettle();

      expect(find.text('DEMO verified'), findsOneWidget);
      expect(find.text('Automation'), findsOneWidget);
      expect(find.text('Locked'), findsOneWidget);
      expect(find.text('Setup complete'), findsOneWidget);
      await tester.tap(find.text('Trading readiness'));
      await tester.pumpAndSettle();
      expect(find.text('PRE-EXECUTION ONLY'), findsOneWidget);
      expect(find.text('Order submission unavailable'), findsOneWidget);
      expect(find.text('Quote-time certification is still required before DEMO execution'), findsOneWidget);
    },
  );

  test(
    'verification parser rejects responses that try to enable execution',
    () {
      final parsed = DemoVerification.fromJson({
        'schema': 'emtifize-onboarding-v1',
        'account_verified': true,
        'demo_only': true,
        'execution_allowed': true,
        'checks': <Map<String, dynamic>>[],
      });
      expect(parsed.verified, isFalse);
    },
  );
}
