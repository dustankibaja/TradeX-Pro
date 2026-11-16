import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'onboarding_client.dart';

abstract interface class DesktopAccountStore {
  Future<void> save(DemoVerification verification);
}

class ProtectedDesktopAccountStore implements DesktopAccountStore {
  const ProtectedDesktopAccountStore();

  static const _key = 'emtifize_verified_desktop_account_v1';
  static const _storage = FlutterSecureStorage();

  @override
  Future<void> save(DemoVerification verification) {
    if (!verification.verified ||
        verification.accountFingerprint.length != 64) {
      throw const FormatException('Only a verified DEMO account can be saved.');
    }
    return _storage.write(
      key: _key,
      value: jsonEncode(verification.toStoredJson()),
    );
  }
}
