import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:apex_trade/features/engine_status/engine_status_client.dart';

void main() {
  test('reads sanitized engine status using bearer token', () async {
    const secret = '1234567890123456789012345678901234567890';
    final client = EngineStatusClient(
      client: MockClient((request) async {
        expect(request.url.path, '/v1/status');
        expect(request.headers['Authorization'], 'Bearer $secret');
        return http.Response(
          jsonEncode({
            'schema_version': 1,
            'state': 'running',
            'mode': 'dry_run',
            'trading_enabled': false,
            'stale': false,
            'updated_at': '2026-11-04T12:00:00+00:00',
            'strategy': 'atr_breakout',
            'symbols': ['EURUSD'],
          }),
          200,
        );
      }),
    );
    final result = await client.fetchStatus(
      baseUrl: 'https://private-engine.example',
      readOnlyToken: secret,
    );
    expect(result.state, 'running');
    expect(result.mode, 'dry_run');
    expect(result.tradingEnabled, false);
    expect(result.symbols, ['EURUSD']);
    client.dispose();
  });

  test('rejects cleartext external HTTP before sending any request', () async {
    final client = EngineStatusClient(
      client: MockClient((request) async {
        fail('Never issue insecure external request');
      }),
    );
    expect(
      () => client.fetchStatus(
        baseUrl: 'http://example.com',
        readOnlyToken: '12345678901234567890123456789012',
      ),
      throwsA(isA<FormatException>()),
    );
    client.dispose();
  });

  test('stale response never displays active trading', () {
    final status = EngineStatus.fromJson({
      'schema_version': 1,
      'state': 'running',
      'mode': 'live_configuration',
      'trading_enabled': true,
      'stale': true,
      'symbols': [],
    });
    expect(status.state, 'offline');
    expect(status.tradingEnabled, false);
  });
}
