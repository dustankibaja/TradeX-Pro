import 'dart:convert';

const strategySchemaVersion = '1.0.0';

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
    this.confirmed = false,
  });

  String id;
  int version;
  String name;
  String description;
  String timeframe;
  int buyFast, buySlow, sellFast, sellSlow;
  String groupOperator;
  double stopLoss, takeProfit, riskPercent;
  int maxPositions;
  String sessionStart, sessionEnd;
  bool oppositeExit, confirmed;
  int maxHoldingCandles;

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

  Map<String, dynamic> toJson() => {
    'schema_version': strategySchemaVersion,
    'strategy_id': id,
    'version': version,
    'name': name,
    'description': description,
    'symbol': 'EURUSD',
    'timeframe': timeframe,
    'evaluation': 'completed_candle',
    'long_entry': _group(buyFast, buySlow, 'crosses_above'),
    'short_entry': _group(sellFast, sellSlow, 'crosses_below'),
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

  static Map<String, dynamic> _group(int fast, int slow, String operator) => {
    'type': 'group',
    'operator': 'AND',
    'conditions': [
      {
        'type': 'comparison',
        'left': {'type': 'indicator', 'indicator': 'EMA', 'period': fast},
        'operator': operator,
        'right': {'type': 'indicator', 'indicator': 'EMA', 'period': slow},
      },
    ],
  };

  factory StrategyDefinition.fromJson(Map<String, dynamic> value) {
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
    if (value.keys.any((key) => !allowed.contains(key))) {
      throw const FormatException('This file contains unsupported fields.');
    }
    if (value['schema_version'] != strategySchemaVersion ||
        value['symbol'] != 'EURUSD' ||
        value['evaluation'] != 'completed_candle') {
      throw const FormatException('Unsupported or unsafe strategy format.');
    }
    final long = value['long_entry'] as Map<String, dynamic>;
    final short = value['short_entry'] as Map<String, dynamic>;
    Map<String, dynamic> comparison(Map<String, dynamic> group) {
      final items = group['conditions'] as List<dynamic>;
      if (group['type'] != 'group' || items.length != 1) {
        throw const FormatException(
          'This editor supports one EMA condition per side.',
        );
      }
      return items.single as Map<String, dynamic>;
    }

    final buy = comparison(long), sell = comparison(short);
    if (buy['operator'] != 'crosses_above' ||
        sell['operator'] != 'crosses_below') {
      throw const FormatException('The imported comparison is unsupported.');
    }
    final session = value['session'] as Map<String, dynamic>;
    final risk = value['risk'] as Map<String, dynamic>;
    final exits = value['exits'] as Map<String, dynamic>;
    final result = StrategyDefinition(
      id: value['strategy_id'] as String,
      version: value['version'] as int,
      name: value['name'] as String,
      description: value['description'] as String? ?? '',
      timeframe: value['timeframe'] as String,
      buyFast: ((buy['left'] as Map)['period'] as num).toInt(),
      buySlow: ((buy['right'] as Map)['period'] as num).toInt(),
      sellFast: ((sell['left'] as Map)['period'] as num).toInt(),
      sellSlow: ((sell['right'] as Map)['period'] as num).toInt(),
      groupOperator: long['operator'] as String,
      stopLoss: (exits['stop_loss_pips'] as num).toDouble(),
      takeProfit: (exits['take_profit_pips'] as num).toDouble(),
      riskPercent: (risk['risk_per_trade_percent'] as num).toDouble(),
      maxPositions: (risk['maximum_simultaneous_positions'] as num).toInt(),
      sessionStart: session['start'] as String,
      sessionEnd: session['end'] as String,
      oppositeExit: exits['opposite_signal'] as bool,
      maxHoldingCandles: (exits['maximum_holding_candles'] as num).toInt(),
      confirmed: value['confirmed_for_testing'] as bool? ?? false,
    );
    result.validate();
    return result;
  }

  void validate() {
    if (name.trim().isEmpty || name.length > 80)
      throw const FormatException(
        'Enter a strategy name (maximum 80 characters).',
      );
    if (!{'M15', 'H1', 'H4', 'D1'}.contains(timeframe))
      throw const FormatException('Choose a supported timeframe.');
    if ([buyFast, buySlow, sellFast, sellSlow].any((v) => v < 1 || v > 500))
      throw const FormatException('EMA periods must be from 1 to 500.');
    if (buyFast >= buySlow || sellFast >= sellSlow)
      throw const FormatException(
        'The fast EMA must be lower than the slow EMA.',
      );
    if (riskPercent < .01 || riskPercent > 2)
      throw const FormatException('Risk must be between 0.01% and 2%.');
    if (stopLoss <= 0 || takeProfit <= 0)
      throw const FormatException(
        'Stop loss and take profit must be greater than zero.',
      );
    if (maxPositions < 1 || maxPositions > 10)
      throw const FormatException('Maximum positions must be from 1 to 10.');
    final clock = RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$');
    if (!clock.hasMatch(sessionStart) || !clock.hasMatch(sessionEnd))
      throw const FormatException('Session times must use HH:MM UTC.');
  }

  String get explanation =>
      'On each completed EUR/USD $timeframe candle, generate a BUY signal when the '
      '$buyFast-period EMA crosses above the $buySlow-period EMA, and a SELL signal '
      'when the $sellFast-period EMA crosses below the $sellSlow-period EMA. '
      'Evaluate between $sessionStart and $sessionEnd UTC. Use a ${stopLoss.toStringAsFixed(1)}-pip '
      'stop loss and ${takeProfit.toStringAsFixed(1)}-pip take profit. Risk no more than '
      '${riskPercent.toStringAsFixed(2)}% per trade with at most $maxPositions position(s). '
      '${oppositeExit ? 'Exit on an opposite signal.' : 'Do not exit solely on an opposite signal.'} '
      'Hold for at most $maxHoldingCandles candles. Signals cannot place broker orders.';

  String exportJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  StrategyDefinition copy() => StrategyDefinition.fromJson(
    jsonDecode(exportJson()) as Map<String, dynamic>,
  );
}
