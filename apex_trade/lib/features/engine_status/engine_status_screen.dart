import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'engine_status_client.dart';

/// Human-friendly pairing UX; no trading controls and no stored broker secrets.
class EngineStatusScreen extends StatefulWidget {
  const EngineStatusScreen({super.key});

  @override
  State<EngineStatusScreen> createState() => _EngineStatusScreenState();
}

class _EngineStatusScreenState extends State<EngineStatusScreen> {
  final _url = TextEditingController();
  final _token = TextEditingController();
  final _client = EngineStatusClient();
  EngineStatus? _current;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _url.dispose();
    _token.clear();
    _token.dispose();
    _client.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final response = await _client.fetchStatus(
        baseUrl: _url.text,
        readOnlyToken: _token.text,
      );
      if (!mounted) return;
      setState(() => _current = response);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _current = null;
        _error = error is FormatException
            ? error.message
            : 'Cannot reach the engine. Check your secure API connection.';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = _current;
    final isOnline = value?.state == 'running' && value?.stale == false;
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        backgroundColor: AppColors.bg0,
        foregroundColor: Colors.white,
        title: const Text('Trading engine'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.hub_outlined, color: AppColors.accent, size: 42),
            const SizedBox(height: 12),
            const Text(
              'Connect your MT5 bot',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 24,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            const Text(
              'View the engine status securely from your phone. '
              'Trade execution and remote controls are intentionally disabled '
              'while strategy validation is incomplete.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.text3, height: 1.5),
            ),
            const SizedBox(height: 26),
            _fieldLabel('Secure API address'),
            TextField(
              controller: _url,
              autocorrect: false,
              keyboardType: TextInputType.url,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'https://your-private-engine.example',
                hintStyle: TextStyle(color: AppColors.text3),
              ),
            ),
            const SizedBox(height: 18),
            _fieldLabel('Read-only pairing token'),
            TextField(
              controller: _token,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your engine access token',
                hintStyle: TextStyle(color: AppColors.text3),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _busy ? null : _check,
              icon: _busy
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.sync_rounded),
              label: Text(_busy ? 'Checking engine...' : 'Check connection'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bg2,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(
                      isOnline ? Icons.check_circle_outline : Icons.cloud_off_outlined,
                      color: isOnline ? Colors.greenAccent : Colors.orangeAccent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        value == null
                            ? 'Not connected'
                            : value.stale ? 'Offline / stale heartbeat' : value.state.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  _detail('Mode', value?.mode ?? 'Unknown'),
                  _detail('Strategy', value?.strategy ?? 'Unavailable'),
                  _detail('Symbols', value?.symbols.join(', ') ?? 'None'),
                  _detail('Last heartbeat', value?.updatedAt ?? 'Not received'),
                  if (value?.tradingEnabled == true) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'WARNING: the engine reports that live trading is configured. '
                      'Do not use funded accounts before certification.',
                      style: TextStyle(color: Colors.orangeAccent),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Other app balances, chart quotes, signals and trade history '
              'are demonstration data—not live brokerage records. '
              'Your broker password never belongs in this screen.',
              style: TextStyle(color: AppColors.text3, fontSize: 12, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(value, style: const TextStyle(
      color: Colors.white, fontWeight: FontWeight.w600,
    )),
  );

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 110,
          child: Text(label, style: const TextStyle(color: AppColors.text3))),
        Expanded(child: Text(value,
          style: const TextStyle(color: Colors.white))),
      ],
    ),
  );
}
