import 'dart:convert';
import 'dart:io';

import 'strategy_model.dart';

abstract class StrategyStore {
  Future<List<StrategyDefinition>> load();
  Future<void> save(List<StrategyDefinition> strategies);
}

class LocalStrategyStore implements StrategyStore {
  const LocalStrategyStore();
  File get _file {
    final root = Platform.environment['LOCALAPPDATA'];
    if (root == null)
      throw StateError('Windows local application storage is unavailable.');
    return File('$root\\EmtifizeAI\\strategies-v1.json');
  }

  @override
  Future<List<StrategyDefinition>> load() async {
    if (!await _file.exists()) return [];
    final values = jsonDecode(await _file.readAsString()) as List<dynamic>;
    return values
        .map(
          (value) => StrategyDefinition.fromJson(value as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> save(List<StrategyDefinition> strategies) async {
    await _file.parent.create(recursive: true);
    final temporary = File('${_file.path}.tmp');
    await temporary.writeAsString(
      jsonEncode(strategies.map((s) => s.toJson()).toList()),
      flush: true,
    );
    if (await _file.exists()) await _file.delete();
    await temporary.rename(_file.path);
  }
}
