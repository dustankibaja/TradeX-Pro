import 'dart:convert';
import 'dart:io';

import 'strategy_model.dart';

class SignalPreview {
  const SignalPreview({
    required this.evaluated,
    required this.buy,
    required this.sell,
    required this.neutral,
    required this.warmup,
    required this.signals,
  });
  final int evaluated, buy, sell, neutral, warmup;
  final List<Map<String, dynamic>> signals;
}

abstract class StrategyPreviewClient {
  Future<SignalPreview> preview(StrategyDefinition strategy);
}

class LocalStrategyPreviewClient implements StrategyPreviewClient {
  const LocalStrategyPreviewClient();
  @override
  Future<SignalPreview> preview(StrategyDefinition strategy) async {
    strategy.validate();
    final executable = File(
      '${File(Platform.resolvedExecutable).parent.path}\\runtime\\emtifize-strategy.exe',
    );
    if (!await executable.exists())
      throw StateError(
        'The packaged signal evaluator is unavailable. Reinstall the beta.',
      );
    final folder = await Directory.systemTemp.createTemp('emtifize-preview-');
    try {
      final strategyFile = File('${folder.path}\\strategy.json');
      final candleFile = File('${folder.path}\\candles.json');
      await strategyFile.writeAsString(strategy.exportJson());
      final start = DateTime.utc(2026, 1, 5);
      final interval = switch (strategy.timeframe) {
        'M15' => const Duration(minutes: 15),
        'H4' => const Duration(hours: 4),
        'D1' => const Duration(days: 1),
        _ => const Duration(hours: 1),
      };
      final candles = List.generate(96, (index) {
        final close = index < 32
            ? 1.12 - index * .0004
            : index < 64
            ? 1.1072 + (index - 32) * .0006
            : 1.1264 - (index - 64) * .0005;
        return {
          'timestamp': start.add(interval * index).toIso8601String(),
          'open': close,
          'high': close + .0008,
          'low': close - .0008,
          'close': close,
          'complete': true,
          'source':
              'emtifize-synthetic-${strategy.timeframe.toLowerCase()}-fixture-v2',
          'price_basis': 'mid_bid_ask',
        };
      });
      await candleFile.writeAsString(jsonEncode(candles));
      final result = await Process.run(executable.path, [
        'preview',
        strategyFile.path,
        '--candles',
        candleFile.path,
      ], workingDirectory: executable.parent.path);
      if (result.exitCode != 0)
        throw FormatException('Signal preview was rejected: ${result.stderr}');
      final root = jsonDecode(result.stdout as String) as Map<String, dynamic>;
      final value = root['preview'] as Map<String, dynamic>;
      return SignalPreview(
        evaluated: value['evaluated_candle_count'] as int,
        buy: value['buy_signal_count'] as int,
        sell: value['sell_signal_count'] as int,
        neutral: value['neutral_count'] as int,
        warmup: value['warmup_rejected_count'] as int,
        signals: (value['signals'] as List<dynamic>)
            .cast<Map<String, dynamic>>(),
      );
    } finally {
      if (await folder.exists()) await folder.delete(recursive: true);
    }
  }
}
