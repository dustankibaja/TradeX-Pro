import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';
import '../strategy_studio/strategy_model.dart';
import '../strategy_studio/strategy_store.dart';
import 'backtest_client.dart';
import 'backtest_model.dart';
import 'backtest_store.dart';

class BacktestScreen extends StatefulWidget {
  const BacktestScreen({
    super.key,
    this.onHome,
    this.client = const LocalBacktestClient(),
    this.store = const BacktestStore(),
    this.strategyStore = const LocalStrategyStore(),
  });
  final VoidCallback? onHome;
  final BacktestClient client;
  final BacktestStore store;
  final StrategyStore strategyStore;
  @override
  State<BacktestScreen> createState() => _BacktestScreenState();
}

class _BacktestScreenState extends State<BacktestScreen> {
  List<StrategyDefinition> strategies = [];
  List<BacktestResult> saved = [];
  StrategyDefinition? strategy;
  DatasetValidation? validation;
  BacktestResult? result;
  bool busy = false, synthetic = false;
  String? error, message;
  final path = TextEditingController(),
      balance = TextEditingController(text: '10000'),
      slippage = TextEditingController(text: '.2'),
      commission = TextEditingController(text: '7'),
      financing = TextEditingController(text: '0'),
      leverage = TextEditingController(text: '30');
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      strategies = (await widget.strategyStore.load())
          .where((s) => s.confirmed)
          .toList();
      saved = await widget.store.load();
      strategy = strategies.firstOrNull;
    } catch (e) {
      error = '$e';
    }
    if (mounted) setState(() {});
  }

  Future<void> _validate() async {
    if (strategy == null) {
      setState(() => error = 'Confirm and save a strategy before backtesting.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
      validation = null;
    });
    try {
      validation = await widget.client.validate(
        path.text.trim(),
        timeframe: strategy!.timeframe,
        synthetic: synthetic,
      );
    } catch (e) {
      error = '$e'.replaceFirst('FormatException: ', '');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  double _n(TextEditingController c, String label) {
    final v = double.tryParse(c.text);
    if (v == null || !v.isFinite)
      throw FormatException('$label must be a valid number.');
    return v;
  }

  Future<void> _run() async {
    if (validation == null || strategy == null) return;
    setState(() {
      busy = true;
      error = null;
      result = null;
    });
    try {
      final settings = BacktestSettings(
        balance: _n(balance, 'Starting balance'),
        slippage: _n(slippage, 'Slippage'),
        commission: _n(commission, 'Commission'),
        financing: _n(financing, 'Financing'),
        leverage: _n(leverage, 'Leverage'),
      );
      final r = await widget.client.run(
        path.text.trim(),
        strategy!,
        settings,
        synthetic: synthetic,
      );
      r.name = '${strategy!.name} — ${validation!.firstUtc.substring(0, 10)}';
      saved.add(r);
      await widget.store.save(saved);
      result = r;
      message = 'Simulation saved locally. No broker order was submitted.';
    } catch (e) {
      error = '$e'.replaceFirst('FormatException: ', '');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    body: Row(
      children: [
        Container(
          width: 250,
          color: AppColors.bg1,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Emtifize AI',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 30),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Home'),
                onTap: widget.onHome,
              ),
              const ListTile(
                selected: true,
                leading: Icon(Icons.query_stats),
                title: Text('Backtesting'),
              ),
              const Divider(),
              const Text(
                'HISTORICAL SIMULATION',
                style: TextStyle(
                  color: AppColors.amber,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'No broker orders. Past simulations do not predict future results.',
                style: TextStyle(color: AppColors.text3),
              ),
              const SizedBox(height: 18),
              const Text(
                'Saved results',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Expanded(
                child: ListView(
                  children: saved
                      .map(
                        (r) => ListTile(
                          title: Text(r.name),
                          subtitle: Text(
                            '${r.manifest['date_range']?[0] ?? ''}',
                          ),
                          onTap: () => setState(() => result = r),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(34),
            child: result == null ? _configuration() : _results(result!),
          ),
        ),
      ],
    ),
  );
  Widget _configuration() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Test My Strategy',
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8),
      const Text(
        'Run a deterministic historical simulation. This cannot place a trade.',
      ),
      const SizedBox(height: 22),
      DropdownButtonFormField<StrategyDefinition>(
        initialValue: strategy,
        decoration: const InputDecoration(
          labelText: 'Confirmed saved strategy',
        ),
        items: strategies
            .map(
              (s) => DropdownMenuItem(
                value: s,
                child: Text('${s.name} · ${s.timeframe} · v${s.version}'),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() {
          strategy = v;
          validation = null;
        }),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: path,
        decoration: const InputDecoration(
          labelText: 'Historical CSV file path',
          helperText: 'Use the documented EURUSD UTC bid/ask OHLC template.',
        ),
      ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: () => setState(() {
          path.text =
              '${File(Platform.resolvedExecutable).parent.path}\\SYNTHETIC-DEMO-EURUSD-H1.csv';
          synthetic = true;
          validation = null;
        }),
        icon: const Icon(Icons.science_outlined),
        label: const Text('Use packaged synthetic demonstration data'),
      ),
      SwitchListTile(
        value: synthetic,
        onChanged: (v) => setState(() => synthetic = v),
        title: const Text('This is synthetic demonstration data'),
        subtitle: const Text(
          'Synthetic results are never presented as genuine historical forex performance.',
        ),
      ),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _field(balance, 'Starting simulated balance'),
          _field(slippage, 'Adverse slippage (pips)'),
          _field(commission, 'Commission per lot'),
          _field(financing, 'Financing per lot/day'),
          _field(leverage, 'Leverage'),
        ],
      ),
      const SizedBox(height: 18),
      FilledButton.icon(
        onPressed: busy ? null : _validate,
        icon: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.fact_check),
        label: const Text('Validate dataset'),
      ),
      if (validation != null) _validationCard(),
      if (error != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(error!, style: const TextStyle(color: AppColors.red)),
        ),
      if (message != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(message!, style: const TextStyle(color: AppColors.green)),
        ),
    ],
  );
  Widget _field(TextEditingController c, String label) => SizedBox(
    width: 220,
    child: TextField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    ),
  );
  Widget _validationCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dataset validation passed',
            style: TextStyle(
              color: AppColors.green,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '${validation!.rows} completed candles · ${validation!.firstUtc} to ${validation!.lastUtc}',
          ),
          Text('SHA-256: ${validation!.dataset['content_hash']}'),
          ...validation!.warnings.map(
            (w) => Text(
              'Warning: $w',
              style: const TextStyle(color: AppColors.amber),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: busy ? null : _run,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Run historical simulation'),
          ),
        ],
      ),
    ),
  );
  Widget _results(BacktestResult r) {
    final m = r.metrics;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => result = null),
              icon: const Icon(Icons.arrow_back),
            ),
            const Text(
              'Simulation results',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () async {
                final f = await widget.store.export(r);
                setState(() => message = 'Exported to ${f.first.parent.path}');
              },
              icon: const Icon(Icons.download),
              label: const Text('Export report, CSV and JSON'),
            ),
          ],
        ),
        const Text(
          'Historical simulation — not actual profit and not a promise of future results.',
          style: TextStyle(color: AppColors.amber),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _metric('Net simulated P/L', m['net_profit']),
            _metric('Return %', m['return_percent']),
            _metric('Closed trades', m['closed_trades']),
            _metric('Win rate %', m['win_rate_percent'] ?? 'No closed trades'),
            _metric('Profit factor', m['profit_factor'] ?? 'Not available'),
            _metric('Maximum drawdown %', m['maximum_drawdown_percent']),
            _metric('Realized P/L', m['realized_pnl']),
            _metric('Unrealized P/L', m['unrealized_pnl']),
            _metric('Open positions', m['open_positions']),
            _metric('Modeled costs', m['trading_costs']),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Equity curve',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const Text(
          'Maximum drawdown is the largest peak-to-trough decline in simulated equity.',
        ),
        SizedBox(
          height: 280,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomPaint(
                painter: _EquityPainter(r.equity),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Trade history',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        if (r.trades.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'No positions closed during this period. Review rejected signals, warm-up and date coverage.',
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                'Direction',
                'Entry',
                'Exit',
                'Entry price',
                'Exit price',
                'Lots',
                'Gross P/L',
                'Commission',
                'Financing',
                'Net P/L',
                'Reason',
              ].map((x) => DataColumn(label: Text(x))).toList(),
              rows: r.trades
                  .map(
                    (t) => DataRow(
                      cells: [
                        'side',
                        'entry_time',
                        'exit_time',
                        'entry',
                        'exit',
                        'lots',
                        'gross_pnl',
                        'commission',
                        'financing',
                        'net_pnl',
                        'reason',
                      ].map((k) => DataCell(Text('${t[k] ?? ''}'))).toList(),
                    ),
                  )
                  .toList(),
            ),
          ),
        const SizedBox(height: 16),
        ...((r.manifest['warnings'] as List? ?? []).map(
          (w) => Text(
            'Warning: $w',
            style: const TextStyle(color: AppColors.amber),
          ),
        )),
        if (message != null)
          Text(message!, style: const TextStyle(color: AppColors.green)),
      ],
    );
  }

  Widget _metric(String l, Object? v) => SizedBox(
    width: 190,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l, style: const TextStyle(color: AppColors.text3)),
            const SizedBox(height: 6),
            Text(
              v is num ? v.toStringAsFixed(2) : '$v',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    ),
  );
}

class _EquityPainter extends CustomPainter {
  _EquityPainter(this.points);
  final List<Map<String, dynamic>> points;
  @override
  void paint(Canvas c, Size s) {
    if (points.length < 2) return;
    final vals = points.map((p) => (p['equity'] as num).toDouble()).toList(),
        lo = vals.reduce((a, b) => a < b ? a : b),
        hi = vals.reduce((a, b) => a > b ? a : b),
        range = hi - lo == 0 ? 1 : hi - lo;
    final p = Paint()
      ..color = AppColors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    for (var i = 0; i < vals.length; i++) {
      final x = i / (vals.length - 1) * s.width,
          y = s.height - (vals[i] - lo) / range * s.height;
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    c.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _EquityPainter old) => old.points != points;
}
