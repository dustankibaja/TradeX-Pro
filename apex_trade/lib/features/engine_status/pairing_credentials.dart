import 'dart:convert';

/// Private on-screen QR credential bundle, never written to logs or plain
/// local storage. Scanning requires an explicit host confirmation.
class PairingCredentials {
  final String url;
  final String readToken;
  final String controlToken;

  const PairingCredentials({
    required this.url,
    required this.readToken,
    required this.controlToken,
  });

  static String validateUrl(String raw) {
    final candidate = Uri.tryParse(raw.trim());
    if (candidate == null ||
        candidate.scheme != 'https' ||
        candidate.host.isEmpty ||
        !candidate.host.toLowerCase().endsWith('.ts.net') ||
        candidate.userInfo.isNotEmpty ||
        candidate.hasPort ||
        (candidate.path.isNotEmpty && candidate.path != '/') ||
        candidate.hasQuery ||
        candidate.hasFragment) {
      throw const FormatException(
        'Pairing must use a private Tailscale HTTPS hostname.',
      );
    }
    return 'https://${candidate.host.toLowerCase()}';
  }

  static bool isStrongToken(String value) =>
      RegExp(r'^[A-Za-z0-9_-]{40,}$').hasMatch(value);

  factory PairingCredentials.fromQr(String raw) {
    if (raw.length > 4096) {
      throw const FormatException('Invalid pairing QR.');
    }
    try {
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic> ||
          data['type'] != 'emtifize-pair-v1' ||
          data['url'] is! String ||
          data['read_token'] is! String ||
          data['control_token'] is! String) {
        throw const FormatException('Not an Emtifize pairing QR.');
      }
      final url = validateUrl(data['url'] as String);
      final read = data['read_token'] as String;
      final control = data['control_token'] as String;
      if (!isStrongToken(read) ||
          !isStrongToken(control) ||
          read == control) {
        throw const FormatException('Invalid private QR credentials.');
      }
      return PairingCredentials(
        url: url, readToken: read, controlToken: control,
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Invalid pairing QR.');
    }
  }
}
