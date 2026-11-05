import 'dart:convert';

import 'package:apex_trade/features/engine_status/saved_pairing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const readToken = 'rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr';
  const controlToken = 'cccccccccccccccccccccccccccccccccccccccc';
  const address = 'https://wingerapp1.tail8208bf.ts.net';

  test('scan Windows QR validates and restores both private tokens', () {
    final encoded = jsonEncode({
      'type': 'emtifize-pair-v1',
      'url': address,
      'read_token': readToken,
      'control_token': controlToken,
    });
    final parsed = SavedPairing.fromQr(encoded);
    expect(parsed.url, address);
    expect(parsed.readToken, readToken);
    expect(parsed.controlToken, controlToken);
    final restored = SavedPairing.fromJson(parsed.toJson());
    expect(restored.url, address);
    expect(restored.readToken, readToken);
    expect(restored.controlToken, controlToken);
  });

  test('rejects URL sending tokens to non-private remote hosts', () {
    final encoded = jsonEncode({
      'type': 'emtifize-pair-v1',
      'url': 'https://evil.example',
      'read_token': readToken,
      'control_token': controlToken,
    });
    expect(() => SavedPairing.fromQr(encoded), throwsFormatException);
  });

  test('QR tokens must be separate and strong', () {
    final encoded = jsonEncode({
      'type': 'emtifize-pair-v1',
      'url': address,
      'read_token': readToken,
      'control_token': readToken,
    });
    expect(() => SavedPairing.fromQr(encoded), throwsFormatException);
  });

  test('saved pairing rejects accidental cleartext HTTP', () {
    final encoded = {
      'version': 1,
      'url': 'http://wingerapp1.tail8208bf.ts.net',
      'read_token': readToken,
      'control_token': controlToken,
    };
    expect(() => SavedPairing.fromJson(encoded), throwsFormatException);
  });

  test('rejects generic or oversized QR codes', () {
    expect(() => SavedPairing.fromQr('hello'), throwsFormatException);
    expect(() => SavedPairing.fromQr('x' * 6000), throwsFormatException);
  });
}
