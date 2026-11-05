import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'pairing_credentials.dart';

/// Credentials are encrypted at rest using the Android Keystore.
/// No plaintext SharedPreferences, logs, or cloud backup.
abstract class PairingSecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class AndroidPairingSecretStore implements PairingSecretStore {
  const AndroidPairingSecretStore();

  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class PairingVault {
  final PairingSecretStore storage;

  const PairingVault({required this.storage});

  static const _mark = 'emtifize.paired';
  static const _url = 'emtifize.url';
  static const _read = 'emtifize.read';
  static const _control = 'emtifize.control';

  Future<void> save(PairingCredentials data) async {
    // Prevent an interrupted write from being mistaken for a valid pairing.
    await storage.write(_mark, '0');
    await storage.write(_url, PairingCredentials.validateUrl(data.url));
    await storage.write(_read, data.readToken);
    await storage.write(_control, data.controlToken);
    await storage.write(_mark, '1');
  }

  Future<PairingCredentials?> load() async {
    if (await storage.read(_mark) != '1') return null;
    final url = await storage.read(_url);
    final read = await storage.read(_read);
    final control = await storage.read(_control);
    if (url == null || read == null || control == null) return null;
    try {
      final safeUrl = PairingCredentials.validateUrl(url);
      if (!PairingCredentials.isStrongToken(read) ||
          (control.isNotEmpty && !PairingCredentials.isStrongToken(control)) ||
          (control.isNotEmpty && read == control)) {
        return null;
      }
      return PairingCredentials(
        url: safeUrl, readToken: read, controlToken: control,
      );
    } on FormatException {
      return null;
    }
  }

  Future<void> forget() async {
    await storage.write(_mark, '0');
    await storage.delete(_url);
    await storage.delete(_read);
    await storage.delete(_control);
    await storage.delete(_mark);
  }
}
