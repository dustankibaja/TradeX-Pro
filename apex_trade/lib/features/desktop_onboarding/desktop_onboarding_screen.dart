import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'desktop_account_store.dart';
import 'onboarding_client.dart';
import 'trading_readiness_screen.dart';
import '../strategy_studio/strategy_studio_screen.dart';
import '../backtesting/backtest_screen.dart';

class DesktopOnboardingScreen extends StatefulWidget {
  const DesktopOnboardingScreen({
    super.key,
    this.client = const LocalOnboardingClient(),
    this.store = const ProtectedDesktopAccountStore(),
  });

  final OnboardingClient client;
  final DesktopAccountStore store;

  @override
  State<DesktopOnboardingScreen> createState() =>
      _DesktopOnboardingScreenState();
}

class _DesktopOnboardingScreenState extends State<DesktopOnboardingScreen> {
  int _step = 0;
  bool _busy = false;
  List<String> _terminals = const [];
  String? _selectedTerminal;
  DemoVerification? _verification;
  String? _error;
  bool _showStrategyStudio = false;
  bool _showBacktests = false;
  bool _showReadiness = false;

  Future<void> _detect() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final terminals = await widget.client.detectTerminals();
      if (!mounted) return;
      setState(() {
        _terminals = terminals;
        _selectedTerminal = terminals.isEmpty ? null : terminals.first;
        _step = 1;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _step = 1;
          _error =
              'The local safety service is unavailable. Reinstall Emtifize AI, then try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    final terminal = _selectedTerminal;
    if (terminal == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _verification = null;
    });
    try {
      final verification = await widget.client.verifyDemo(terminal);
      if (!mounted) return;
      setState(() {
        _verification = verification;
        _step = 2;
      });
      if (verification.verified) {
        await widget.store.save(verification);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _step = 2;
          _error =
              'We could not verify MetaTrader 5. Keep it open on your DEMO account and try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showReadiness && _verification != null) {
      return TradingReadinessScreen(
        verification: _verification!,
        onHome: () => setState(() => _showReadiness = false),
      );
    }
    if (_showBacktests) {
      return BacktestScreen(
        onHome: () => setState(() => _showBacktests = false),
      );
    }
    if (_showStrategyStudio) {
      return StrategyStudioScreen(
        onHome: () => setState(() => _showStrategyStudio = false),
        onBacktests: () => setState(() {
          _showStrategyStudio = false;
          _showBacktests = true;
        }),
      );
    }
    if (_step == 3 && _verification != null) return _dashboard(_verification!);
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 300,
            color: AppColors.bg1,
            padding: const EdgeInsets.fromLTRB(32, 42, 28, 28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Brand(),
                  const SizedBox(height: 56),
                  _progressItem(0, 'Welcome', 'Your private DEMO workspace'),
                  _progressItem(
                    1,
                    'Find MetaTrader 5',
                    'Use your installed terminal',
                  ),
                  _progressItem(
                    2,
                    'Verify DEMO account',
                    'Read-only safety checks',
                  ),
                  _progressItem(3, 'Dashboard', 'Trading remains locked'),
                  const SizedBox(height: 28),
                  const Text(
                    'BETA · DEMO ONLY',
                    style: TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your brokerage password never enters Emtifize AI.',
                    style: TextStyle(color: AppColors.text3, height: 1.45),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: _content(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() => switch (_step) {
    0 => _welcome(),
    1 => _terminal(),
    _ => _verificationView(),
  };

  Widget _welcome() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _Eyebrow('FIRST-RUN SETUP'),
      const SizedBox(height: 18),
      const Text(
        'Welcome to Emtifize AI',
        style: TextStyle(
          fontSize: 42,
          color: AppColors.text1,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.4,
        ),
      ),
      const SizedBox(height: 18),
      const Text(
        'Connect the MetaTrader 5 DEMO account that is already open on this computer. '
        'We will check it without switching accounts, storing a password, or placing a trade.',
        style: TextStyle(fontSize: 18, color: AppColors.text2, height: 1.55),
      ),
      const SizedBox(height: 34),
      _notice(
        Icons.shield_outlined,
        'DEMO accounts only',
        'Funded and contest accounts are technically rejected by the local safety service.',
      ),
      const SizedBox(height: 14),
      _notice(
        Icons.computer_outlined,
        'Local-first and private',
        'Your terminal and verified configuration stay on this Windows computer.',
      ),
      const SizedBox(height: 36),
      _primaryButton('Find MetaTrader 5', _busy ? null : _detect),
    ],
  );

  Widget _terminal() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _Eyebrow('STEP 2 OF 3'),
      const SizedBox(height: 16),
      const Text(
        'Choose your MetaTrader 5 terminal',
        style: TextStyle(
          fontSize: 32,
          color: AppColors.text1,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        'Keep the official broker terminal open and signed in to your DEMO account.',
        style: TextStyle(fontSize: 16, color: AppColors.text2),
      ),
      const SizedBox(height: 28),
      if (_terminals.isEmpty)
        _emptyTerminal()
      else ...[
        RadioGroup<String>(
          groupValue: _selectedTerminal,
          onChanged: (value) => setState(() => _selectedTerminal = value),
          child: Column(
            children: _terminals
                .map(
                  (path) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RadioListTile<String>(
                      value: path,
                      title: const Text(
                        'MetaTrader 5',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        path,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      tileColor: AppColors.bg1,
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
        const SizedBox(height: 18),
        _primaryButton('Verify my DEMO account', _busy ? null : _verify),
      ],
      if (_error != null) _errorBox(_error!),
    ],
  );

  Widget _verificationView() {
    final verification = _verification;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Eyebrow('SAFETY CHECK'),
        const SizedBox(height: 16),
        Text(
          verification?.verified == true
              ? 'Your DEMO account is connected'
              : 'We need your attention',
          style: const TextStyle(
            fontSize: 32,
            color: AppColors.text1,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 22),
        if (verification != null) ...[
          ...verification.checks.map((check) => _checkRow(check)),
          const SizedBox(height: 18),
          _blockedCard(verification.blockedReason),
        ],
        if (_error != null) _errorBox(_error!),
        const SizedBox(height: 26),
        if (verification?.verified == true)
          _primaryButton('Open dashboard', () => setState(() => _step = 3))
        else
          _primaryButton('Try again', _busy ? null : _verify),
      ],
    );
  }

  Widget _dashboard(DemoVerification value) => Scaffold(
    body: Row(
      children: [
        Container(
          width: 260,
          color: AppColors.bg1,
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Brand(),
              const SizedBox(height: 42),
              _nav(Icons.home_rounded, 'Home', true),
              _nav(Icons.hub_outlined, 'Connect account', false),
              _nav(
                Icons.auto_awesome_outlined,
                'Strategy Studio',
                false,
                onTap: () => setState(() => _showStrategyStudio = true),
              ),
              _nav(
                Icons.query_stats_outlined,
                'Backtests',
                false,
                onTap: () => setState(() => _showBacktests = true),
              ),
              _nav(
                Icons.verified_user_outlined,
                'Trading readiness',
                false,
                onTap: () => setState(() => _showReadiness = true),
              ),
              const Spacer(),
              const Text(
                'Execution locked',
                style: TextStyle(
                  color: AppColors.amber,
                  fontWeight: FontWeight.w700,
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
                  'Good to see you',
                  style: TextStyle(
                    fontSize: 32,
                    color: AppColors.text1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${value.accountLabel} · ${value.server}',
                  style: const TextStyle(color: AppColors.text2, fontSize: 16),
                ),
                const SizedBox(height: 30),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _metric('Account', 'DEMO verified', AppColors.green),
                    _metric('Runtime', 'Paused', AppColors.amber),
                    _metric('Automation', 'Locked', AppColors.red),
                  ],
                ),
                const SizedBox(height: 28),
                _blockedCard(value.blockedReason),
                const SizedBox(height: 24),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: AppColors.green,
                          size: 32,
                        ),
                        SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Setup complete',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Your verified local configuration is protected by Windows. No trading was armed.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _progressItem(int index, String title, String subtitle) => Padding(
    padding: const EdgeInsets.only(bottom: 28),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= _step ? AppColors.accent : AppColors.bg2,
            border: Border.all(
              color: index <= _step ? AppColors.accent : AppColors.border,
            ),
          ),
          child: Text(
            '${index + 1}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: index <= _step ? AppColors.text1 : AppColors.text3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.text3, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _notice(IconData icon, String title, String body) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 30),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _emptyTerminal() => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.desktop_windows_outlined,
            color: AppColors.amber,
            size: 36,
          ),
          const SizedBox(height: 14),
          const Text(
            'MetaTrader 5 was not found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Install your broker’s official MetaTrader 5 terminal. Do not download a terminal from an unverified website.',
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: _busy ? null : _detect,
            icon: const Icon(Icons.refresh),
            label: const Text('Check again'),
          ),
        ],
      ),
    ),
  );

  Widget _checkRow(OnboardingCheck check) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Card(
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
  );

  Widget _blockedCard(String reason) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.amber.withValues(alpha: .08),
      border: Border.all(color: AppColors.amber.withValues(alpha: .45)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const Icon(Icons.lock_outline, color: AppColors.amber),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            reason,
            style: const TextStyle(color: AppColors.text1, height: 1.45),
          ),
        ),
      ],
    ),
  );

  Widget _errorBox(String message) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Text(
      message,
      style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w600),
    ),
  );

  Widget _primaryButton(String label, VoidCallback? onPressed) => SizedBox(
    width: 260,
    child: FilledButton.icon(
      onPressed: onPressed,
      icon: _busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.arrow_forward_rounded),
      label: Text(label),
    ),
  );

  Widget _nav(
    IconData icon,
    String label,
    bool selected, {
    VoidCallback? onTap,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        onTap: onTap,
        selected: selected,
        selectedTileColor: AppColors.accentSoft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  Widget _metric(String label, String value, Color color) => SizedBox(
    width: 250,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.text3)),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Icon(Icons.auto_graph_rounded, color: AppColors.green, size: 30),
      SizedBox(width: 12),
      Expanded(
        child: Text(
          'Emtifize AI',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
    ],
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppColors.green,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.4,
    ),
  );
}
