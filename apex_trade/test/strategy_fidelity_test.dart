import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_trade/features/strategy_studio/strategy_model.dart';

void main() {
  test('nested mixed-indicator tree round trips losslessly', () {
    final base = StrategyDefinition.emaTemplate().toJson();
    base['configuration_hash'] = 'canonical-from-backend';
    base['long_entry'] = {
      'type': 'group',
      'operator': 'AND',
      'conditions': [
        {
          'type': 'comparison',
          'left': {'type': 'indicator', 'indicator': 'RSI', 'period': 14},
          'operator': 'crosses_above',
          'right': {'type': 'constant', 'value': 30},
        },
        {
          'type': 'group',
          'operator': 'OR',
          'conditions': [
            {
              'type': 'comparison',
              'left': {'type': 'price', 'field': 'close'},
              'operator': 'greater_than',
              'right': {'type': 'indicator', 'indicator': 'EMA', 'period': 200},
            },
            {
              'type': 'comparison',
              'left': {
                'type': 'indicator',
                'indicator': 'MACD',
                'fast': 12,
                'slow': 26,
                'signal': 9,
                'component': 'line',
              },
              'operator': 'greater_than',
              'right': {'type': 'constant', 'value': 0},
            },
          ],
        },
      ],
    };
    final encoded = jsonEncode(base);
    final model = StrategyDefinition.fromJson(jsonDecode(encoded));
    expect(model.visuallyEditable, isFalse);
    expect(jsonDecode(model.exportJson()), jsonDecode(encoded));
    expect(model.explanation, contains('14-period RSI'));
    expect(model.configurationHash, 'canonical-from-backend');
  });

  test('SMA and mixed EMA/SMA are not rewritten as EMA', () {
    for (final pair in [('SMA', 'SMA'), ('EMA', 'SMA')]) {
      final value = StrategyDefinition.emaTemplate().toJson();
      final c =
          ((value['long_entry'] as Map)['conditions'] as List).single as Map;
      (c['left'] as Map)['indicator'] = pair.$1;
      (c['right'] as Map)['indicator'] = pair.$2;
      final model = StrategyDefinition.fromJson(value);
      expect(model.visuallyEditable, isFalse);
      expect(model.toJson()['long_entry'], value['long_entry']);
    }
  });
}
