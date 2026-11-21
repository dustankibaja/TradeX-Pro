import 'package:apex_trade/features/backtesting/backtest_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('retains the deterministic simulation fingerprint separately from run ID',
      () {
    final result = BacktestResult({
      'metrics': <String, dynamic>{},
      'manifest': {
        'run_id': 'a1b2c3d4-unique-run',
        'simulation_content_fingerprint': 'content-fingerprint',
      },
      'trades': <dynamic>[],
      'equity_curve': <dynamic>[],
      'report': {
        'label': 'HISTORICAL SIMULATION — NOT BROKER EXECUTION',
        'execution_enabled': false,
      },
    });

    expect(result.id, 'a1b2c3d4-unique-run');
    expect(result.fingerprint, 'content-fingerprint');
    expect(result.report['execution_enabled'], isFalse);
  });
}
