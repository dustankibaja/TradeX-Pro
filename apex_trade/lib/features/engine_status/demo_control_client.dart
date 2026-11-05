import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Can pause/resume DEMO signal simulation only. Never sends MT5 trade orders.
/// A separate control token is required, distinct from the read-only token.
class DemoControlClient {
  final http.Client _http;

  DemoControlClient({http.Client? client}) : _http = client ?? http.Client();

  Future<bool> setPaused({
    required String baseUrl,
    required String controlToken,
    required bool paused,
  }) async {
    final root = Uri.tryParse(baseUrl.trim());
    if (root == null || !root.hasAuthority || root.host.isEmpty ||
        root.userInfo.isNotEmpty || root.hasQuery || root.hasFragment) {
      throw const FormatException('Enter a valid private HTTPS address.');
    }

    final localDebug = kDebugMode && root.scheme == 'http' &&
        {'localhost', '127.0.0.1', '10.0.2.2'}.contains(root.host);
    if (root.scheme != 'https' && !localDebug) {
      throw const FormatException('HTTPS is required for phone controls.');
    }
    if (controlToken.trim().length < 32) {
      throw const FormatException('Demo control token is missing or too short.');
    }

    final action = paused ? 'pause' : 'resume';
    final endpoint = root.replace(path: '/v1/demo-control/$action', queryParameters: null);
    final response = await _http.post(endpoint, headers: {
      'Authorization': 'Bearer ${controlToken.trim()}',
      'Accept': 'application/json',
    }).timeout(const Duration(seconds: 8));

    if (response.statusCode == 401) {
      throw const FormatException('Control access denied. Check the separate control token.');
    }
    if (response.statusCode == 404 || response.statusCode == 405) {
      throw const FormatException('Upgrade the Windows backend to enable demo controls.');
    }
    if (response.statusCode == 409) {
      throw const FormatException(
        'Resume blocked: DEMO worker/account not verified or engine unavailable.',
      );
    }
    if (response.statusCode != 200) {
      throw FormatException('Demo control returned HTTP ${response.statusCode}.');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> ||
        decoded['ok'] != true || decoded['remote_paused'] is! bool) {
      throw const FormatException('Invalid demo control response.');
    }
    if (decoded['remote_paused'] != paused) {
      throw const FormatException('Demo control state did not match the request.');
    }
    return decoded['remote_paused'] as bool;
  }

  void dispose() => _http.close();
}
