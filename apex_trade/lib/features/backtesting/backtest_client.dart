import 'dart:convert';
import 'dart:io';
import '../strategy_studio/strategy_model.dart';
import 'backtest_model.dart';

class BacktestSettings {
  const BacktestSettings({
    this.balance = 10000,
    this.slippage = .2,
    this.commission = 7,
    this.financing = 0,
    this.leverage = 30,
    this.startDate,
    this.endDate,
  });
  final double balance, slippage, commission, financing, leverage;
  final String? startDate, endDate;
  Map<String, dynamic> get costs => {
    'slippage_pips': slippage,
    'commission_per_lot_round_turn': commission,
    'financing_per_lot_per_day': financing,
    'contract_size': 100000,
    'leverage': leverage,
    'minimum_lot': .01,
    'lot_step': .01,
    'maximum_lot': 100,
  };
}

abstract class BacktestClient {
  Future<DatasetValidation> validate(
    String path, {
    required String timeframe,
    required bool synthetic,
  });
  Future<BacktestResult> run(
    String path,
    StrategyDefinition strategy,
    BacktestSettings settings, {
    required bool synthetic,
  });
}

class LocalBacktestClient implements BacktestClient {
  const LocalBacktestClient();
  Future<Map<String, dynamic>> _call(
    String command,
    String path,
    Map<String, dynamic> request,
  ) async {
    if (!Platform.isWindows) {
      throw StateError(
        'Historical simulation is currently available in the Windows beta only. '
        'This Android build does not contain the local simulator runtime.',
      );
    }
    final exe = File(
      '${File(Platform.resolvedExecutable).parent.path}\\runtime\\emtifize-backtest.exe',
    );
    if (!await exe.exists())
      throw StateError('The packaged historical simulator is unavailable.');
    final temp = await Directory.systemTemp.createTemp('emtifize-backtest-');
    try {
      final input = File('${temp.path}\\request.json');
      await input.writeAsString(jsonEncode(request), flush: true);
      final p = await Process.start(exe.path, [
        command,
        input.path,
        path,
      ], workingDirectory: exe.parent.path);
      final out = await p.stdout.transform(utf8.decoder).join(),
          err = await p.stderr.transform(utf8.decoder).join();
      final code = await p.exitCode;
      if (code != 0) {
        try {
          throw FormatException('${(jsonDecode(err) as Map)['error']}');
        } catch (_) {
          throw FormatException('Historical simulation failed safely.');
        }
      }
      return Map<String, dynamic>.from(jsonDecode(out) as Map);
    } finally {
      if (await temp.exists()) await temp.delete(recursive: true);
    }
  }

  Map<String, dynamic> _base(String timeframe, bool synthetic) => {
    'contract_version': '1.0.0',
    'dataset': {
      'symbol': 'EURUSD',
      'timeframe': timeframe,
      'intended_use': 'performance_backtest',
      'permission': synthetic ? 'synthetic_demo' : 'user_supplied_authorized',
      'source': synthetic
          ? 'Customer synthetic demonstration CSV'
          : 'Customer-supplied authorized historical CSV',
    },
  };
  @override
  Future<DatasetValidation> validate(
    String path, {
    required String timeframe,
    required bool synthetic,
  }) async => DatasetValidation.fromJson(
    await _call('validate', path, _base(timeframe, synthetic)),
  );
  @override
  Future<BacktestResult> run(
    String path,
    StrategyDefinition strategy,
    BacktestSettings settings, {
    required bool synthetic,
  }) async {
    final request = _base(strategy.timeframe, synthetic)
      ..addAll({
        'strategy': strategy.toJson(),
        'initial_balance': settings.balance,
        'cost_model': settings.costs,
        'start_date': settings.startDate,
        'end_date': settings.endDate,
      });
    return BacktestResult(await _call('run', path, request));
  }
}
