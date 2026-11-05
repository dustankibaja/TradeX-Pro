import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'demo_account_client.dart';
import 'demo_control_client.dart';
import 'engine_status_client.dart';
import 'saved_pairing.dart';
import 'scan_pairing_screen.dart';

/// One private console: pair, monitor broker DEMO account, pause/resume
/// demo signal simulation. Broker order execution is never exposed.
class EngineStatusScreen extends StatefulWidget {
  const EngineStatusScreen({super.key});

  @override
  State<EngineStatusScreen> createState() => _EngineStatusScreenState();
}

class _EngineStatusScreenState extends State<EngineStatusScreen>
    with WidgetsBindingObserver {
  final _url = TextEditingController();
  final _readToken = TextEditingController();
  final _controlToken = TextEditingController();
  final _statusClient = EngineStatusClient();
  final _accountClient = DemoAccountClient();
  final _controlClient = DemoControlClient();
  final _pairingStore = const PairingStore();

  Timer? _timer;
  EngineStatus? _status;
  DemoAccount? _account;
  String? _error;
  String? _controlError;
  bool _paired = false;
  bool _showConnection = true;
  bool _checking = false;
  bool _changingState = false;
  bool _pairingSaved = false;
  bool _restoring = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _restorePairing();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_paired && !_showConnection) {
        _startAutoRefresh();
        _refresh();
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _startAutoRefresh() {
    _timer ??= Timer.periodic(
      const Duration(seconds: 15), (_) => _refresh(),
    );
  }

  Future<void> _restorePairing() async {
    try {
      final stored = await _pairingStore.load();
      if (!mounted) return;
      if (stored != null) {
        _url.text = stored.url;
        _readToken.text = stored.readToken;
        _controlToken.text = stored.controlToken;
        setState(() {
          _paired = true;
          _showConnection = false;
          _pairingSaved = true;
        });
        _startAutoRefresh();
        await _refresh();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Saved pairing unavailable. Scan your Windows QR again.');
      }
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  Future<void> _scanPairing() async {
    final scanned = await Navigator.push<SavedPairing>(
      context,
      MaterialPageRoute(builder: (_) => const ScanPairingScreen()),
    );
    if (scanned == null || !mounted) return;
    _url.text = scanned.url;
    _readToken.text = scanned.readToken;
    _controlToken.text = scanned.controlToken;
    setState(() {
      _error = null;
      _pairingSaved = false;
    });
    await _refresh();
  }

  Future<void> _forgetPairing() async {
    _timer?.cancel();
    _timer = null;
    try {
      await _pairingStore.forget();
    } catch (_) {
      if (mounted) setState(() =>
          _error = 'Could not clear encrypted pairing. Try again.');
      return;
    }
    _url.clear();
    _readToken.clear();
    _controlToken.clear();
    if (!mounted) return;
    setState(() {
      _paired = false;
      _showConnection = true;
      _pairingSaved = false;
      _status = null;
      _account = null;
      _error = null;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _url.dispose();
    _readToken.clear();
    _readToken.dispose();
    _controlToken.clear();
    _controlToken.dispose();
    _statusClient.dispose();
    _accountClient.dispose();
    _controlClient.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_checking || _readToken.text.trim().isEmpty) return;
    setState(() {
      _checking = true;
      _error = null;
    });
    try {
      final status = await _statusClient.fetchStatus(
        baseUrl: _url.text,
        readOnlyToken: _readToken.text,
      );
      DemoAccount? account;
      String? brokerError;
      if (!status.stale && status.mode == 'dry_run' &&
          !status.tradingEnabled && status.state != 'offline') {
        try {
          account = await _accountClient.fetch(
            baseUrl: _url.text,
            readOnlyToken: _readToken.text,
          );
        } on FormatException catch (e) {
          brokerError = e.message;
        } catch (_) {
          brokerError = 'Unable to fetch demo-account figures.';
        }
      }

      if (!mounted) return;
      setState(() {
        _paired = true;
        _showConnection = false;
        _status = status;
        _account = account;
        _controlError = brokerError;
      });
      _startAutoRefresh();
      if (!_pairingSaved) {
        try {
          await _pairingStore.save(SavedPairing(
            url: _url.text.trim(),
            readToken: _readToken.text.trim(),
            controlToken: _controlToken.text.trim(),
          ));
          if (mounted) setState(() => _pairingSaved = true);
        } catch (_) {
          if (mounted) {
            setState(() => _controlError =
                'Connected, but secure save failed. Re-pair may be needed after restart.');
          }
        }
      }
    } on FormatException catch (e) {
      if (!mounted) return;
      setState(() {
        _status = null;
        _account = null; // Never retain last known money on disconnection.
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = null;
        _account = null;
        _error = 'Cannot reach the Windows engine. Check MT5 and Tailscale.';
      });
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _setPaused(bool pause) async {
    if (_changingState) return;
    final status = _status;
    if (status == null || status.remoteControlAvailable != true ||
        _controlToken.text.trim().length < 32) return;

    // RESUME means resume DEMO signal calculations, never market execution.
    if (!pause) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.bg1,
          title: const Text('Resume demo simulation?'),
          content: const Text(
            'This resumes calculations for DEMO signal testing only. '
            'No real or demo market orders can be placed from this app. '
            'The manual Windows kill switch is never cleared.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Resume'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    setState(() {
      _changingState = true;
      _controlError = null;
    });
    try {
      await _controlClient.setPaused(
        baseUrl: _url.text,
        controlToken: _controlToken.text,
        paused: pause,
      );
      await Future<void>.delayed(const Duration(milliseconds: 700));
      await _refresh();
    } on FormatException catch (e) {
      if (mounted) setState(() => _controlError = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _controlError =
            'Cannot change simulation state. Check PC and private connection.');
      }
    } finally {
      if (mounted) setState(() => _changingState = false);
    }
  }

  void _editConnection() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _paired = false;
      _showConnection = true;
      _status = null;
      _account = null;
      _error = null;
      _controlError = null;
    });
  }

  String _money(double? value, String? currency) {
    if (value == null || currency == null) return 'Unavailable';
    return '$currency ' + value.toStringAsFixed(2);
  }

  String _time(String? timestamp) {
    if (timestamp == null) return 'Unavailable';
    final date = DateTime.tryParse(timestamp);
    if (date == null) return 'Unavailable';
    final local = date.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '${local.day}/${local.month} $hour:$min';
  }

  Color _pnlColor(double? value) {
    if (value == null || value == 0) return AppColors.text1;
    return value > 0 ? AppColors.green : AppColors.red;
  }

  Widget _surface({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.bg1,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );

  Widget _label(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: const TextStyle(
        color: AppColors.text2, fontSize: 12, fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _infoRow(String name, String value, {Color? valueColor}) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(child: Text(name,
          style: const TextStyle(color: AppColors.text3, fontSize: 13))),
        Flexible(child: Text(value, textAlign: TextAlign.end,
          style: TextStyle(color: valueColor ?? AppColors.text1,
            fontSize: 13, fontWeight: FontWeight.w600))),
      ],
    ),
  );

  Widget _connectionPanel() => _surface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Connect your Windows bot',
          style: TextStyle(color: AppColors.text1, fontSize: 17,
            fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('Private HTTPS over Tailscale · tokens stay in this app session',
          style: TextStyle(color: AppColors.text3, fontSize: 12)),
        const SizedBox(height: 20),
        _label('Private API address'),
        TextField(
          controller: _url,
          autocorrect: false,
          keyboardType: TextInputType.url,
          style: const TextStyle(color: AppColors.text1),
          decoration: const InputDecoration(
            hintText: 'https://your-pc.your-tailnet.ts.net',
          ),
        ),
        const SizedBox(height: 15),
        _label('Read-only pairing token'),
        TextField(
          controller: _readToken,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          style: const TextStyle(color: AppColors.text1),
          decoration: const InputDecoration(hintText: 'Read-only token from Windows'),
        ),
        const SizedBox(height: 15),
        _label('Separate demo control token (optional)'),
        TextField(
          controller: _controlToken,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          style: const TextStyle(color: AppColors.text1),
          decoration: const InputDecoration(hintText: 'For pause / resume controls'),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _checking ? null : _refresh,
          icon: _checking
            ? const SizedBox(height: 18, width: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.link_rounded, size: 19),
          label: Text(_checking ? 'Connecting...' : 'Connect securely'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: AppColors.red)),
        ],
      ],
    ),
  );

  Widget _statusPanel() {
    final status = _status;
    final online = status != null && !status.stale &&
      status.state != 'offline';
    final paused = status?.state == 'paused';
    final stateColor = online
      ? (paused ? AppColors.amber : AppColors.green)
      : AppColors.text3;
    final stateLabel = !online ? 'DISCONNECTED'
      : paused ? 'PAUSED' : 'RUNNING';

    return _surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ENGINE', style: TextStyle(color: AppColors.text3,
            fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  online ? Icons.hub_outlined : Icons.cloud_off_rounded,
                  color: stateColor, size: 22,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stateLabel, style: TextStyle(
                    color: stateColor, fontSize: 22,
                    fontWeight: FontWeight.w800)),
                  Text(online ? 'Connected to MT5 demo worker'
                    : 'Windows engine is not responding',
                    style: const TextStyle(
                      color: AppColors.text3, fontSize: 12)),
                ],
              )),
              IconButton(
                tooltip: 'Refresh engine',
                onPressed: _checking ? null : _refresh,
                icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.text2),
              ),
            ],
          ),
          const SizedBox(height: 19),
          _infoRow('Strategy', status?.strategy ?? '—'),
          _infoRow('Market', status?.symbols.join(', ') ?? '—'),
          _infoRow('Execution mode',
              status?.mode == 'dry_run' ? 'DEMO / DRY RUN' : 'Unavailable',
              valueColor: status?.mode == 'dry_run'
                ? AppColors.green : AppColors.amber),
          _infoRow('Last heartbeat', _time(status?.updatedAt)),
          if (status?.state == 'paused' &&
              status?.remotePaused == false) ...[
            const Text(
              'Paused by Windows or manual safety switch. Phone resume '
              'cannot override that switch.',
              style: TextStyle(color: AppColors.amber, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _controlPanel() {
    final status = _status;
    final canControl = status?.remoteControlAvailable == true &&
        _controlToken.text.trim().length >= 32;
    final remotePaused = status?.remotePaused == true;
    final safeResume = status != null &&
        !status.stale && status.demoGuarded &&
        !status.tradingEnabled && status.mode == 'dry_run' &&
        (_account?.available ?? false);
    return _surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DEMO CONTROLS', style: TextStyle(
            color: AppColors.text3, fontSize: 11,
            fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 8),
          const Text('Pause or resume signal simulation',
            style: TextStyle(
              color: AppColors.text1, fontSize: 16,
              fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          const Text('No market orders. No funded trading. '
              'Windows manual kill switch always has priority.',
              style: TextStyle(
                color: AppColors.text3, fontSize: 12, height: 1.4)),
          const SizedBox(height: 17),
          if (!canControl)
            const Text(
              'Enter the separate control token in connection settings '
              'and upgrade the Windows bridge to enable controls.',
              style: TextStyle(color: AppColors.amber, fontSize: 12),
            )
          else if (remotePaused)
            FilledButton.icon(
              onPressed: _changingState || !safeResume
                ? null : () => _setPaused(false),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(_changingState
                ? 'Applying...' : 'Resume demo simulation'),
            )
          else
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: AppColors.bg0,
              ),
              onPressed: _changingState ? null : () => _setPaused(true),
              icon: const Icon(Icons.pause_circle_outline_rounded),
              label: Text(_changingState ? 'Applying...' : 'Pause demo simulation'),
            ),
          if (_controlError != null) ...[
            const SizedBox(height: 11),
            Text(_controlError!,
              style: const TextStyle(color: AppColors.amber, fontSize: 12)),
          ],
          if (remotePaused && !safeResume) ...[
            const SizedBox(height: 9),
            const Text(
              'Resume locked until the DEMO broker and dry-run worker are verified.',
              style: TextStyle(color: AppColors.amber, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metric(String title, String value, {Color? color}) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(
          color: AppColors.text3, fontSize: 12)),
        const SizedBox(height: 7),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: TextStyle(
            color: color ?? AppColors.text1,
            fontSize: 21, fontWeight: FontWeight.w800)),
        ),
      ],
    ),
  );

  Widget _portfolioPanel() {
    final account = _account;
    final available = account != null && account.available && !account.stale;
    return _surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(child: Text('DEMO ACCOUNT',
              style: TextStyle(color: AppColors.text3,
                fontSize: 11, fontWeight: FontWeight.w700,
                letterSpacing: 2))),
            if (available)
              const Icon(Icons.verified_rounded,
                size: 17, color: AppColors.green),
          ]),
          const SizedBox(height: 16),
          if (!available)
            const Text(
              'Real broker figures unavailable. Connect a verified MT5 '
              'DEMO worker—no sample balances will be shown.',
              style: TextStyle(color: AppColors.text3,
                fontSize: 13, height: 1.4),
            )
          else ...[
            Row(children: [
              _metric('Balance', _money(account?.balance, account?.currency)),
              const SizedBox(width: 10),
              _metric('Equity', _money(account?.equity, account?.currency)),
            ]),
            const SizedBox(height: 22),
            Row(children: [
              _metric('Floating P&L',
                _money(account?.floatingPnl, account?.currency),
                color: _pnlColor(account?.floatingPnl)),
              const SizedBox(width: 10),
              _metric('Free margin',
                _money(account?.freeMargin, account?.currency)),
            ]),
            const SizedBox(height: 10),
            Text('Broker sync: ' + _time(account?.updatedAt),
              style: const TextStyle(color: AppColors.text3, fontSize: 11)),
          ],
        ],
      ),
    );
  }

  Widget _tradesPanel() {
    final positions = _account?.positions ?? [];
    final deals = _account?.recentClosingDeals ?? [];
    final currency = _account?.currency;
    if (_account?.available != true) return const SizedBox.shrink();
    return _surface(child: Column(children: [
      Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          iconColor: AppColors.text1,
          collapsedIconColor: AppColors.text2,
          title: Text('Open positions (' + positions.length.toString() + ')',
            style: const TextStyle(color: AppColors.text1,
              fontSize: 15, fontWeight: FontWeight.w700)),
          children: [
            if (positions.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('No open positions.',
                  style: TextStyle(color: AppColors.text3)),
              ),
            ...positions.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(p.side + '  ' + p.symbol,
                    _money(p.profit, currency),
                    valueColor: _pnlColor(p.profit)),
                  Text('Lots: ' + p.volume.toString() +
                    '   Entry: ' + p.openPrice.toString() +
                    '   Now: ' + p.currentPrice.toString(),
                    style: const TextStyle(color: AppColors.text3,
                      fontSize: 12)),
                ],
              ),
            )),
          ],
        ),
      ),
      const Divider(color: AppColors.border),
      Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          iconColor: AppColors.text1,
          collapsedIconColor: AppColors.text2,
          title: Text('Closing deals · 7 days (' + deals.length.toString() + ')',
            style: const TextStyle(color: AppColors.text1,
              fontSize: 15, fontWeight: FontWeight.w700)),
          children: [
            if (deals.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('No recent closing deals.',
                  style: TextStyle(color: AppColors.text3)),
              ),
            ...deals.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(children: [
                _infoRow(d.symbol + '  ' + d.dealSide,
                  _money(d.netPnl, currency),
                  valueColor: _pnlColor(d.netPnl)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Lots: ' + d.volume.toString() +
                    '   ' + _time(d.closedAt),
                    style: const TextStyle(color: AppColors.text3,
                      fontSize: 12)),
                ),
              ]),
            )),
          ],
        ),
      ),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 17, 18, 36),
          children: [
            Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.accentSoft,
                ),
                child: const Icon(Icons.hub_rounded,
                  color: AppColors.accent, size: 25),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Emtifize AI', style: TextStyle(
                    color: AppColors.text1, fontSize: 22,
                    fontWeight: FontWeight.w800)),
                  Text('Private bot control center', style: TextStyle(
                    color: AppColors.text3, fontSize: 11)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('DEMO', style: TextStyle(
                  fontSize: 11, color: AppColors.green,
                  fontWeight: FontWeight.w800)),
              ),
              IconButton(
                tooltip: 'Connection settings',
                onPressed: _editConnection,
                icon: const Icon(Icons.tune_rounded,
                  color: AppColors.text2),
              ),
            ]),
            const SizedBox(height: 22),
            if (_showConnection) ...[
              _connectionPanel(),
              const SizedBox(height: 16),
            ],
            _statusPanel(),
            const SizedBox(height: 12),
            if (_paired) ...[
              _controlPanel(),
              const SizedBox(height: 12),
              _portfolioPanel(),
              const SizedBox(height: 12),
              _tradesPanel(),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            const Text(
              'DEMO dry-run only · No broker orders or funded trading '
              'can be initiated from this app.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.text3,
                fontSize: 11, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
