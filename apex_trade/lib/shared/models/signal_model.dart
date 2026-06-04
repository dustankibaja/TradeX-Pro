import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum SignalDirection { buy, sell }

enum SignalStatus { active, closed, pending }

enum SignalTimeframe { m5, m15, m30, h1, h4, d1, w1 }

class SignalModel {
  final String id;
  final String pair;
  final SignalDirection direction;
  final SignalStatus status;
  final SignalTimeframe timeframe;
  final double entry;
  final double takeProfit1;
  final double takeProfit2;
  final double stopLoss;
  final double aiConfidence;
  final double riskReward;
  final String strategy;
  final String session;
  final DateTime createdAt;
  final double? currentPnl;
  final double? rMultiple;

  const SignalModel({
    required this.id,
    required this.pair,
    required this.direction,
    required this.status,
    required this.timeframe,
    required this.entry,
    required this.takeProfit1,
    required this.takeProfit2,
    required this.stopLoss,
    required this.aiConfidence,
    required this.riskReward,
    required this.strategy,
    required this.session,
    required this.createdAt,
    this.currentPnl,
    this.rMultiple,
  });

  // Convenience getters
  bool get isBuy => direction == SignalDirection.buy;
  bool get isActive => status == SignalStatus.active;

  Color get directionColor =>
      isBuy ? AppColors.green : AppColors.red;

  String get directionLabel =>
      isBuy ? 'BUY' : 'SELL';

  String get timeframeLabel {
    switch (timeframe) {
      case SignalTimeframe.m5:  return 'M5';
      case SignalTimeframe.m15: return 'M15';
      case SignalTimeframe.m30: return 'M30';
      case SignalTimeframe.h1:  return 'H1';
      case SignalTimeframe.h4:  return 'H4';
      case SignalTimeframe.d1:  return 'D1';
      case SignalTimeframe.w1:  return 'W1';
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// Dummy data — realistic signals for MVP
class SignalData {
  static List<SignalModel> get all => [
    SignalModel(
      id: 's1',
      pair: 'XAUUSD',
      direction: SignalDirection.buy,
      status: SignalStatus.active,
      timeframe: SignalTimeframe.h4,
      entry: 2318.40,
      takeProfit1: 2328.00,
      takeProfit2: 2334.00,
      stopLoss: 2308.00,
      aiConfidence: 87,
      riskReward: 1.5,
      strategy: 'BOS + FVG + OB confluence',
      session: 'London',
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      currentPnl: 184.20,
      rMultiple: 2.4,
    ),
    SignalModel(
      id: 's2',
      pair: 'EURUSD',
      direction: SignalDirection.sell,
      status: SignalStatus.active,
      timeframe: SignalTimeframe.h1,
      entry: 1.0861,
      takeProfit1: 1.0840,
      takeProfit2: 1.0820,
      stopLoss: 1.0882,
      aiConfidence: 75,
      riskReward: 2.0,
      strategy: 'MSS + Liquidity Sweep',
      session: 'NY Open',
      createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
      currentPnl: 62.40,
      rMultiple: 0.8,
    ),
    SignalModel(
      id: 's3',
      pair: 'GBPJPY',
      direction: SignalDirection.buy,
      status: SignalStatus.active,
      timeframe: SignalTimeframe.d1,
      entry: 190.82,
      takeProfit1: 191.80,
      takeProfit2: 192.60,
      stopLoss: 189.90,
      aiConfidence: 82,
      riskReward: 2.8,
      strategy: 'Weekly OB retest',
      session: 'London',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      currentPnl: 156.00,
      rMultiple: 1.2,
    ),
    SignalModel(
      id: 's4',
      pair: 'GBPUSD',
      direction: SignalDirection.sell,
      status: SignalStatus.pending,
      timeframe: SignalTimeframe.h4,
      entry: 1.2650,
      takeProfit1: 1.2610,
      takeProfit2: 1.2580,
      stopLoss: 1.2675,
      aiConfidence: 79,
      riskReward: 2.2,
      strategy: 'Supply Zone + BOS',
      session: 'NY Session',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    SignalModel(
      id: 's5',
      pair: 'USDJPY',
      direction: SignalDirection.buy,
      status: SignalStatus.closed,
      timeframe: SignalTimeframe.h1,
      entry: 149.20,
      takeProfit1: 149.80,
      takeProfit2: 150.20,
      stopLoss: 148.90,
      aiConfidence: 71,
      riskReward: 1.8,
      strategy: 'FVG + Demand Zone',
      session: 'Tokyo',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      currentPnl: 198.00,
      rMultiple: 2.0,
    ),
  ];

  static List<SignalModel> get active =>
      all.where((s) => s.isActive).toList();
}