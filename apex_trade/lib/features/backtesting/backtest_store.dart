import 'dart:convert';
import 'dart:io';
import 'backtest_model.dart';

class BacktestStore {
  const BacktestStore();
  Future<File> _file() async {
    final root = Platform.environment['LOCALAPPDATA'];
    if (root == null)
      throw StateError('Local application storage is unavailable.');
    final d = Directory('$root\\EmtifizeAI');
    await d.create(recursive: true);
    return File('${d.path}\\backtests-v1.json');
  }

  Future<List<BacktestResult>> load() async {
    final f = await _file();
    if (!await f.exists()) return [];
    final v = jsonDecode(await f.readAsString());
    if (v is! List)
      throw const FormatException('Saved backtests are malformed.');
    return v
        .map((e) => BacktestResult(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> save(List<BacktestResult> values) async {
    final f = await _file(), tmp = File('${f.path}.tmp');
    await tmp.writeAsString(
      jsonEncode(values.map((e) => e.value).toList()),
      flush: true,
    );
    await tmp.rename(f.path);
  }

  Future<Directory> exportFolder() async {
    final home = Platform.environment['USERPROFILE'];
    if (home == null) throw StateError('User profile is unavailable.');
    final d = Directory('$home\\Documents\\Emtifize AI Exports');
    await d.create(recursive: true);
    return d;
  }

  Future<List<File>> export(BacktestResult r) async {
    final d = await exportFolder(), base = 'backtest-${r.id}';
    final jsonFile = File('${d.path}\\$base.json'),
        csv = File('${d.path}\\$base-trades.csv'),
        report = File('${d.path}\\$base-report.txt');
    await jsonFile.writeAsString(r.encode(), flush: true);
    final b = StringBuffer(
      'side,entry_time,exit_time,entry,exit,lots,stop,target,gross_pnl,commission,financing,net_pnl,reason\n',
    );
    for (final t in r.trades) {
      b.writeln(
        [
          'side',
          'entry_time',
          'exit_time',
          'entry',
          'exit',
          'lots',
          'stop',
          'target',
          'gross_pnl',
          'commission',
          'financing',
          'net_pnl',
          'reason',
        ].map((k) => t[k] ?? '').join(','),
      );
    }
    await csv.writeAsString(b.toString(), flush: true);
    await report.writeAsString(
      'EMTIFIZE AI — HISTORICAL SIMULATION\nNot actual profit and not a promise of future results.\n\n${r.encode()}',
      flush: true,
    );
    return [report, csv, jsonFile];
  }
}
