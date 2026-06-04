import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';
import '../../shared/models/market_model.dart';
import '../../shared/models/signal_model.dart';
import '../../shared/widgets/apex_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late Animation<double> _headerFade;
  late Animation<double> _cardsFade;
  late Animation<Offset> _cardsSlide;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _headerFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _cardsFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsController, curve: Curves.easeOut),
    );
    _cardsSlide = Tween(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _cardsController, curve: Curves.easeOut),
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _cardsController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 1200));
          },
          color: AppColors.accent,
          backgroundColor: AppColors.bg2,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerFade,
                  child: _DashboardHeader(),
                ),
              ),

              // Balance card
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _cardsSlide,
                  child: FadeTransition(
                    opacity: _cardsFade,
                    child: _BalanceCard(),
                  ),
                ),
              ),

              // Session indicators
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _cardsFade,
                  child: _SessionRow(),
                ),
              ),

              // AI Signal banner
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _cardsFade,
                  child: _AISignalBanner(),
                ),
              ),

              // Markets grid
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _cardsFade,
                  child: _MarketsSection(),
                ),
              ),

              // Active trades
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _cardsFade,
                  child: _ActiveTradesSection(),
                ),
              ),

              // AI Sentiment
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _cardsFade,
                  child: _SentimentCard(),
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

