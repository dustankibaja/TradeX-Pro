import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Only displays a non-sensitive heartbeat from the local MT5 worker.
/// There are no trade-execution, account-balance, or configuration endpoints.
class EngineStatus {
  final String state;
  final String mode;
  final bool stale;
  final bool tradingEnabled;
  final bool demoGuarded;
  final bool remotePaused;
  final bool remoteControlAvailable;
  final String? updatedAt;
  final String? strategy;
  final List<String> symbols;

  const EngineStatus({
    required this.state,
    required this.mode,
    required this.stale,
    required this.tradingEnabled,
    this.demoGuarded = false,
    this.remotePaused = false,
    this.remoteControlAvailable = false,
    this.updatedAt,
    this.strategy,
    required this.symbols,
  });

  factory EngineStatus.fromJson(Map<String, dynamic> payload) {
    if (payload['schema_version'] != 1) {
      throw const FormatException('Unsupported engine status version.');
    }
    final state = payload['state'];
    final mode = payload['mode'];
    if (state is! String || mode is! String ||
        payload['stale'] is! bool || payload['trading_enabled'] is! bool) {
      throw const FormatException('Incomplete engine status response.');
    }
    return EngineStatus(
      state: payload['stale'] == true ? 'offline' : state,
      mode: mode,
      stale: payload['stale'] as bool,
      tradingEnabled: payload['stale'] == true ? false : payload['trading_enabled'] as bool,
      demoGuarded: payload['demo_guarded'] == true,
      remotePaused: payload['remote_paused'] == true,
      remoteControlAvailable: payload['remote_control_available'] == true,
      updatedAt: payload['updated_at'] as String?,
      strategy: payload['strategy'] as String?,
      symbols: (payload['symbols'] as List<dynamic>? ?? [])
          .whereType<String>()
          .take(20)
          .toList(growable: false),
    );
  }
}

class EngineStatusClient {
  final http.Client _http;

  EngineStatusClient({http.Client? client}) : _http = client ?? http.Client();

  Future<EngineStatus> fetchStatus({
    required String baseUrl,
    required String readOnlyToken,
  }) async {
    final root = Uri.tryParse(baseUrl.trim());
    if (root == null || !root.hasAuthority || root.host.isEmpty ||
        root.userInfo.isNotEmpty || root.hasQuery || root.hasFragment) {
      throw const FormatException('Enter a valid HTTPS API address.');
    }

    final isDebugLocal = kDebugMode && root.scheme == 'http' &&
        {'localhost', '127.0.0.1', '10.0.2.2'}.contains(root.host);
    if (root.scheme != 'https' && !isDebugLocal) {
      throw const FormatException(
        'Use HTTPS for phone access. Plain HTTP is allowed only for local debug.',
      );
    }
    if (readOnlyToken.trim().length < 32) {
      throw const FormatException('Read-only pairing token is missing or too short.');
    }

    final url = root.replace(path: '/v1/status', queryParameters: null);
    final response = await _http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${readOnlyToken.trim()}',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 401) {
      throw const FormatException('Pairing rejected: check your read-only token.');
    }
    if (response.statusCode != 200) {
      throw FormatException('Engine API returned HTTP ${response.statusCode}.');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Engine returned an invalid status response.');
    }
    return EngineStatus.fromJson(decoded);
  }

  void dispose() => _http.close();
}
