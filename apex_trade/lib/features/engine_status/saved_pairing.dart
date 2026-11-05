import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Private pairing keys are encrypted by Android Keystore-backed storage.
/// Persist only after a successful authenticated read-only status request.
/// This is NOT a background bot service: MT5 runs independently on Windows.
class SavedPairing {
  final String url;
  final String readToken;
  final String controlToken;

  const SavedPairing({
    required this.url,
    required this.readToken,
    required this.controlToken,
  });

  factory SavedPairing.fromQr(String raw) {
    if (raw.length > 4096) {
      throw const FormatException('QR code is too large.');
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic> ||
        decoded['type'] != 'emtifize-pair-v1' ||
        decoded['url'] is! String ||
        decoded['read_token'] is! String ||
        decoded['control_token'] is! String) {
      throw const FormatException('Scan an Emtifize AI pairing QR from your Windows PC.');
    }
    final url = decoded['url'] as String;
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || !uri.hasAuthority ||
        !uri.host.endsWith('.ts.net') || uri.userInfo.isNotEmpty ||
        uri.hasQuery || uri.hasFragment ||
        (uri.path.isNotEmpty && uri.path != '/')) {
      throw const FormatException('QR must contain a private HTTPS Tailscale address.');
    }
    final read = decoded['read_token'] as String;
    final control = decoded['control_token'] as String;
    final secret = RegExp(r'^[A-Za-z0-9_-]{32,128}$');
    if (!secret.hasMatch(read) || !secret.hasMatch(control) || read == control) {
      throw const FormatException('Invalid QR pairing credentials.');
    }
    return SavedPairing(url: url, readToken: read, controlToken: control);
  }

  Map<String, dynamic> toJson() => {
    'version': 1,
    'url': url,
    'read_token': readToken,
    'control_token': controlToken,
  };

  factory SavedPairing.fromJson(Map<String, dynamic> input) {
    if (input['version'] != 1 ||
        input['url'] is! String ||
        input['read_token'] is! String ||
        input['control_token'] is! String) {
      throw const FormatException('Unrecognized saved pairing.');
    }
    final pairing = SavedPairing(
      url: input['url'] as String,
      readToken: input['read_token'] as String,
      controlToken: input['control_token'] as String,
    );
    final uri = Uri.tryParse(pairing.url);
    if (uri == null || uri.scheme != 'https' || !uri.hasAuthority ||
        uri.userInfo.isNotEmpty || pairing.readToken.length < 32 ||
        (pairing.controlToken.isNotEmpty &&
        pairing.controlToken.length < 32)) {
      throw const FormatException('Saved pairing was invalid.');
    }
    return pairing;
  }
}

class PairingStore {
  final FlutterSecureStorage _secureStorage;

  const PairingStore({
    FlutterSecureStorage secureStorage = const FlutterSecureStorage(),
  }) : _secureStorage = secureStorage;

  static const _key = 'emtifize_private_pairing_v1';

  Future<SavedPairing?> load() async {
    final raw = await _secureStorage.read(key: _key);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Corrupt saved pairing.');
    }
    return SavedPairing.fromJson(decoded);
  }

  Future<void> save(SavedPairing pairing) =>
      _secureStorage.write(key: _key, value: jsonEncode(pairing.toJson()));

  Future<void> forget() => _secureStorage.delete(key: _key);
}
