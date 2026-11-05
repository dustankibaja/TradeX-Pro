import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Strictly read-only DTOs. No credentials, orders, or account identifiers.
class DemoPosition {
  final String symbol;
  final String side;
  final double volume;
  final double openPrice;
  final double currentPrice;
  final double profit;
  final String openedAt;

  const DemoPosition({
    required this.symbol,
    required this.side,
    required this.volume,
    required this.openPrice,
    required this.currentPrice,
    required this.profit,
    required this.openedAt,
  });

  factory DemoPosition.fromJson(Map<String, dynamic> data) => DemoPosition(
    symbol: data['symbol'] as String,
    side: data['side'] as String,
    volume: (data['volume'] as num).toDouble(),
    openPrice: (data['open_price'] as num).toDouble(),
    currentPrice: (data['current_price'] as num).toDouble(),
    profit: (data['profit'] as num).toDouble(),
    openedAt: data['opened_at'] as String,
  );
}

class DemoClosingDeal {
  final String symbol;
  final String dealSide;
  final double volume;
  final double netPnl;
  final String closedAt;

  const DemoClosingDeal({
    required this.symbol,
    required this.dealSide,
    required this.volume,
    required this.netPnl,
    required this.closedAt,
  });

  factory DemoClosingDeal.fromJson(Map<String, dynamic> data) => DemoClosingDeal(
    symbol: data['symbol'] as String,
    dealSide: data['deal_side'] as String,
    volume: (data['volume'] as num).toDouble(),
    netPnl: (data['net_pnl'] as num).toDouble(),
    closedAt: data['closed_at'] as String,
  );
}

/// Broker-reported MT5 demo-account data. Never infer balance from mock data.
class DemoAccount {
  final bool available;
  final bool stale;
  final String accountType;
  final String? updatedAt;
  final String? currency;
  final double? balance;
  final double? equity;
  final double? freeMargin;
  final double? floatingPnl;
  final List<DemoPosition> positions;
  final List<DemoClosingDeal> recentClosingDeals;

  const DemoAccount({
    required this.available,
    required this.stale,
    required this.accountType,
    this.updatedAt,
    this.currency,
    this.balance,
    this.equity,
    this.freeMargin,
    this.floatingPnl,
    this.positions = const [],
    this.recentClosingDeals = const [],
  });

  factory DemoAccount.fromJson(Map<String, dynamic> data) {
    if (data['schema_version'] != 1 ||
        data['available'] is! bool ||
        data['stale'] is! bool ||
        data['account_type'] is! String) {
      throw const FormatException('Unsupported broker demo data response.');
    }
    if (data['available'] != true ||
        data['stale'] == true ||
        data['account_type'] != 'demo') {
      // Never surface stale or non-demo account figures from any server.
      return const DemoAccount(
        available: false, stale: true, accountType: 'unknown',
      );
    }
    if (data['currency'] is! String ||
        data['balance'] is! num ||
        data['equity'] is! num ||
        data['margin_free'] is! num ||
        data['floating_pnl'] is! num ||
        data['updated_at'] is! String) {
      throw const FormatException('Incomplete broker demo data.');
    }
    final positionsRaw = data['positions'];
    final dealsRaw = data['recent_closing_deals'];
    if (positionsRaw is! List || dealsRaw is! List) {
      throw const FormatException('Incomplete broker positions/deals.');
    }
    return DemoAccount(
      available: true,
      stale: false,
      accountType: 'demo',
      updatedAt: data['updated_at'] as String,
      currency: data['currency'] as String,
      balance: (data['balance'] as num).toDouble(),
      equity: (data['equity'] as num).toDouble(),
      freeMargin: (data['margin_free'] as num).toDouble(),
      floatingPnl: (data['floating_pnl'] as num).toDouble(),
      positions: positionsRaw
          .whereType<Map<String, dynamic>>()
          .take(20).map(DemoPosition.fromJson)
          .toList(growable: false),
      recentClosingDeals: dealsRaw
          .whereType<Map<String, dynamic>>()
          .take(20).map(DemoClosingDeal.fromJson)
          .toList(growable: false),
    );
  }
}

class DemoAccountClient {
  final http.Client _http;
  DemoAccountClient({http.Client? client}) : _http = client ?? http.Client();

  Future<DemoAccount> fetch({
    required String baseUrl,
    required String readOnlyToken,
  }) async {
    final root = Uri.tryParse(baseUrl.trim());
    if (root == null || !root.hasAuthority || root.host.isEmpty ||
        root.userInfo.isNotEmpty || root.hasQuery || root.hasFragment) {
      throw const FormatException('Enter a valid private HTTPS address.');
    }
    final localDebug = kDebugMode && root.scheme == 'http' &&
        {'localhost', '127.0.0.1', '10.0.2.2'}.contains(root.host);
    if (root.scheme != 'https' && !localDebug) {
      throw const FormatException('HTTPS is required for phone access.');
    }
    if (readOnlyToken.trim().length < 32) {
      throw const FormatException('Private pairing token is missing or too short.');
    }
    final uri = root.replace(path: '/v1/demo-account', queryParameters: null);
    final response = await _http.get(uri, headers: {
      'Authorization': 'Bearer ${readOnlyToken.trim()}',
      'Accept': 'application/json',
    }).timeout(const Duration(seconds: 8));
    if (response.statusCode == 401) {
      throw const FormatException('Pairing rejected: check the private token.');
    }
    if (response.statusCode == 404) {
      throw const FormatException('Windows backend needs the demo-account upgrade.');
    }
    if (response.statusCode == 503) {
      return const DemoAccount(
        available: false, stale: true, accountType: 'unknown',
      );
    }
    if (response.statusCode != 200) {
      throw FormatException('Demo broker API returned HTTP ${response.statusCode}.');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid demo broker API response.');
    }
    return DemoAccount.fromJson(decoded);
  }

  void dispose() => _http.close();
}
