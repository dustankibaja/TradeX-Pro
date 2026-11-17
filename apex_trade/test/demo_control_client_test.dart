import 'dart:convert';

import 'package:apex_trade/features/engine_status/demo_control_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const readToken = 'rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr';
  const controlToken = 'cccccccccccccccccccccccccccccccccccccc';

  test('pause uses a distinct control token and no order endpoint', () async {
    final client = DemoControlClient(client: MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.scheme, 'https');
      expect(request.url.path, '/v1/demo-control/pause');
      expect(request.headers['Authorization'], 'Bearer $controlToken');
      expect(request.bodyBytes, isEmpty);
      return http.Response(jsonEncode({'ok': true, 'remote_paused': true}), 200);
    }));
    expect(await client.setPaused(
      baseUrl: 'https://private.tail.ts.net',
      controlToken: controlToken,
      paused: true,
    ), true);
    client.dispose();
  });

  test('resume must be explicitly confirmed by the caller', () async {
    final client = DemoControlClient(client: MockClient((request) async {
      expect(request.url.path, '/v1/demo-control/resume');
      return http.Response(jsonEncode({'ok': true, 'remote_paused': false}), 200);
    }));
    expect(await client.setPaused(
      baseUrl: 'https://private.tail.ts.net',
      controlToken: controlToken,
      paused: false,
    ), false);
    client.dispose();
  });

  test('backend rejects unsafe resume with 409', () async {
    final client = DemoControlClient(client: MockClient((_) async =>
        http.Response('{"error":"demo_only_resume_blocked"}', 409)));
    expect(
      () => client.setPaused(
        baseUrl: 'https://private.tail.ts.net',
        controlToken: controlToken,
        paused: false,
      ),
      throwsA(isA<FormatException>()),
    );
    client.dispose();
  });

  test('cleartext external connections are blocked even with a token', () async {
    final client = DemoControlClient(client: MockClient((_) async {
      fail('Never send control secret via public HTTP');
    }));
    expect(
      () => client.setPaused(
        baseUrl: 'http://untrusted.example',
        controlToken: controlToken,
        paused: true,
      ),
      throwsA(isA<FormatException>()),
    );
    client.dispose();
  });
}
