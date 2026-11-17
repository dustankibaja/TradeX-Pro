import 'dart:convert';

const strategySchemaVersion = '1.0.0';
Map<String, dynamic> _copyMap(Map<String, dynamic> value) =>
    jsonDecode(jsonEncode(value)) as Map<String, dynamic>;

/// Lossless schema-1.0 strategy model. Unknown visual shapes remain intact and
/// are shown read-only instead of being coerced into an EMA crossover.
class StrategyDefinition {
  StrategyDefinition({
    required this.id,
    required this.version,
    required this.name,
    required this.description,
    required this.timeframe,
    required this.buyFast,
    required this.buySlow,
    required this.sellFast,
    required this.sellSlow,
    required this.groupOperator,
    required this.stopLoss,
    required this.takeProfit,
    required this.riskPercent,
    required this.maxPositions,
    required this.sessionStart,
    required this.sessionEnd,
    required this.oppositeExit,
    required this.maxHoldingCandles,
    Map<String, dynamic>? longEntry,
    Map<String, dynamic>? shortEntry,
    this.configurationHash,
    this.confirmed = false,
  }) : longEntry = longEntry ?? _ema(buyFast, buySlow, 'crosses_above'),
       shortEntry = shortEntry ?? _ema(sellFast, sellSlow, 'crosses_below');

  String id,
      name,
      description,
      timeframe,
      groupOperator,
      sessionStart,
      sessionEnd;
  int version,
      buyFast,
      buySlow,
      sellFast,
      sellSlow,
      maxPositions,
      maxHoldingCandles;
  double stopLoss, takeProfit, riskPercent;
  bool oppositeExit, confirmed;
  Map<String, dynamic> longEntry, shortEntry;
  String? configurationHash;

  static Map<String, dynamic> _ema(int a, int b, String op) => {
    'type': 'group',
    'operator': 'AND',
    'conditions': [
      {
        'type': 'comparison',
        'left': {'type': 'indicator', 'indicator': 'EMA', 'period': a},
        'operator': op,
        'right': {'type': 'indicator', 'indicator': 'EMA', 'period': b},
      },
    ],
  };
  static List<int>? _simple(Map<String, dynamic> n, String op) {
    try {
      final xs = n['conditions'] as List;
      final c = xs.single as Map<String, dynamic>;
      final l = c['left'] as Map<String, dynamic>,
          r = c['right'] as Map<String, dynamic>;
      if (n['type'] != 'group' ||
          n['operator'] != 'AND' ||
          xs.length != 1 ||
          c['operator'] != op ||
          l['type'] != 'indicator' ||
          r['type'] != 'indicator' ||
          l['indicator'] != 'EMA' ||
          r['indicator'] != 'EMA')
        return null;
      return [(l['period'] as num).toInt(), (r['period'] as num).toInt()];
    } catch (_) {
      return null;
    }
  }

  bool get visuallyEditable =>
      _simple(longEntry, 'crosses_above') != null &&
      _simple(shortEntry, 'crosses_below') != null;

  factory StrategyDefinition.emaTemplate() => StrategyDefinition(
    id: 'ema-${DateTime.now().microsecondsSinceEpoch}',
    version: 1,
    name: 'My EMA crossover',
    description: 'A completed-candle trend strategy.',
    timeframe: 'H1',
    buyFast: 20,
    buySlow: 50,
    sellFast: 20,
    sellSlow: 50,
    groupOperator: 'AND',
    stopLoss: 20,
    takeProfit: 40,
    riskPercent: .25,
    maxPositions: 1,
    sessionStart: '00:00',
    sessionEnd: '23:59',
    oppositeExit: true,
    maxHoldingCandles: 24,
  );

  Map<String, dynamic> toJson() {
    if (visuallyEditable) {
      longEntry = _ema(buyFast, buySlow, 'crosses_above');
      shortEntry = _ema(sellFast, sellSlow, 'crosses_below');
    }
    final v = <String, dynamic>{
      'schema_version': strategySchemaVersion,
      'strategy_id': id,
      'version': version,
      'name': name,
      'description': description,
      'symbol': 'EURUSD',
      'timeframe': timeframe,
      'evaluation': 'completed_candle',
      'long_entry': _copyMap(longEntry),
      'short_entry': _copyMap(shortEntry),
      'session': {'timezone': 'UTC', 'start': sessionStart, 'end': sessionEnd},
      'risk': {
        'risk_per_trade_percent': riskPercent,
        'maximum_simultaneous_positions': maxPositions,
      },
      'exits': {
        'stop_loss_pips': stopLoss,
        'take_profit_pips': takeProfit,
        'opposite_signal': oppositeExit,
        'maximum_holding_candles': maxHoldingCandles,
      },
      'confirmed_for_testing': confirmed,
    };
    if (configurationHash != null) v['configuration_hash'] = configurationHash;
    return v;
  }

