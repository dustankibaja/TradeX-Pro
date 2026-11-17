import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'strategy_model.dart';
import 'teach_client.dart';

class TeachMyBotDialog extends StatefulWidget {
  const TeachMyBotDialog({super.key, required this.client});
  final TeachClient client;
  @override
  State<TeachMyBotDialog> createState() => _TeachMyBotDialogState();
}

class _TeachMyBotDialogState extends State<TeachMyBotDialog> {
  final _controller = TextEditingController();
  TeachProposal? _proposal;
  bool _busy = false;
  String? _error;
  Future<void> _interpret() async {
    if (_controller.text.trim().isEmpty) {
      setState(() => _error = 'Describe the strategy first.');
      return;
    }
    final previous = _proposal?.proposalState;
    setState(() {
      _busy = true;
      _error = null;
      _proposal = null;
    });
    try {
      final value = await widget.client.interpret(
        _controller.text,
        previous: previous,
      );
      if (mounted) setState(() => _proposal = value);
    } catch (e) {
      if (mounted)
        setState(
          () => _error = '$e'
              .replaceFirst('Bad state: ', '')
              .replaceFirst('FormatException: ', ''),
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Teach My Bot'),
    content: SizedBox(
      width: 760,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Describe explicit rules in everyday language. The local fallback does not send text to an external AI service.',
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              maxLength: 4000,
              minLines: 4,
              maxLines: 9,
              decoration: const InputDecoration(
                labelText: 'Your strategy description',
                hintText:
                    'Buy EURUSD when the 20 EMA crosses above the 50 EMA on H1…',
              ),
            ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: AppColors.red)),
            if (_proposal != null) ...[
              const SizedBox(height: 12),
              Text(
                _proposal!.complete
                    ? 'Draft complete — backend validation passed'
                    : 'Clarification needed',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _proposal!.complete
                      ? AppColors.green
                      : AppColors.amber,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Interpreter: ${_proposal!.provider} · No external transmission',
              ),
              const SizedBox(height: 8),
              if (_proposal!.proposalState['parsed_facts'] is Map)
                Text(
                  'Carried-forward user facts: ${(_proposal!.proposalState['parsed_facts'] as Map).keys.join(', ')}',
                  style: const TextStyle(color: AppColors.text3),
                ),
              ..._proposal!.questions.map(
                (q) => ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: Text(q),
                ),
              ),
              ..._proposal!.ambiguities.map(
                (q) => ListTile(
                  leading: const Icon(Icons.warning_amber),
                  title: Text(q),
                ),
              ),
              ..._proposal!.unsupported.map(
                (q) => ListTile(
                  leading: const Icon(Icons.block),
                  title: Text('Unsupported: $q'),
                ),
              ),
              Text(
                _proposal!.limitation,
                style: const TextStyle(color: AppColors.text3),
              ),
            ],
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton.icon(
        onPressed: _busy ? null : _interpret,
        icon: const Icon(Icons.auto_awesome),
        label: Text(_busy ? 'Interpreting…' : 'Interpret rules'),
      ),
      if (_proposal?.complete == true)
        FilledButton(
          onPressed: () =>
              Navigator.pop<StrategyDefinition>(context, _proposal!.strategy),
          child: const Text('Open draft in visual editor'),
        ),
    ],
  );
}
