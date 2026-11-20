import 'dart:convert';

class BacktestResult {
  BacktestResult(this.value);
  final Map<String, dynamic> value;
  Map<String, dynamic> get metrics =>
      Map<String, dynamic>.from(value['metrics'] as Map);
  Map<String, dynamic> get manifest =>
      Map<String, dynamic>.from(value['manifest'] as Map);
  Map<String, dynamic> get report => value['report'] is Map
      ? Map<String, dynamic>.from(value['report'] as Map)
      : const {};
  List<Map<String, dynamic>> get trades => (value['trades'] as List? ?? [])
      .map((v) => Map<String, dynamic>.from(v as Map))
      .toList();
  List<Map<String, dynamic>> get equity =>
      (value['equity_curve'] as List? ?? [])
          .map((v) => Map<String, dynamic>.from(v as Map))
          .toList();
  String get id => '${manifest['run_id']}';
  String get fingerprint => '${manifest['simulation_content_fingerprint'] ?? ''}';
  String get name =>
      '${value['saved_name'] ?? 'Backtest ${id.substring(0, 8)}'}';
  set name(String v) => value['saved_name'] = v;
  String encode() => const JsonEncoder.withIndent('  ').convert(value);
}

class DatasetValidation {
  const DatasetValidation({
    required this.dataset,
    required this.rows,
    required this.firstUtc,
    required this.lastUtc,
    required this.warnings,
  });
  final Map<String, dynamic> dataset;
  final int rows;
  final String firstUtc, lastUtc;
  final List<String> warnings;
  factory DatasetValidation.fromJson(Map<String, dynamic> v) =>
      DatasetValidation(
        dataset: Map<String, dynamic>.from(v['dataset'] as Map),
        rows: v['rows'] as int,
        firstUtc: '${v['first_utc']}',
        lastUtc: '${v['last_utc']}',
        warnings: (v['warnings'] as List? ?? []).map((e) => '$e').toList(),
      );
}
