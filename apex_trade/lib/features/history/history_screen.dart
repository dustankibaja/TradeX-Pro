import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/trade_model.dart';
import '../../shared/widgets/apex_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  int _selectedFilter = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<String> _filters = [
    'All', 'Wins', 'Losses', 'This Week',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  List<TradeModel> get _filteredTrades {
    switch (_selectedFilter) {
      case 1:
        return TradeData.history.where((t) => t.isWin).toList();
      case 2:
        return TradeData.history.where((t) => t.isLoss).toList();
      case 3:
        final weekAgo = DateTime.now().subtract(
          const Duration(days: 7),
        );
        return TradeData.history
            .where((t) => t.closedAt.isAfter(weekAgo))
            .toList();
      default:
        return TradeData.history;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trade History',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bg3,
                        borderRadius: AppRadius.full,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '${TradeData.totalTrades} Trades',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.text2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Summary row
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryChip(
                        label: 'Total P&L',
                        value: '+\$${TradeData.totalPnl.toStringAsFixed(0)}',
                        color: AppColors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryChip(
                        label: 'Win Rate',
                        value: '${TradeData.winRate.toStringAsFixed(1)}%',
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryChip(
                        label: 'Avg R',
                        value: '${TradeData.avgRMultiple.toStringAsFixed(1)}R',
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter chips
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final isActive = _selectedFilter == i;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedFilter = i),
                      child: AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.accent
                              : AppColors.bg3,
                          borderRadius: AppRadius.full,
                          border: Border.all(
                            color: isActive
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          _filters[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? Colors.white
                                : AppColors.text2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Trade list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filteredTrades.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    return _TradeHistoryItem(
                      trade: _filteredTrades[i],
                      index: i,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Summary Chip ─────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: AppRadius.md,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.text3,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Trade History Item ───────────────────────────────────────

class _TradeHistoryItem extends StatefulWidget {
  final TradeModel trade;
  final int index;

  const _TradeHistoryItem({
    required this.trade,
    required this.index,
  });

  @override
  State<_TradeHistoryItem> createState() => _TradeHistoryItemState();
}

class _TradeHistoryItemState extends State<_TradeHistoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slide = Tween(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(
      Duration(milliseconds: widget.index * 60),
      () { if (mounted) _controller.forward(); },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trade = widget.trade;

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.bg2,
            borderRadius: AppRadius.lg,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: trade.resultColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Text(
                  trade.resultEmoji,
                  style: const TextStyle(fontSize: 18),
                ),
              ),

              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${trade.pairLabel} ${trade.directionLabel}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${trade.dateLabel} · ${trade.timeframe} · ${trade.strategy}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.text3,
                      ),
                    ),
                  ],
                ),
              ),

              // Result
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    trade.pnlLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: trade.resultColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: trade.resultColor.withOpacity(0.1),
                      borderRadius: AppRadius.full,
                    ),
                    child: Text(
                      trade.rLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: trade.resultColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}