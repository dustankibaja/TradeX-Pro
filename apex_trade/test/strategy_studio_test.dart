import 'dart:convert';

import 'package:apex_trade/features/strategy_studio/strategy_model.dart';
import 'package:apex_trade/features/strategy_studio/strategy_store.dart';
import 'package:apex_trade/features/strategy_studio/strategy_studio_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryStore implements StrategyStore {
  List<StrategyDefinition> values = [];
  @override
  Future<List<StrategyDefinition>> load() async => values;
  @override
  Future<void> save(List<StrategyDefinition> strategies) async {
    values = strategies
        .map((s) => StrategyDefinition.fromJson(jsonDecode(s.exportJson())))
        .toList();
  }
}

void main() {
  test('EMA definition export and import are equivalent', () {
    final original = StrategyDefinition.emaTemplate();
    final imported = StrategyDefinition.fromJson(
      jsonDecode(original.exportJson()),
    );
    expect(imported.exportJson(), original.exportJson());
    expect(imported.explanation, contains('cannot place broker orders'));
  });

  test('invalid risk and malicious fields are rejected', () {
    final value = StrategyDefinition.emaTemplate()..riskPercent = 20;
    expect(value.validate, throwsFormatException);
    final json =
        jsonDecode(StrategyDefinition.emaTemplate().exportJson())
            as Map<String, dynamic>;
    json['python'] = 'do_bad_thing()';
    expect(() => StrategyDefinition.fromJson(json), throwsFormatException);
  });

  testWidgets('ordinary user can create validate save and reopen strategy', (
    tester,
  ) async {
    final store = MemoryStore();
    await tester.binding.setSurfaceSize(const Size(1500, 1000));
    await tester.pumpWidget(
      MaterialApp(home: StrategyStudioScreen(store: store)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create my first strategy'));
    await tester.pumpAndSettle();
    expect(find.text('BUY conditions'), findsOneWidget);
    expect(find.text('SELL conditions'), findsOneWidget);
    await tester.ensureVisible(find.text('Validate and save strategy'));
    await tester.tap(find.text('Validate and save strategy'));
    await tester.pumpAndSettle();
    expect(store.values, hasLength(1));
    expect(store.values.single.name, 'My EMA crossover');
    await tester.pumpWidget(
      MaterialApp(home: StrategyStudioScreen(store: store)),
    );
    await tester.pumpAndSettle();
    expect(find.text('My EMA crossover'), findsWidgets);
    expect(find.textContaining('completed EUR/USD H1 candle'), findsOneWidget);
  });
}
