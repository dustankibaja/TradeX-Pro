import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'backtest_model.dart';

class BacktestStore {
  const BacktestStore();

  Future<Directory> _persistentRoot() async {
    // Retain the existing Windows location so a product update never hides
    // previously saved simulations. Android uses its app documents directory
    // and therefore needs no broad storage permission.
    final legacy = Platform.isWindows ? Platform.environment['LOCALAPPDATA'] : null;
    if (legacy != null && legacy.trim().isNotEmpty) {
      return Directory(p.join(legacy, 'EmtifizeAI'));
    }
    final documents = await getApplicationDocumentsDirectory();
    return Directory(p.join(documents.path, 'EmtifizeAI'));
  }

  Future<File> _file() async {
    final d = await _persistentRoot();
    await d.create(recursive: true);
    return File(p.join(d.path, 'backtests-v1.json'));
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
    // Preserve the existing visible Windows export folder. Android exports stay
    // within app documents until a future explicit share/save action is added.
    final home = Platform.isWindows ? Platform.environment['USERPROFILE'] : null;
    final d = home != null && home.trim().isNotEmpty
        ? Directory(p.join(home, 'Documents', 'Emtifize AI Exports'))
        : Directory(p.join((await _persistentRoot()).path, 'Exports'));
    await d.create(recursive: true);
    return d;
  }

  Future<List<File>> export(BacktestResult r) async {
    final d = await exportFolder(), base = 'backtest-${r.id}';
    final jsonFile = File(p.join(d.path, '$base.json')),
        csv = File(p.join(d.path, '$base-trades.csv')),
        report = File(p.join(d.path, '$base-report.txt'));
    final portable = r.report.isEmpty ? r.value : r.report;
    await jsonFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(portable),
      flush: true,
    );
    final b = StringBuffer(
      'side,entry_time,exit_time,entry,exit,lots,stop,target,gross_pnl,commission,financing,net_pnl,reason\n',
    );
    final ledger = (r.report['historical_trade_ledger'] as List? ?? r.trades)
        .map((v) => Map<String, dynamic>.from(v as Map))
        .toList();
    String cell(Object? value) => '"${'$value'.replaceAll('"', '""')}"';
    for (final t in ledger) {
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
        ].map((k) => cell(t[k] ?? '')).join(','),
      );
    }
    await csv.writeAsString(b.toString(), flush: true);
    await report.writeAsString(
      'EMTIFIZE AI — HISTORICAL SIMULATION\nNot actual profit and not a promise of future results.\n\n${const JsonEncoder.withIndent('  ').convert(portable)}',
      flush: true,
    );
    return [report, csv, jsonFile];
  }
}
