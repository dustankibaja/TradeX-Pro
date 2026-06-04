import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/trade_model.dart';
import '../../shared/widgets/apex_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _statsController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _statsAnimation;
  int _selectedPeriod = 1;

  final List<String> _periods = [
    'Week', 'Month', '3 Months', 'Year', 'All',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _statsAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _statsController,
        curve: Curves.easeOut,
      ),
    );
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _statsController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
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
                        'Analytics',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: AppRadius.full,
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.2),
                          ),
                        ),
                        child: const Text(
                          'June 2025',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Period selector
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    itemCount: _periods.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final isActive = _selectedPeriod == i;
                      return GestureDetector(
                        onTap: () => setState(
                          () => _selectedPeriod = i,
                        ),
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
                            _periods[i],
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
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.lg),
              ),

              // Stats grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                    children: [
                      _StatCard(
                        label: 'Win Rate',
                        value: '73.4%',
                        change: '+4.2% vs last',
                        valueColor: AppColors.green,
                        icon: Icons.emoji_events_rounded,
                        iconColor: AppColors.green,
                        animation: _statsAnimation,
                      ),
                      _StatCard(
                        label: 'Total Profit',
                        value: '\$4,847',
                        change: '+28.4%',
                        valueColor: AppColors.green,
                        icon: Icons.trending_up_rounded,
                        iconColor: AppColors.green,
                        animation: _statsAnimation,
                      ),
                      _StatCard(
                        label: 'Avg R:R',
                        value: '1.82R',
                        change: 'Per trade',
                        valueColor: AppColors.text1,
                        icon: Icons.balance_rounded,
                        iconColor: AppColors.accent,
                        animation: _statsAnimation,
                      ),
                      _StatCard(
                        label: 'Total Trades',
                        value: '47',
                        change: 'This month',
                        valueColor: AppColors.text1,
                        icon: Icons.receipt_long_rounded,
                        iconColor: AppColors.gold,
                        animation: _statsAnimation,
                      ),
                    ],
                  ),
                ),
              ),

              // Equity curve
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Equity Curve'),
                      const SizedBox(height: AppSpacing.md),
                      ApexCard(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          height: 160,
                          child: AnimatedBuilder(
                            animation: _statsAnimation,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: _EquityCurvePainter(
                                  progress: _statsAnimation.value,
                                ),
                                child: const SizedBox.expand(),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Pair breakdown
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Performance by Pair',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _PairBreakdown(
                        animation: _statsAnimation,
                      ),
                    ],
                  ),
                ),
              ),

              // Win/Loss distribution
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Trade Distribution',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _TradeDistribution(),
                    ],
                  ),
                ),
              ),

              // Best trades
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Best Trades'),
                      const SizedBox(height: AppSpacing.md),
                      ...TradeData.history
                          .where((t) => t.isWin)
                          .take(3)
                          .map(
                            (t) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: 8,
                              ),
                              child: _BestTradeItem(trade: t),
                            ),
                          ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String change;
  final Color valueColor;
  final IconData icon;
  final Color iconColor;
  final Animation<double> animation;

  const _StatCard({
    required this.label,
    required this.value,
    required this.change,
    required this.valueColor,
    required this.icon,
    required this.iconColor,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.text3,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                  fontFamily: 'monospace',
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                change,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Pair Breakdown ───────────────────────────────────────────

class _PairBreakdown extends StatelessWidget {
  final Animation<double> animation;

  const _PairBreakdown({required this.animation});

  final List<Map<String, dynamic>> pairs = const [
    {
      'pair': 'XAUUSD',
      'winRate': 0.78,
      'pnl': '+\$2,140',
      'color': AppColors.gold,
    },
    {
      'pair': 'EURUSD',
      'winRate': 0.71,
      'pnl': '+\$1,280',
      'color': AppColors.accent,
    },
    {
      'pair': 'GBPUSD',
      'winRate': 0.65,
      'pnl': '+\$840',
      'color': AppColors.green,
    },
    {
      'pair': 'USDJPY',
      'winRate': 0.58,
      'pnl': '+\$587',
      'color': AppColors.text2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: pairs.map((p) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.bg3,
              borderRadius: AppRadius.md,
              border: Border.all(
                color: AppColors.border.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: p['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 60,
                  child: Text(
                    p['pair'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text1,
                    ),
                  ),
                ),
                Expanded(
                  child: AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: AppRadius.full,
                        child: LinearProgressIndicator(
                          value: (p['winRate'] as double) *
                              animation.value,
                          backgroundColor: AppColors.bg4,
                          valueColor: AlwaysStoppedAnimation(
                            p['color'] as Color,
                          ),
                          minHeight: 6,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 72,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${((p['winRate'] as double) * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: p['color'] as Color,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        p['pnl'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.text3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Trade Distribution ───────────────────────────────────────

class _TradeDistribution extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ApexCard(
      child: Row(
        children: [
          Expanded(
            child: _DistStat(
              value: '${TradeData.wins}',
              label: 'Wins',
              color: AppColors.green,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: AppColors.border,
          ),
          Expanded(
            child: _DistStat(
              value: '${TradeData.breakevens}',
              label: 'Breakeven',
              color: AppColors.text2,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: AppColors.border,
          ),
          Expanded(
            child: _DistStat(
              value: '${TradeData.losses}',
              label: 'Losses',
              color: AppColors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _DistStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _DistStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.text3,
          ),
        ),
      ],
    );
  }
}

// ─── Best Trade Item ──────────────────────────────────────────

class _BestTradeItem extends StatelessWidget {
  final TradeModel trade;

  const _BestTradeItem({required this.trade});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: AppColors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${trade.pairLabel} ${trade.directionLabel}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text1,
                  ),
                ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                trade.pnlLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.1),
                  borderRadius: AppRadius.full,
                ),
                child: Text(
                  trade.rLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Equity Curve Painter ─────────────────────────────────────

class _EquityCurvePainter extends CustomPainter {
  final double progress;

  _EquityCurvePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Generate equity data
    final data = <double>[];
    double v = 20000;
    for (int i = 0; i < 30; i++) {
      final change = (i % 4 == 3 ? -1 : 1) * (80 + (i * 20) % 200);
      v += change;
      data.add(v);
    }
    data[data.length - 1] = 24847;

    final minV = data.reduce((a, b) => a < b ? a : b) - 200;
    final maxV = data.reduce((a, b) => a > b ? a : b) + 200;
    final range = maxV - minV;

    final pad = const EdgeInsets.fromLTRB(8, 8, 8, 20);
    final chartW = w - pad.left - pad.right;
    final chartH = h - pad.top - pad.bottom;

    double px(int i) => pad.left + (i / (data.length - 1)) * chartW;
    double py(double val) =>
        pad.top + chartH - ((val - minV) / range) * chartH;

    // Grid
    for (int g = 0; g <= 3; g++) {
      final y = pad.top + (chartH / 3) * g;
      canvas.drawLine(
        Offset(pad.left, y),
        Offset(w - pad.right, y),
        Paint()
          ..color = Colors.white.withOpacity(0.04)
          ..strokeWidth = 1,
      );
    }

    // Determine visible points
    final visibleCount =
        (data.length * progress).clamp(1, data.length.toDouble()).toInt();

    // Fill area
    final fillPath = Path();
    fillPath.moveTo(px(0), py(data[0]));
    for (int i = 1; i < visibleCount; i++) {
      final cp1x = px(i - 1) + (px(i) - px(i - 1)) / 2;
      fillPath.cubicTo(
        cp1x, py(data[i - 1]),
        cp1x, py(data[i]),
        px(i), py(data[i]),
      );
    }
    fillPath.lineTo(px(visibleCount - 1), pad.top + chartH);
    fillPath.lineTo(px(0), pad.top + chartH);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.green.withOpacity(0.15),
            AppColors.green.withOpacity(0.0),
          ],
        ).createShader(
          Rect.fromLTWH(0, 0, w, h),
        ),
    );

    // Line
    final linePath = Path();
    linePath.moveTo(px(0), py(data[0]));
    for (int i = 1; i < visibleCount; i++) {
      final cp1x = px(i - 1) + (px(i) - px(i - 1)) / 2;
      linePath.cubicTo(
        cp1x, py(data[i - 1]),
        cp1x, py(data[i]),
        px(i), py(data[i]),
      );
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.green
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // End dot
    if (visibleCount > 0) {
      final endX = px(visibleCount - 1);
      final endY = py(data[visibleCount - 1]);
      canvas.drawCircle(
        Offset(endX, endY),
        4,
        Paint()..color = AppColors.green,
      );
      canvas.drawCircle(
        Offset(endX, endY),
        8,
        Paint()
          ..color = AppColors.green.withOpacity(0.2)
          ..style = PaintingStyle.fill,
      );
    }

    // Labels
    final labels = ['\$20k', '\$21k', '\$22k', '\$23k', '\$24k'];
    for (int i = 0; i < labels.length; i++) {
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: Colors.white.withOpacity(0.25),
            fontSize: 8,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          pad.left,
          pad.top + chartH - (i / (labels.length - 1)) * chartH - 5,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EquityCurvePainter old) =>
      old.progress != progress;
}