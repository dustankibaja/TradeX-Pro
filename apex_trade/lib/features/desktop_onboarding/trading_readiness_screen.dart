import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'onboarding_client.dart';

class TradingReadinessScreen extends StatelessWidget {
  const TradingReadinessScreen({
    super.key,
    required this.verification,
    required this.onHome,
  });

  final DemoVerification verification;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Row(
      children: [
        Container(
          width: 260,
          color: AppColors.bg1,
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Emtifize AI',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 42),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: const Icon(Icons.home_rounded),
                  title: const Text('Home'),
                  onTap: onHome,
                ),
              ),
              const Material(
                color: Colors.transparent,
                child: ListTile(
                  selected: true,
                  leading: Icon(Icons.verified_user_outlined),
                  title: Text('Trading readiness'),
                ),
              ),
              const Spacer(),
              const Text(
                'PRE-EXECUTION ONLY',
                style: TextStyle(
                  color: AppColors.amber,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(42),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trading readiness',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Read-only checks for a future, separately authorized DEMO smoke test. This screen cannot submit an order.',
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _status(
                      'Account',
                      verification.accountLabel,
                      verification.verified,
                    ),
                    _status(
                      'Broker',
                      verification.server,
                      verification.verified,
                    ),
                    _status('Execution', 'Locked', false),
                  ],
                ),
                const SizedBox(height: 26),
                ...verification.checks.map(
                  (check) => Card(
                    child: ListTile(
                      leading: Icon(
                        check.passed ? Icons.check_circle : Icons.error_outline,
                        color: check.passed ? AppColors.green : AppColors.amber,
                      ),
                      title: Text(
                        check.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(check.detail),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  color: AppColors.amber.withValues(alpha: .08),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline, color: AppColors.amber),
                        const SizedBox(width: 14),
                        Expanded(child: Text(verification.blockedReason)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Required before a supervised DEMO proposal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Fresh defensible quote time · trading permissions · account/terminal pin · contract and filling rules · spread, risk and margin · zero unreconciled intents · local operator authorization.',
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.lock),
                  label: const Text('Order submission unavailable'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _status(String label, String value, bool passed) => SizedBox(
    width: 250,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.text3)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: passed ? AppColors.green : AppColors.amber,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
