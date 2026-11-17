import 'dart:convert';

import 'package:apex_trade/features/engine_status/demo_account_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const token = '1234567890123456789012345678901234567890';

  test('fetches actual broker DEMO balances over authenticated HTTPS', () async {
    final client = DemoAccountClient(client: MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.scheme, 'https');
      expect(request.url.path, '/v1/demo-account');
      expect(request.headers['Authorization'], 'Bearer $token');
      return http.Response(jsonEncode({
        'schema_version': 1,
        'available': true,
        'stale': false,
        'account_type': 'demo',
        'currency': 'USD',
        'updated_at': '2026-11-05T09:00:00+00:00',
        'balance': 10000.12,
        'equity': 10120.34,
        'margin_free': 9540.55,
        'floating_pnl': 120.22,
        'positions': [{
          'symbol': 'EURUSD', 'side': 'BUY', 'volume': 0.01,
          'open_price': 1.12111, 'current_price': 1.12122,
          'profit': 1.65, 'opened_at': '2026-11-05T09:00:00+00:00'
        }],
        'recent_closing_deals': [{
          'symbol': 'EURUSD', 'deal_side': 'SELL', 'volume': 0.01,
          'net_pnl': 6.20, 'closed_at': '2026-11-05T09:00:00+00:00'
        }],
      }), 200);
    }));
    final data = await client.fetch(baseUrl: 'https://test.ts.net', readOnlyToken: token);
    expect(data.available, true);
    expect(data.balance, 10000.12);
    expect(data.equity, 10120.34);
    expect(data.floatingPnl, 120.22);
    expect(data.positions.single.symbol, 'EURUSD');
    expect(data.recentClosingDeals.single.netPnl, 6.2);
    client.dispose();
  });

  test('refuses to reveal stale or live-account values', () {
    final data = DemoAccount.fromJson({
      'schema_version': 1, 'available': true, 'stale': true,
      'account_type': 'demo', 'balance': 100000000,
    });
    expect(data.available, false);
    expect(data.balance, null);
    final live = DemoAccount.fromJson({
      'schema_version': 1, 'available': true, 'stale': false,
      'account_type': 'live', 'balance': 100000000,
    });
    expect(live.balance, null);
  });

  test('503 hides all broker figures', () async {
    final client = DemoAccountClient(client: MockClient((_) async =>
        http.Response('{"error":"demo_engine_unavailable"}', 503)));
    final data = await client.fetch(baseUrl: 'https://test.ts.net', readOnlyToken: token);
    expect(data.available, false);
    expect(data.positions, isEmpty);
    client.dispose();
  });

  test('404 explains that Windows backend requires upgrade', () async {
    final client = DemoAccountClient(client: MockClient((_) async =>
        http.Response('{"error":"not_found"}', 404)));
    expect(
      () => client.fetch(baseUrl: 'https://test.ts.net', readOnlyToken: token),
      throwsA(isA<FormatException>()),
    );
    client.dispose();
  });

  test('never sends bearer secret over external cleartext HTTP', () async {
    final client = DemoAccountClient(client: MockClient((_) async {
      fail('Must block external HTTP before sending token');
    }));
    expect(
      () => client.fetch(baseUrl: 'http://test.ts.net', readOnlyToken: token),
      throwsA(isA<FormatException>()),
    );
    client.dispose();
  });
}
