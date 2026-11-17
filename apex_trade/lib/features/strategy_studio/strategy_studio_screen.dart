import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'strategy_model.dart';
import 'strategy_preview_client.dart';
import 'strategy_store.dart';
import 'teach_client.dart';
import 'teach_dialog.dart';

class StrategyStudioScreen extends StatefulWidget {
  const StrategyStudioScreen({
    super.key,
    this.store = const LocalStrategyStore(),
    this.previewClient = const LocalStrategyPreviewClient(),
    this.teachClient = const LocalTeachClient(),
    this.onHome,
  });
  final StrategyStore store;
  final StrategyPreviewClient previewClient;
  final TeachClient teachClient;
  final VoidCallback? onHome;
  @override
  State<StrategyStudioScreen> createState() => _StrategyStudioScreenState();
}

class _StrategyStudioScreenState extends State<StrategyStudioScreen> {
  List<StrategyDefinition> _strategies = [];
  StrategyDefinition? _selected;
  String? _error;
  bool _loading = true;
  bool _previewing = false;
  SignalPreview? _preview;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _strategies = await widget.store.load();
      _selected = _strategies.firstOrNull?.copy();
    } catch (e) {
      _error = '$e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _persist() async {
    await widget.store.save(_strategies);
    if (mounted) setState(() {});
  }

  void _new() {
    setState(() {
      _selected = StrategyDefinition.emaTemplate();
      _error = null;
    });
  }

  void _materialChange(VoidCallback update) {
    update();
    _selected?.confirmed = false;
    _preview = null;
  }

  Future<void> _teach() async {
    final draft = await showDialog<StrategyDefinition>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TeachMyBotDialog(client: widget.teachClient),
    );
    if (draft != null && mounted) {
      draft.confirmed = false;
      setState(() {
        _selected = draft;
        _error = null;
        _preview = null;
      });
    }
  }

  Future<void> _save() async {
    final value = _selected;
    if (value == null) return;
    try {
      value.validate();
      final index = _strategies.indexWhere((s) => s.id == value.id);
      if (index < 0) {
        _strategies.add(value.copy());
      } else {
        final existing = _strategies[index];
        final candidate = value.copy()..version = existing.version;
        if (candidate.exportJson() == existing.exportJson()) {
          _message(
            'No rule changes to save. Version ${existing.version} remains current.',
          );
          return;
        }
        value.version = existing.version + 1;
        _strategies[index] = value.copy();
      }
      await _persist();
      _message('Strategy saved locally. Version ${value.version}.');
    } catch (e) {
      setState(
        () => _error = e.toString().replaceFirst('FormatException: ', ''),
      );
    }
  }

  Future<void> _duplicate() async {
    final source = _selected;
    if (source == null) return;
    final copy = StrategyDefinition.fromJson(jsonDecode(source.exportJson()));
    copy.id = 'copy-${DateTime.now().microsecondsSinceEpoch}';
    copy.name = '${copy.name} copy';
    copy.version = 1;
    copy.confirmed = false;
    _strategies.add(copy);
    _selected = copy;
    await _persist();
  }

  Future<void> _delete() async {
    final value = _selected;
    if (value == null) return;
    final yes =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete strategy?'),
            content: Text('Delete “${value.name}” from this computer?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!yes) return;
    _strategies.removeWhere((s) => s.id == value.id);
    _selected = _strategies.firstOrNull?.copy();
    await _persist();
  }

  Future<void> _export() async {
    final value = _selected;
    if (value == null) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export strategy definition'),
        content: SizedBox(
          width: 700,
          child: SelectableText(value.exportJson()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _import() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Import strategy definition'),
        content: SizedBox(
          width: 700,
          child: TextField(
            controller: controller,
            maxLines: 18,
            decoration: const InputDecoration(
              hintText: 'Paste the exported JSON definition here',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Validate and import'),
          ),
        ],
      ),
    );
    if (text == null) return;
    try {
      final value = StrategyDefinition.fromJson(
        jsonDecode(text) as Map<String, dynamic>,
      );
      if (_strategies.any(
        (s) => s.id == value.id && s.version == value.version,
      ))
        throw const FormatException(
          'That strategy identifier and version already exist. Duplicate it instead.',
        );
      _strategies.add(value);
      _selected = value;
      await _persist();
      _message('Validated and imported.');
    } catch (e) {
      setState(
        () => _error = e.toString().replaceFirst('FormatException: ', ''),
      );
    }
  }

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _runPreview() async {
    final value = _selected;
    if (value == null) return;
    if (!value.confirmed) {
      setState(
        () => _error =
            'Confirm the specification before running the signal preview.',
      );
      return;
    }
    setState(() {
      _previewing = true;
      _preview = null;
      _error = null;
    });
    try {
      final result = await widget.previewClient.preview(value);
      if (mounted) setState(() => _preview = result);
    } catch (e) {
      if (mounted)
        setState(
          () => _error = '$e'
              .replaceFirst('Bad state: ', '')
              .replaceFirst('FormatException: ', ''),
        );
    } finally {
      if (mounted) setState(() => _previewing = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Row(
      children: [
        Container(
          width: 270,
          color: AppColors.bg1,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Emtifize AI',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 28),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Home'),
                onTap: widget.onHome,
              ),
              const ListTile(
                selected: true,
                leading: Icon(Icons.auto_awesome),
                title: Text('Strategy Studio'),
              ),
              const Divider(),
              FilledButton.icon(
                onPressed: _new,
                icon: const Icon(Icons.add),
                label: const Text('Create strategy'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _teach,
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Teach My Bot'),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        children: _strategies
                            .map(
                              (s) => ListTile(
                                selected: identical(s, _selected),
                                title: Text(s.name),
                                subtitle: Text(
                                  'EUR/USD · ${s.timeframe} · v${s.version}',
                                ),
                                onTap: () => setState(() {
                                  _selected = s.copy();
                                  _error = null;
                                }),
                              ),
                            )
                            .toList(),
                      ),
              ),
              const Text(
                'DEMO ONLY · EXECUTION LOCKED',
                style: TextStyle(
                  color: AppColors.amber,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _selected == null ? _empty() : _editor(_selected!)),
      ],
    ),
  );
  Widget _empty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.account_tree_outlined,
          size: 56,
          color: AppColors.green,
        ),
        const SizedBox(height: 18),
        const Text(
          'Build a strategy without code',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Create plain-language BUY and SELL rules. Trading remains locked.',
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: _new,
          icon: const Icon(Icons.add),
          label: const Text('Create my first strategy'),
        ),
      ],
    ),
  );
  Widget _editor(StrategyDefinition s) => SingleChildScrollView(
    padding: const EdgeInsets.all(36),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Strategy Studio',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
            ),
            OutlinedButton(onPressed: _import, child: const Text('Import')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: _export, child: const Text('Export')),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _duplicate,
              child: const Text('Duplicate'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: _delete, child: const Text('Delete')),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Signal design only — account verification is not trading readiness.',
          style: TextStyle(color: AppColors.amber),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(_error!, style: const TextStyle(color: AppColors.red)),
          ),
        const SizedBox(height: 24),
        _section('Basics', [
          TextFormField(
            initialValue: s.name,
            decoration: const InputDecoration(labelText: 'Strategy name'),
            onChanged: (v) => _materialChange(() => s.name = v),
          ),
          TextFormField(
            initialValue: s.description,
            decoration: const InputDecoration(labelText: 'Description'),
            onChanged: (v) => _materialChange(() => s.description = v),
          ),
          DropdownButtonFormField<String>(
            initialValue: s.timeframe,
            decoration: const InputDecoration(
              labelText: 'Completed-candle timeframe',
            ),
            items: [
              'M15',
              'H1',
              'H4',
              'D1',
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) =>
                setState(() => _materialChange(() => s.timeframe = v!)),
          ),
        ]),
        _conditionSection('BUY conditions', s.buyFast, s.buySlow, (a, b) {
          s.buyFast = a;
          s.buySlow = b;
        }, 'crosses above'),
        _conditionSection('SELL conditions', s.sellFast, s.sellSlow, (a, b) {
          s.sellFast = a;
          s.sellSlow = b;
        }, 'crosses below'),
        _section('Risk and exits', [
          _number('Stop loss (pips)', s.stopLoss, (v) => s.stopLoss = v),
          _number('Take profit (pips)', s.takeProfit, (v) => s.takeProfit = v),
          _number(
            'Risk per trade (%)',
            s.riskPercent,
            (v) => s.riskPercent = v,
          ),
          _integer(
            'Maximum simultaneous positions',
            s.maxPositions,
            (v) => s.maxPositions = v,
          ),
          _integer(
            'Maximum holding candles',
            s.maxHoldingCandles,
            (v) => s.maxHoldingCandles = v,
          ),
          SwitchListTile(
            value: s.oppositeExit,
            title: const Text('Exit on an opposite signal'),
            onChanged: (v) =>
                setState(() => _materialChange(() => s.oppositeExit = v)),
          ),
        ]),
        _section('Session boundaries', [
          TextFormField(
            initialValue: s.sessionStart,
            decoration: const InputDecoration(labelText: 'Start (UTC HH:MM)'),
            onChanged: (v) => _materialChange(() => s.sessionStart = v),
          ),
          TextFormField(
            initialValue: s.sessionEnd,
            decoration: const InputDecoration(labelText: 'End (UTC HH:MM)'),
            onChanged: (v) => _materialChange(() => s.sessionEnd = v),
          ),
        ]),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Plain-language specification',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(s.explanation, style: const TextStyle(height: 1.5)),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: s.confirmed,
                  title: const Text(
                    'I confirm this specification is ready for signal testing',
                  ),
                  subtitle: const Text('This does not enable trading.'),
                  onChanged: (v) => setState(() => s.confirmed = v ?? false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Validate and save strategy'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _previewing ? null : _runPreview,
          icon: const Icon(Icons.science_outlined),
          label: Text(
            _previewing
                ? 'Evaluating controlled candles…'
                : 'Run signal preview',
          ),
        ),
        if (_preview != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _previewCard(_preview!),
          ),
      ],
    ),
  );
  Widget _section(String title, List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            ...children.map(
              (w) =>
                  Padding(padding: const EdgeInsets.only(bottom: 12), child: w),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _conditionSection(
    String title,
    int fast,
    int slow,
    void Function(int, int) change,
    String operation,
  ) => _section(title, [
    Row(
      children: [
        Expanded(
          child: _integer('Fast EMA period', fast, (v) => change(v, slow)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Icon(Icons.arrow_forward),
        ),
        Text(operation),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Icon(Icons.arrow_forward),
        ),
        Expanded(
          child: _integer('Slow EMA period', slow, (v) => change(fast, v)),
        ),
      ],
    ),
    const Text(
      'Crossovers compare the previous completed candle with the current completed candle.',
      style: TextStyle(color: AppColors.text3),
    ),
  ]);
  Widget _number(String label, double value, void Function(double) change) =>
      TextFormField(
        initialValue: '$value',
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        onChanged: (v) {
          final n = double.tryParse(v);
          if (n != null) _materialChange(() => change(n));
        },
      );
  Widget _integer(String label, int value, void Function(int) change) =>
      TextFormField(
        initialValue: '$value',
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        onChanged: (v) {
          final n = int.tryParse(v);
          if (n != null) _materialChange(() => change(n));
        },
      );

  Widget _previewCard(SignalPreview value) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Controlled signal preview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Deterministic fixture candles only. This is not a profitability backtest and cannot trade.',
            style: TextStyle(color: AppColors.text3),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              Text('Evaluated: ${value.evaluated}'),
              Text('BUY: ${value.buy}'),
              Text('SELL: ${value.sell}'),
              Text('Neutral: ${value.neutral}'),
              Text('Warm-up rejected: ${value.warmup}'),
            ],
          ),
          const SizedBox(height: 12),
          ...value.signals
              .where((s) => s['decision'] != 'neutral')
              .take(8)
              .map(
                (s) => Text(
                  '${s['timestamp']} — ${s['decision'].toString().toUpperCase()} because its completed-candle condition passed.',
                ),
              ),
        ],
      ),
    ),
  );
}
