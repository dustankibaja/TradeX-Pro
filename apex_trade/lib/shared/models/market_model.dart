import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum MarketType { forex, gold, crypto }

class MarketModel {
  final String symbol;
  final String name;
  final MarketType type;
  final double price;
  final double change;
  final double changePercent;
  final double high;
  final double low;
  final double spread;
  final List<double> sparklineData;
  final bool isWatchlisted;

  const MarketModel({
    required this.symbol,
    required this.name,
    required this.type,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.high,
    required this.low,
    required this.spread,
    required this.sparklineData,
    this.isWatchlisted = false,
  });

  // Convenience getters
  bool get isUp => change >= 0;

  Color get changeColor => isUp ? AppColors.green : AppColors.red;

  String get changeLabel {
    final prefix = isUp ? '+' : '';
    return '$prefix${changePercent.toStringAsFixed(2)}%';
  }

  String get priceLabel {
    if (type == MarketType.gold) {
      return price.toStringAsFixed(2);
    }
    if (price > 100) {
      return price.toStringAsFixed(2);
    }
    return price.toStringAsFixed(4);
  }

  String get typeLabel {
    switch (type) {
      case MarketType.forex:  return 'FX';
      case MarketType.gold:   return 'GOLD';
      case MarketType.crypto: return 'CRYPTO';
    }
  }

  Color get typeColor {
    switch (type) {
      case MarketType.forex:  return AppColors.accent;
      case MarketType.gold:   return AppColors.gold;
      case MarketType.crypto: return AppColors.text2;
    }
  }
}

// Dummy live market data
class MarketData {
  static List<MarketModel> get all => [
    MarketModel(
      symbol: 'XAUUSD',
      name: 'Gold vs US Dollar',
      type: MarketType.gold,
      price: 2318.40,
      change: 9.80,
      changePercent: 0.42,
      high: 2324.80,
      low: 2305.40,
      spread: 0.20,
      sparklineData: [
        2305, 2308, 2306, 2312, 2310,
        2315, 2313, 2318, 2316, 2318,
      ],
      isWatchlisted: true,
    ),
    MarketModel(
      symbol: 'EURUSD',
      name: 'Euro vs US Dollar',
      type: MarketType.forex,
      price: 1.0847,
      change: 0.0019,
      changePercent: 0.18,
      high: 1.0871,
      low: 1.0821,
      spread: 0.0001,
      sparklineData: [
        1.0821, 1.0830, 1.0828, 1.0835,
        1.0832, 1.0840, 1.0838, 1.0844,
        1.0842, 1.0847,
      ],
      isWatchlisted: true,
    ),
    MarketModel(
      symbol: 'GBPUSD',
      name: 'British Pound vs US Dollar',
      type: MarketType.forex,
      price: 1.2634,
      change: -0.0011,
      changePercent: -0.09,
      high: 1.2668,
      low: 1.2610,
      spread: 0.0001,
      sparklineData: [
        1.2668, 1.2660, 1.2655, 1.2648,
        1.2650, 1.2645, 1.2640, 1.2638,
        1.2636, 1.2634,
      ],
      isWatchlisted: true,
    ),
    MarketModel(
      symbol: 'USDJPY',
      name: 'US Dollar vs Japanese Yen',
      type: MarketType.forex,
      price: 149.72,
      change: 0.46,
      changePercent: 0.31,
      high: 150.10,
      low: 149.20,
      spread: 0.02,
      sparklineData: [
        149.20, 149.30, 149.28, 149.40,
        149.38, 149.50, 149.55, 149.62,
        149.68, 149.72,
      ],
      isWatchlisted: true,
    ),
    MarketModel(
      symbol: 'GBPJPY',
      name: 'British Pound vs Japanese Yen',
      type: MarketType.forex,
      price: 190.82,
      change: 0.34,
      changePercent: 0.18,
      high: 191.20,
      low: 190.10,
      spread: 0.03,
      sparklineData: [
        190.10, 190.20, 190.18, 190.35,
        190.40, 190.55, 190.60, 190.70,
        190.78, 190.82,
      ],
      isWatchlisted: false,
    ),
    MarketModel(
      symbol: 'EURJPY',
      name: 'Euro vs Japanese Yen',
      type: MarketType.forex,
      price: 162.44,
      change: -0.28,
      changePercent: -0.17,
      high: 163.10,
      low: 162.20,
      spread: 0.02,
      sparklineData: [
        163.10, 163.00, 162.90, 162.80,
        162.75, 162.65, 162.60, 162.55,
        162.48, 162.44,
      ],
      isWatchlisted: false,
    ),
  ];

  // Watchlisted pairs only
  static List<MarketModel> get watchlist =>
      all.where((m) => m.isWatchlisted).toList();

  // Gold only
  static MarketModel get gold =>
      all.firstWhere((m) => m.type == MarketType.gold);
}