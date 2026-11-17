import 'dart:convert';
import 'dart:io';
import 'strategy_model.dart';

class TeachProposal {
  const TeachProposal({
    required this.state,
    required this.provider,
    required this.questions,
    required this.ambiguities,
    required this.unsupported,
    required this.limitation,
    required this.proposalState,
    this.strategy,
  });
  final String state, provider, limitation;
  final List<String> questions, ambiguities, unsupported;
  final Map<String, dynamic> proposalState;
  final StrategyDefinition? strategy;
  bool get complete => state == 'draft_complete' && strategy != null;
}

abstract class TeachClient {
  Future<TeachProposal> interpret(
    String description, {
    Map<String, dynamic>? previous,
  });
}

class LocalTeachClient implements TeachClient {
  const LocalTeachClient();
  @override
  Future<TeachProposal> interpret(
    String description, {
    Map<String, dynamic>? previous,
  }) async {
    final executable = File(
      '${File(Platform.resolvedExecutable).parent.path}\\runtime\\emtifize-strategy.exe',
    );
    if (!await executable.exists())
      throw StateError('The packaged strategy interpreter is unavailable.');
    final folder = await Directory.systemTemp.createTemp('emtifize-teach-');
    try {
      final request = File('${folder.path}\\request.json');
      await request.writeAsString(
        jsonEncode({
          'description': description,
          'strategy_id': 'taught-${DateTime.now().microsecondsSinceEpoch}',
          'name': 'Taught strategy',
          if (previous != null) 'previous': previous,
        }),
      );
      final result = await Process.run(executable.path, [
        'interpret',
        request.path,
      ], workingDirectory: executable.parent.path);
      if (result.exitCode != 0)
        throw FormatException('I could not safely interpret that description.');
      final root = jsonDecode(result.stdout as String) as Map<String, dynamic>;
      final value = root['proposal'] as Map<String, dynamic>;
      StrategyDefinition? strategy;
      if (root['strategy'] is Map<String, dynamic>) {
        strategy = StrategyDefinition.fromJson(
          root['strategy'] as Map<String, dynamic>,
        );
      }
      List<String> strings(String key) =>
          (value[key] as List<dynamic>? ?? []).map((v) => '$v').toList();
      return TeachProposal(
        state: value['state'] as String,
        provider: value['provider'] as String,
        questions: strings('unresolved_questions'),
        ambiguities: strings('ambiguous_instructions'),
        unsupported: strings('unsupported_instructions'),
        limitation: value['limitation'] as String,
        proposalState: Map<String, dynamic>.from(value),
        strategy: strategy,
      );
    } finally {
      if (await folder.exists()) await folder.delete(recursive: true);
    }
  }
}