  factory StrategyDefinition.fromJson(Map<String, dynamic> v) {
    const allowed = {
      'schema_version',
      'strategy_id',
      'version',
      'name',
      'description',
      'symbol',
      'timeframe',
      'evaluation',
      'long_entry',
      'short_entry',
      'session',
      'risk',
      'exits',
      'confirmed_for_testing',
      'configuration_hash',
    };
    if (v.keys.any((k) => !allowed.contains(k)) ||
        v['schema_version'] != strategySchemaVersion ||
        v['symbol'] != 'EURUSD' ||
        v['evaluation'] != 'completed_candle')
      throw const FormatException('Unsupported or unsafe strategy format.');
    final l = _copyMap(v['long_entry'] as Map<String, dynamic>),
        s = _copyMap(v['short_entry'] as Map<String, dynamic>),
        a = _simple(l, 'crosses_above'),
        b = _simple(s, 'crosses_below');
    final se = v['session'] as Map<String, dynamic>,
        r = v['risk'] as Map<String, dynamic>,
        e = v['exits'] as Map<String, dynamic>;
    final x = StrategyDefinition(
      id: v['strategy_id'] as String,
      version: v['version'] as int,
      name: v['name'] as String,
      description: v['description'] as String? ?? '',
      timeframe: v['timeframe'] as String,
      buyFast: a?[0] ?? 20,
      buySlow: a?[1] ?? 50,
      sellFast: b?[0] ?? 20,
      sellSlow: b?[1] ?? 50,
      groupOperator: l['operator'] as String? ?? 'AND',
      stopLoss: (e['stop_loss_pips'] as num).toDouble(),
      takeProfit: (e['take_profit_pips'] as num).toDouble(),
      riskPercent: (r['risk_per_trade_percent'] as num).toDouble(),
      maxPositions: (r['maximum_simultaneous_positions'] as num).toInt(),
      sessionStart: se['start'] as String,
      sessionEnd: se['end'] as String,
      oppositeExit: e['opposite_signal'] as bool,
      maxHoldingCandles: (e['maximum_holding_candles'] as num).toInt(),
      longEntry: l,
      shortEntry: s,
      configurationHash: v['configuration_hash'] as String?,
      confirmed: v['confirmed_for_testing'] as bool? ?? false,
    );
    x.validate();
    return x;
  }
  void validate() {
    if (name.trim().isEmpty || name.length > 80)
      throw const FormatException(
        'Enter a strategy name (maximum 80 characters).',
      );
    if (!{'M15', 'H1', 'H4', 'D1'}.contains(timeframe))
      throw const FormatException('Choose a supported timeframe.');
    if (visuallyEditable &&
        ([buyFast, buySlow, sellFast, sellSlow].any((v) => v < 1 || v > 500) ||
            buyFast >= buySlow ||
            sellFast >= sellSlow))
      throw const FormatException(
        'EMA periods must be 1–500 and fast below slow.',
      );
    if (riskPercent < .01 || riskPercent > 2)
      throw const FormatException('Risk must be between 0.01% and 2%.');
    if (stopLoss <= 0 || takeProfit <= 0)
      throw const FormatException('Stops and targets must be positive.');
    if (maxPositions < 1 || maxPositions > 10)
      throw const FormatException('Maximum positions must be from 1 to 10.');
  }

  static String _op(Map<String, dynamic> v) {
    if (v['type'] == 'price') return '${v['field']}'.replaceAll('_', ' ');
    if (v['type'] == 'constant') return '${v['value']}';
    if (v['indicator'] == 'MACD')
      return 'MACD ${v['fast']}/${v['slow']}/${v['signal']} ${v['component'] ?? 'line'}';
    return '${v['period']}-period ${v['indicator']}';
  }

  static String _cond(Map<String, dynamic> v) {
    if (v['type'] == 'group')
      return (v['conditions'] as List)
          .map((x) => '(${_cond(x as Map<String, dynamic>)})')
          .join(' ${v['operator']} ');
    return '${_op(v['left'] as Map<String, dynamic>)} ${('${v['operator']}').replaceAll('_', ' ')} ${_op(v['right'] as Map<String, dynamic>)}';
  }

  String get explanation =>
      'On each completed EUR/USD $timeframe candle, generate a BUY signal when ${_cond(longEntry)}, and a SELL signal when ${_cond(shortEntry)}. Evaluate between $sessionStart and $sessionEnd UTC. Use a ${stopLoss.toStringAsFixed(1)}-pip stop loss and ${takeProfit.toStringAsFixed(1)}-pip take profit. Risk no more than ${riskPercent.toStringAsFixed(2)}% per trade with at most $maxPositions position(s). ${oppositeExit ? 'Exit on an opposite signal.' : 'Do not exit solely on an opposite signal.'} Hold for at most $maxHoldingCandles candles. Signals cannot place broker orders.';
  String exportJson() => const JsonEncoder.withIndent('  ').convert(toJson());
  StrategyDefinition copy() => StrategyDefinition.fromJson(
    jsonDecode(exportJson()) as Map<String, dynamic>,
  );
}
