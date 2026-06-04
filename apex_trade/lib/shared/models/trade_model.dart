import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum TradeResult { win, loss, breakeven }

enum TradePair { xauusd, eurusd, gbpusd, usdjpy, gbpjpy, eurjpy, audusd }

class TradeModel {
  final String id;
  final TradePair pair;
  final bool isBuy;
  final TradeResult result;
  final double entryPrice;
  final double exitPrice;
  final double pnl;
  final double rMultiple;
  final String timeframe;
  final String strategy;
  final DateTime openedAt;
  final DateTime closedAt;

  const TradeModel({
    required this.id,
    required this.pair,
    required this.isBuy,
    required this.result,
    required this.entryPrice,
    required this.exitPrice,
    required this.pnl,
    required this.rMultiple,
    required this.timeframe,
    required this.strategy,
    required this.openedAt,
    required this.closedAt,
  });

  // Convenience getters
  bool get isWin => result == TradeResult.win;
  bool get isLoss => result == TradeResult.loss;
  bool get isBreakeven => result == TradeResult.breakeven;

  String get pairLabel {
    switch (pair) {
      case TradePair.xauusd: return 'XAUUSD';
      case TradePair.eurusd: return 'EURUSD';
      case TradePair.gbpusd: return 'GBPUSD';
      case TradePair.usdjpy: return 'USDJPY';
      case TradePair.gbpjpy: return 'GBPJPY';
      case TradePair.eurjpy: return 'EURJPY';
      case TradePair.audusd: return 'AUDUSD';
    }
  }

  String get directionLabel => isBuy ? 'BUY' : 'SELL';

  String get pnlLabel {
    final prefix = pnl >= 0 ? '+' : '';
    return '$prefix\$${pnl.toStringAsFixed(2)}';
  }

  String get rLabel {
    final prefix = rMultiple >= 0 ? '+' : '';
    return '$prefix${rMultiple.toStringAsFixed(1)}R';
  }

  Color get resultColor {
    switch (result) {
      case TradeResult.win:       return AppColors.green;
      case TradeResult.loss:      return AppColors.red;
      case TradeResult.breakeven: return AppColors.text2;
    }
  }

  String get resultEmoji {
    switch (result) {
      case TradeResult.win:       return '📈';
      case TradeResult.loss:      return '📉';
      case TradeResult.breakeven: return '⚡';
    }
  }

  String get dateLabel {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[closedAt.month - 1]} ${closedAt.day}';
  }
}

// Dummy trade history data
class TradeData {
  static List<TradeModel> get history => [
    TradeModel(
      id: 't1',
      pair: TradePair.xauusd,
      isBuy: true,
      result: TradeResult.win,
      entryPrice: 2312.00,
      exitPrice: 2334.00,
      pnl: 284.00,
      rMultiple: 2.4,
      timeframe: 'H4',
      strategy: 'SMC OB',
      openedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      closedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TradeModel(
      id: 't2',
      pair: TradePair.eurusd,
      isBuy: false,
      result: TradeResult.win,
      entryPrice: 1.0880,
      exitPrice: 1.0848,
      pnl: 156.00,
      rMultiple: 1.8,
      timeframe: 'H1',
      strategy: 'MSS',
      openedAt: DateTime.now().subtract(const Duration(days: 2)),
      closedAt: DateTime.now().subtract(const Duration(days: 1, hours: 18)),
    ),
    TradeModel(
      id: 't3',
      pair: TradePair.gbpusd,
      isBuy: true,
      result: TradeResult.loss,
      entryPrice: 1.2640,
      exitPrice: 1.2610,
      pnl: -100.00,
      rMultiple: -1.0,
      timeframe: 'M30',
      strategy: 'FVG',
      openedAt: DateTime.now().subtract(const Duration(days: 3)),
      closedAt: DateTime.now().subtract(const Duration(days: 2, hours: 20)),
    ),
    TradeModel(
      id: 't4',
      pair: TradePair.xauusd,
      isBuy: false,
      result: TradeResult.win,
      entryPrice: 2340.00,
      exitPrice: 2308.00,
      pnl: 420.00,
      rMultiple: 3.2,
      timeframe: 'D1',
      strategy: 'Supply Zone',
      openedAt: DateTime.now().subtract(const Duration(days: 4)),
      closedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    TradeModel(
      id: 't5',
      pair: TradePair.usdjpy,
      isBuy: true,
      result: TradeResult.breakeven,
      entryPrice: 149.20,
      exitPrice: 149.20,
      pnl: 0.00,
      rMultiple: 0.0,
      timeframe: 'H4',
      strategy: 'Liquidity Sweep',
      openedAt: DateTime.now().subtract(const Duration(days: 5)),
      closedAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    TradeModel(
      id: 't6',
      pair: TradePair.eurusd,
      isBuy: true,
      result: TradeResult.win,
      entryPrice: 1.0820,
      exitPrice: 1.0862,
      pnl: 198.00,
      rMultiple: 2.0,
      timeframe: 'H1',
      strategy: 'BOS',
      openedAt: DateTime.now().subtract(const Duration(days: 6)),
      closedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    TradeModel(
      id: 't7',
      pair: TradePair.gbpjpy,
      isBuy: true,
      result: TradeResult.win,
      entryPrice: 189.40,
      exitPrice: 192.60,
      pnl: 374.00,
      rMultiple: 2.8,
      timeframe: 'W1',
      strategy: 'Weekly OB',
      openedAt: DateTime.now().subtract(const Duration(days: 8)),
      closedAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    TradeModel(
      id: 't8',
      pair: TradePair.xauusd,
      isBuy: true,
      result: TradeResult.win,
      entryPrice: 2298.00,
      exitPrice: 2318.00,
      pnl: 312.00,
      rMultiple: 2.2,
      timeframe: 'H4',
      strategy: 'Demand Zone',
      openedAt: DateTime.now().subtract(const Duration(days: 10)),
      closedAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];

  // Stats computed from history
  static int get totalTrades => history.length;
  static int get wins => history.where((t) => t.isWin).length;
  static int get losses => history.where((t) => t.isLoss).length;
  static int get breakevens => history.where((t) => t.isBreakeven).length;

  static double get winRate =>
      (wins / totalTrades * 100);

  static double get totalPnl =>
      history.fold(0, (sum, t) => sum + t.pnl);

  static double get avgRMultiple =>
      history.fold(0.0, (sum, t) => sum + t.rMultiple) / totalTrades;
}