import 'package:apex_trade/features/engine_status/pairing_credentials.dart';
import 'package:apex_trade/features/engine_status/pairing_vault.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryEncryptedStore implements PairingSecretStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}

void main() {
  test('saved pairing restores after a simulated app restart', () async {
    final storage = MemoryEncryptedStore();
    const secrets = PairingCredentials(
      url: 'https://wingerapp1.tail8208bf.ts.net',
      readToken: 'r0123456789r0123456789r0123456789r0123456789',
      controlToken: 'c0123456789c0123456789c0123456789c0123456789',
    );
    await PairingVault(storage: storage).save(secrets);
    final restartedAppVault = PairingVault(storage: storage);
    final restored = await restartedAppVault.load();
    expect(restored?.url, secrets.url);
    expect(restored?.readToken, secrets.readToken);
    expect(restored?.controlToken, secrets.controlToken);
  });

  test('view-only credentials can also be remembered', () async {
    final store = MemoryEncryptedStore();
    const data = PairingCredentials(
      url: 'https://wingerapp1.tail8208bf.ts.net',
      readToken: 'r0123456789r0123456789r0123456789r0123456789',
      controlToken: '',
    );
    await PairingVault(storage: store).save(data);
    expect((await PairingVault(storage: store).load())?.controlToken, '');
  });

  test('missing commit marker cannot restore partial pairing', () async {
    final store = MemoryEncryptedStore();
    store.values['emtifize.url'] = 'https://pc.tail.ts.net';
    store.values['emtifize.read'] = 'r' * 48;
    store.values['emtifize.control'] = 'c' * 48;
    expect(await PairingVault(storage: store).load(), null);
  });

  test('explicit forget deletes all saved secrets', () async {
    final store = MemoryEncryptedStore();
    const data = PairingCredentials(
      url: 'https://pc.tail.ts.net',
      readToken: 'r0123456789r0123456789r0123456789r0123456789',
      controlToken: '',
    );
    final vault = PairingVault(storage: store);
    await vault.save(data);
    await vault.forget();
    expect(await vault.load(), null);
    expect(store.values, isEmpty);
  });
}
