import 'dart:convert';

import 'package:apex_trade/features/engine_status/pairing_credentials.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const read = 'rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr';
  const control = 'cccccccccccccccccccccccccccccccccccccccccccc';

  test('private Windows QR pairs with exact Tailscale HTTPS host', () {
    final data = PairingCredentials.fromQr(jsonEncode({
      'type': 'emtifize-pair-v1',
      'url': 'https://wingerapp1.tail8208bf.ts.net',
      'read_token': read,
      'control_token': control,
    }));
    expect(data.url, 'https://wingerapp1.tail8208bf.ts.net');
    expect(data.readToken, read);
    expect(data.controlToken, control);
  });

  test('accepts only private HTTPS Tailscale addresses', () {
    for (final url in [
      'http://wingerapp1.tail8208bf.ts.net',
      'https://not-tailscale.example',
      'https://bad.ts.net.attacker.example',
      'https://user@wingerapp1.tail8208bf.ts.net',
      'https://wingerapp1.tail8208bf.ts.net:8080',
      'https://wingerapp1.tail8208bf.ts.net/path',
      'https://wingerapp1.tail8208bf.ts.net/?token=x',
    ]) {
      expect(() => PairingCredentials.validateUrl(url),
          throwsA(isA<FormatException>()), reason: url);
    }
  });

  test('rejects unknown/malformed QR and duplicate control token', () {
    final qr = jsonEncode({
      'type': 'emtifize-pair-v1',
      'url': 'https://wingerapp1.tail8208bf.ts.net',
      'read_token': read, 'control_token': read,
    });
    expect(() => PairingCredentials.fromQr(qr),
        throwsA(isA<FormatException>()));
    expect(() => PairingCredentials.fromQr('garbage QR'),
        throwsA(isA<FormatException>()));
    expect(() => PairingCredentials.fromQr('x' * 5000),
        throwsA(isA<FormatException>()));
  });
}