// ─── Header ──────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Good morning,',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.text3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Alex Chen 👋',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Notification bell
              GestureDetector(
                onTap: () => context.go(AppRoutes.notifications),
                child: Stack(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.bg3,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        size: 18,
                        color: AppColors.text2,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Avatar
              GestureDetector(
                onTap: () => context.go(AppRoutes.profile),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, Color(0xFF6C63FF)],
                    ),
                    borderRadius: BorderRadius.circular(19),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'AC',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
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

// ─── Balance Card ─────────────────────────────────────────────

class _BalanceCard extends StatefulWidget {
  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _counterController;
  late Animation<double> _counterAnimation;

  @override
  void initState() {
    super.initState();
    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _counterAnimation = Tween(begin: 0.0, end: 24847.63).animate(
      CurvedAnimation(
        parent: _counterController,
        curve: Curves.easeOut,
      ),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _counterController.forward();
    });
  }

  @override
  void dispose() {
    _counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1D3E), Color(0xFF111827)],
          ),
          borderRadius: AppRadius.xl,
          border: Border.all(
            color: AppColors.accent.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background circles
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: 10,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6C63FF).withOpacity(0.05),
                ),
              ),
            ),

            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL PORTFOLIO VALUE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text3,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),

                // Animated counter
                AnimatedBuilder(
                  animation: _counterAnimation,
                  builder: (context, child) {
                    return Text(
                      '\$${_counterAnimation.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text1,
                        letterSpacing: -1,
                        fontFamily: 'monospace',
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(0.12),
                        borderRadius: AppRadius.full,
                      ),
                      child: const Text(
                        '+\$1,247.80',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '+5.28% today',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.06),
                ),

                const SizedBox(height: 16),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _BalanceStat(
                      label: 'Win Rate',
                      value: '73.4%',
                      valueColor: AppColors.green,
                    ),
                    _BalanceStat(
                      label: 'Open Trades',
                      value: '3',
                    ),
                    _BalanceStat(
                      label: 'This Month',
                      value: '+28.4%',
                      valueColor: AppColors.green,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _BalanceStat({
    required this.label,
    required this.value,
    this.valueColor = AppColors.text1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.text3,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: valueColor,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

// ─── Session Row ──────────────────────────────────────────────

class _SessionRow extends StatelessWidget {
  final List<Map<String, dynamic>> sessions = const [
    {'name': 'London Open', 'active': true},
    {'name': 'NY Session', 'active': true},
    {'name': 'Asia', 'active': false},
    {'name': 'Sydney', 'active': false},
    {'name': 'Tokyo', 'active': false},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: sessions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final session = sessions[i];
          final isActive = session['active'] as bool;
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.green.withOpacity(0.1)
                  : AppColors.bg3,
              borderRadius: AppRadius.full,
              border: Border.all(
                color: isActive
                    ? AppColors.green.withOpacity(0.25)
                    : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isActive) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                Text(
                  session['name'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? AppColors.green
                        : AppColors.text3,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── AI Signal Banner ─────────────────────────────────────────

class _AISignalBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        0,
      ),
      child: GestureDetector(
        onTap: () => context.go(AppRoutes.signals),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.green.withOpacity(0.08),
                AppColors.accent.withOpacity(0.06),
              ],
            ),
            borderRadius: AppRadius.lg,
            border: Border.all(
              color: AppColors.green.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'New Signal — XAUUSD',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.green,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'BUY at 2,318.40 · TP: 2,334 · SL: 2,308',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.text2,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '87%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Markets Section ──────────────────────────────────────────

class _MarketsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final markets = MarketData.watchlist;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        0,
      ),
      child: Column(
        children: [
          SectionHeader(
            title: 'Live Markets',
            actionLabel: 'View All →',
            onAction: () => context.go(AppRoutes.signals),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
            ),
            itemCount: markets.length > 4 ? 4 : markets.length,
            itemBuilder: (context, i) {
              return _MarketCard(market: markets[i]);
            },
          ),
        ],
      ),
    );
  }
}

class _MarketCard extends StatelessWidget {
  final MarketModel market;

  const _MarketCard({required this.market});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.chart),
      child: Container(
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
                  market.symbol,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: market.typeColor.withOpacity(0.12),
                    borderRadius: AppRadius.full,
                  ),
                  child: Text(
                    market.typeLabel,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: market.typeColor,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  market.priceLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text1,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: market.changeColor.withOpacity(0.12),
                        borderRadius: AppRadius.full,
                      ),
                      child: Text(
                        market.changeLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: market.changeColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _Sparkline(
                      data: market.sparklineData,
                      color: market.changeColor,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Mini sparkline chart
class _Sparkline extends StatelessWidget {
  final List<double> data;
  final Color color;

  const _Sparkline({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 20,
      child: CustomPaint(
        painter: _SparklinePainter(data: data, color: color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    if (range == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - ((data[i] - min) / range) * size.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Active Trades ────────────────────────────────────────────

class _ActiveTradesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        0,
      ),
      child: Column(
        children: [
          SectionHeader(
            title: 'Active Trades',
            actionLabel: 'History →',
            onAction: () => context.go(AppRoutes.history),
          ),
          const SizedBox(height: AppSpacing.md),
          _TradeItem(
            pair: 'XAUUSD',
            direction: 'BUY',
            entry: '2,312.00',
            pnl: '+\$184.20',
            rMultiple: '+2.4R',
            isBuy: true,
          ),
          const SizedBox(height: 8),
          _TradeItem(
            pair: 'EURUSD',
            direction: 'SELL',
            entry: '1.0861',
            pnl: '+\$62.40',
            rMultiple: '+0.8R',
            isBuy: false,
          ),
          const SizedBox(height: 8),
          _TradeItem(
            pair: 'GBPJPY',
            direction: 'BUY',
            entry: '190.82',
            pnl: '+\$156.00',
            rMultiple: '+1.2R',
            isBuy: true,
          ),
        ],
      ),
    );
  }
}

class _TradeItem extends StatelessWidget {
  final String pair;
  final String direction;
  final String entry;
  final String pnl;
  final String rMultiple;
  final bool isBuy;

  const _TradeItem({
    required this.pair,
    required this.direction,
    required this.entry,
    required this.pnl,
    required this.rMultiple,
    required this.isBuy,
  });

  @override
  Widget build(BuildContext context) {
    final color = isBuy ? AppColors.green : AppColors.red;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Text(
              direction,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pair,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text1,
                  ),
                ),
                Text(
                  'Entry $entry',
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
                pnl,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
              ),
              Text(
                rMultiple,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Sentiment Card ───────────────────────────────────────────

class _SentimentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        0,
      ),
      child: Column(
        children: [
          const SectionHeader(title: 'AI Market Sentiment'),
          const SizedBox(height: AppSpacing.md),
          ApexCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _SentimentStat(
                      label: 'Bullish',
                      value: '62%',
                      color: AppColors.green,
                    ),
                    _SentimentStat(
                      label: 'Neutral',
                      value: '22%',
                      color: AppColors.text2,
                    ),
                    _SentimentStat(
                      label: 'Bearish',
                      value: '16%',
                      color: AppColors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Sentiment bar
                ClipRRect(
                  borderRadius: AppRadius.full,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 62,
                        child: Container(
                          height: 8,
                          color: AppColors.green.withOpacity(0.7),
                        ),
                      ),
                      Expanded(
                        flex: 22,
                        child: Container(
                          height: 8,
                          color: AppColors.text3.withOpacity(0.7),
                        ),
                      ),
                      Expanded(
                        flex: 16,
                        child: Container(
                          height: 8,
                          color: AppColors.red.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Based on 847 confluence factors across 12 timeframes',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.text3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SentimentStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SentimentStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.text3,
          ),
        ),
      ],
    );
  }
}