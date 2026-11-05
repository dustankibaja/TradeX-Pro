import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'engine_status_client.dart';
import 'demo_account_client.dart';

/// Human-friendly pairing UX; no trading controls and no stored broker secrets.
class EngineStatusScreen extends StatefulWidget {
  const EngineStatusScreen({super.key});

  @override
  State<EngineStatusScreen> createState() => _EngineStatusScreenState();
}

class _EngineStatusScreenState extends State<EngineStatusScreen> {
  final _url = TextEditingController();
  final _token = TextEditingController();
  final _client = EngineStatusClient();
  final _demoClient = DemoAccountClient();
  EngineStatus? _current;
  DemoAccount? _account;
  String? _error;
  String? _accountError;
  Timer? _refreshTimer;
  bool _busy = false;

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _url.dispose();
    _token.clear();
    _token.dispose();
    _client.dispose();
    _demoClient.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _accountError = null;
    });
    try {
      final response = await _client.fetchStatus(
        baseUrl: _url.text,
        readOnlyToken: _token.text,
      );
      if (!mounted) return;
      setState(() {
        _current = response;
        _account = null; // Never keep stale broker balances during refresh.
      });
      _refreshTimer ??= Timer.periodic(
        const Duration(seconds: 15), (_) => _check(),
      );
      if (response.stale || response.state == 'offline' ||
          response.mode != 'dry_run' || response.tradingEnabled) {
        return; // Never request account figures for a live-config engine.
      }
      try {
        final account = await _demoClient.fetch(
          baseUrl: _url.text,
          readOnlyToken: _token.text,
        );
        if (!mounted) return;
        setState(() => _account = account);
      } catch (error) {
        if (!mounted) return;
        setState(() {
          _account = null;
          _accountError = error is FormatException
              ? error.message
              : 'Unable to read the demo account. Try again.';
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _current = null;
        _account = null;
        _error = error is FormatException
            ? error.message
            : 'Cannot reach the engine. Check your secure API connection.';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _money(double? amount, String currency) {
    if (amount == null) return 'Unavailable';
    final value = amount.toStringAsFixed(2);
    final grouped = value.replaceAllMapped(
      RegExp(r'(\\d)(?=(\\d{3})+\\.)'), (match) => '${match[1]},',
    );
    return '$currency $grouped';
  }

  Color _pnlColor(double? value) {
    if (value == null || value == 0) return Colors.white;
    return value > 0 ? Colors.greenAccent : Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final value = _current;
    final isOnline = value?.state == 'running' && value?.stale == false;
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        backgroundColor: AppColors.bg0,
        foregroundColor: Colors.white,
        title: const Text('Trading engine'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.hub_outlined, color: AppColors.accent, size: 42),
            const SizedBox(height: 12),
            const Text(
              'Connect your MT5 bot',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 24,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            const Text(
              'View the engine status securely from your phone. '
              'Trade execution and remote controls are intentionally disabled '
              'while strategy validation is incomplete.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.text3, height: 1.5),
            ),
            const SizedBox(height: 26),
            _fieldLabel('Secure API address'),
            TextField(
              controller: _url,
              autocorrect: false,
              keyboardType: TextInputType.url,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'https://your-private-engine.example',
                hintStyle: TextStyle(color: AppColors.text3),
              ),
            ),
            const SizedBox(height: 18),
            _fieldLabel('Read-only pairing token'),
            TextField(
              controller: _token,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your engine access token',
                hintStyle: TextStyle(color: AppColors.text3),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _busy ? null : _check,
              icon: _busy
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.sync_rounded),
              label: Text(_busy ? 'Checking engine...' : 'Check connection'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bg2,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(
                      isOnline ? Icons.check_circle_outline : Icons.cloud_off_outlined,
                      color: isOnline ? Colors.greenAccent : Colors.orangeAccent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        value == null
                            ? 'Not connected'
                            : value.stale ? 'Offline / stale heartbeat' : value.state.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  _detail('Mode', value?.mode ?? 'Unknown'),
                  _detail('Strategy', value?.strategy ?? 'Unavailable'),
                  _detail('Symbols', value?.symbols.join(', ') ?? 'None'),
                  _detail('Last heartbeat', value?.updatedAt ?? 'Not received'),
                  if (value?.tradingEnabled == true) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'WARNING: the engine reports that live trading is configured. '
                      'Do not use funded accounts before certification.',
                      style: TextStyle(color: Colors.orangeAccent),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            _demoPortfolioPanel(),
            const SizedBox(height: 18),
            const Text(
              'Other app balances, chart quotes, signals and trade history '
              'are demonstration data—not live brokerage records. '
              'Your broker password never belongs in this screen.',
              style: TextStyle(color: AppColors.text3, fontSize: 12, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _demoPortfolioPanel() {
    final data = _account;
    final currency = data?.currency ?? '';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.account_balance_wallet_outlined,
                color: AppColors.accent),
            SizedBox(width: 10),
            Expanded(child: Text(
              'Real MT5 demo account',
              style: TextStyle(color: Colors.white,
                  fontSize: 18, fontWeight: FontWeight.bold),
            )),
          ]),
          const SizedBox(height: 8),
          const Text(
            'Read-only broker figures. No real-money account access.',
            style: TextStyle(color: AppColors.text3, fontSize: 12),
          ),
          if (_accountError != null) ...[
            const SizedBox(height: 14),
            Text(_accountError!,
                style: const TextStyle(color: Colors.orangeAccent)),
          ],
          if (data == null || !data.available) ...[
            const SizedBox(height: 16),
            const Text(
              'Demo account data unavailable. Connect a running demo-only '
              'backend and refresh. Empty values are never replaced with '
              'sample balances.',
              style: TextStyle(color: AppColors.text3, height: 1.5),
            ),
          ] else ...[
            const SizedBox(height: 18),
            _detail('Balance', _money(data.balance, currency)),
            _detail('Equity', _money(data.equity, currency)),
            _detail('Free margin', _money(data.freeMargin, currency)),
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(children: [
                const SizedBox(
                  width: 110,
                  child: Text('Floating P&L',
                      style: TextStyle(color: AppColors.text3)),
                ),
                Expanded(child: Text(
                  _money(data.floatingPnl, currency),
                  style: TextStyle(color: _pnlColor(data.floatingPnl),
                      fontWeight: FontWeight.bold),
                )),
              ]),
            ),
            _detail('Last broker sync', data.updatedAt ?? 'Not received'),
            const SizedBox(height: 18),
            Text('Open positions (${data.positions.length} shown)',
                style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (data.positions.isEmpty)
              const Text('No open positions on this demo account.',
                  style: TextStyle(color: AppColors.text3))
            else
              ...data.positions.map((position) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${position.side} ${position.symbol} • ${position.volume} lots',
                        style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w600)),
                    Text(
                      'Entry ${position.openPrice} → ${position.currentPrice}',
                      style: const TextStyle(color: AppColors.text3,
                          fontSize: 12),
                    ),
                    Text(_money(position.profit, currency),
                        style: TextStyle(color: _pnlColor(position.profit))),
                  ],
                ),
              )),
            const SizedBox(height: 14),
            const Text('Recent closing deals (last 7 days)',
                style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (data.recentClosingDeals.isEmpty)
              const Text('No closing deals reported in the last 7 days.',
                  style: TextStyle(color: AppColors.text3))
            else
              ...data.recentClosingDeals.map((deal) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${deal.symbol} • closing deal • ${deal.dealSide} • ${deal.volume} lots',
                        style: const TextStyle(color: Colors.white)),
                    Text('${_money(deal.netPnl, currency)} • ${deal.closedAt}',
                        style: TextStyle(color: _pnlColor(deal.netPnl),
                            fontSize: 12)),
                  ],
                ),
              )),
            const SizedBox(height: 10),
            const Text(
              'Closing deals are not necessarily complete round-trip trades. '
              'The worker is DRY_RUN: no orders are placed by Emtifize AI.',
              style: TextStyle(color: AppColors.text3,
                  fontSize: 12, height: 1.5),
            ),
          ],
          const SizedBox(height: 12),
          const Text('Refreshes every 15 seconds while this screen is open.',
              style: TextStyle(color: AppColors.text3, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _fieldLabel(String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(value, style: const TextStyle(
      color: Colors.white, fontWeight: FontWeight.w600,
    )),
  );

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 110,
          child: Text(label, style: const TextStyle(color: AppColors.text3))),
        Expanded(child: Text(value,
          style: const TextStyle(color: Colors.white))),
      ],
    ),
  );
}
