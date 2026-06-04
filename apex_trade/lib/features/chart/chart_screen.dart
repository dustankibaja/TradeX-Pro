import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/apex_card.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen>
    with TickerProviderStateMixin {
  int _selectedTimeframe = 3; // H1 default
  late AnimationController _fadeController;
  late AnimationController _priceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _priceAnimation;

  final List<String> _timeframes = [
    'M5', 'M15', 'M30', 'H1', 'H4', 'D1', 'W1',
  ];

  // Simulated candle data
  late List<_CandleData> _candles;

  @override
  void initState() {
    super.initState();
    _generateCandles();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _priceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );
    _priceAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _priceController,
        curve: Curves.easeOut,
      ),
    );

    _fadeController.forward();
    _priceController.forward();
  }

  void _generateCandles() {
    _candles = [];
    double price = 2300;
    final random = ValueNotifier(0);

    for (int i = 0; i < 50; i++) {
      final open = price;
      // Slight upward bias
      final change = (i % 3 == 0 ? 1 : -1) *
          (2 + (i * 0.3) % 8);
      final close = open + change;
      final high = [open, close].reduce(
            (a, b) => a > b ? a : b,
          ) +
          (1 + i % 4).toDouble();
      final low = [open, close].reduce(
            (a, b) => a < b ? a : b,
          ) -
          (1 + i % 3).toDouble();

      _candles.add(_CandleData(
        open: open,
        close: close,
        high: high,
        low: low,
      ));
      price = close;
    }
    // Make last candle realistic
    _candles.last = _CandleData(
      open: 2312.0,
      close: 2318.4,
      high: 2324.8,
      low: 2308.0,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _priceController.dispose();
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
                child: _ChartHeader(),
              ),

              // Timeframe selector
              SliverToBoxAdapter(
                child: _TimeframeSelector(
                  timeframes: _timeframes,
                  selected: _selectedTimeframe,
                  onSelect: (i) {
                    setState(() {
                      _selectedTimeframe = i;
                      _generateCandles();
                    });
                    _priceController.reset();
                    _priceController.forward();
                  },
                ),
              ),

              // Chart
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: AppColors.bg2,
                      borderRadius: AppRadius.lg,
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: AnimatedBuilder(
                      animation: _priceAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _CandlestickPainter(
                            candles: _candles,
                            progress: _priceAnimation.value,
                          ),
                          child: const SizedBox.expand(),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Zone legend
              SliverToBoxAdapter(
                child: _ZoneLegend(),
              ),

              // Live ticker
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.xl,
                    0,
                  ),
                  child: _LiveTickerCard(),
                ),
              ),

              // Signal info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.xl,
                    0,
                  ),
                  child: _ActiveSignalCard(),
                ),
              ),

              // SMC Analysis
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.xl,
                    0,
                  ),
                  child: _SMCAnalysisCard(),
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

class _ChartHeader extends StatelessWidget {
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
            children: [
              Row(
                children: [
                  const Text(
                    'XAUUSD',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.12),
                      borderRadius: AppRadius.full,
                    ),
                    child: const Text(
                      'GOLD',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Text(
                    '2,318.40',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text1,
                      fontFamily: 'monospace',
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '+9.80',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.green,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '(+0.42%)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.bg3,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Icon(
              Icons.tune_rounded,
              size: 18,
              color: AppColors.text2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Timeframe Selector ───────────────────────────────────────

class _TimeframeSelector extends StatelessWidget {
  final List<String> timeframes;
  final int selected;
  final ValueChanged<int> onSelect;

  const _TimeframeSelector({
    required this.timeframes,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
        ),
        itemCount: timeframes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final isActive = selected == i;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.accent
                    : AppColors.bg3,
                borderRadius: AppRadius.sm,
                border: Border.all(
                  color: isActive
                      ? AppColors.accent
                      : AppColors.border,
                ),
              ),
              child: Text(
                timeframes[i],
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
    );
  }
}

// ─── Zone Legend ──────────────────────────────────────────────

class _ZoneLegend extends StatelessWidget {
  final List<Map<String, dynamic>> zones = const [
    {'label': 'Demand Zone', 'color': AppColors.green},
    {'label': 'Supply Zone', 'color': AppColors.red},
    {'label': 'FVG', 'color': AppColors.accent},
    {'label': 'MSS', 'color': AppColors.gold},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        0,
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: zones.map((z) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: (z['color'] as Color).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                z['label'] as String,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.text2,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Live Ticker Card ─────────────────────────────────────────

class _LiveTickerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ApexCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _TickerStat(label: 'BID', value: '2,318.30'),
          _TickerStat(label: 'ASK', value: '2,318.50'),
          _TickerStat(
            label: 'HIGH',
            value: '2,324.80',
            valueColor: AppColors.green,
          ),
          _TickerStat(
            label: 'LOW',
            value: '2,305.40',
            valueColor: AppColors.red,
          ),
        ],
      ),
    );
  }
}

class _TickerStat extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _TickerStat({
    required this.label,
    required this.value,
    this.valueColor = AppColors.text1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.text3,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

// ─── Active Signal Card ───────────────────────────────────────

class _ActiveSignalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.green.withOpacity(0.06),
            AppColors.accent.withOpacity(0.04),
          ],
        ),
        borderRadius: AppRadius.lg,
        border: Border.all(
          color: AppColors.green.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Signal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.12),
                  borderRadius: AppRadius.sm,
                  border: Border.all(
                    color: AppColors.green.withOpacity(0.25),
                  ),
                ),
                child: const Text(
                  'BUY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
            children: const [
              _SignalLevel(
                label: 'Entry',
                value: '2,318.40',
                color: AppColors.text1,
              ),
              _SignalLevel(
                label: 'Risk:Reward',
                value: '1:1.5R',
                color: AppColors.green,
              ),
              _SignalLevel(
                label: 'AI Score',
                value: '87/100',
                color: AppColors.green,
              ),
              _SignalLevel(
                label: 'TP 1',
                value: '2,328.00',
                color: AppColors.green,
              ),
              _SignalLevel(
                label: 'TP 2',
                value: '2,334.00',
                color: AppColors.green,
              ),
              _SignalLevel(
                label: 'Stop Loss',
                value: '2,308.00',
                color: AppColors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignalLevel extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SignalLevel({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.text3,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

// ─── SMC Analysis Card ────────────────────────────────────────

class _SMCAnalysisCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ApexCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'SMC Analysis'),
          const SizedBox(height: 14),
          _SMCRow(
            label: 'Market Structure',
            value: 'Bullish BOS',
            color: AppColors.green,
            icon: Icons.trending_up_rounded,
          ),
          const SizedBox(height: 10),
          _SMCRow(
            label: 'Order Block',
            value: '2,312 – 2,316',
            color: AppColors.accent,
            icon: Icons.crop_square_rounded,
          ),
          const SizedBox(height: 10),
          _SMCRow(
            label: 'Fair Value Gap',
            value: '2,308 – 2,314',
            color: AppColors.accent2,
            icon: Icons.layers_rounded,
          ),
          const SizedBox(height: 10),
          _SMCRow(
            label: 'Liquidity',
            value: 'Swept at 2,306',
            color: AppColors.gold,
            icon: Icons.water_rounded,
          ),
          const SizedBox(height: 10),
          _SMCRow(
            label: 'Premium / Discount',
            value: 'Discount Zone',
            color: AppColors.green,
            icon: Icons.percent_rounded,
          ),
        ],
      ),
    );
  }
}

class _SMCRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SMCRow({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.text2,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

// ─── Candle Data Model ────────────────────────────────────────

class _CandleData {
  final double open;
  final double close;
  final double high;
  final double low;

  const _CandleData({
    required this.open,
    required this.close,
    required this.high,
    required this.low,
  });

  bool get isBull => close >= open;
}

// ─── Candlestick Painter ──────────────────────────────────────

class _CandlestickPainter extends CustomPainter {
  final List<_CandleData> candles;
  final double progress;

  _CandlestickPainter({
    required this.candles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Visible candles based on progress
    final visibleCount =
        (candles.length * progress).clamp(1, candles.length).toInt();
    final visibleCandles = candles.sublist(
      candles.length - visibleCount,
    );

    if (visibleCandles.isEmpty) return;

    // Price range
    final allPrices = visibleCandles
        .expand((c) => [c.high, c.low])
        .toList();
    final minP =
        allPrices.reduce((a, b) => a < b ? a : b) - 3;
    final maxP =
        allPrices.reduce((a, b) => a > b ? a : b) + 3;
    final range = maxP - minP;

    final pad = const EdgeInsets.fromLTRB(8, 16, 48, 24);
    final chartW = w - pad.left - pad.right;
    final chartH = h - pad.top - pad.bottom;
    final candleW = chartW / visibleCandles.length;

    double py(double price) =>
        pad.top + chartH - ((price - minP) / range) * chartH;
    double px(int i) =>
        pad.left + i * candleW + candleW / 2;

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;

    for (int g = 0; g <= 4; g++) {
      final y = pad.top + (chartH / 4) * g;
      canvas.drawLine(
        Offset(pad.left, y),
        Offset(w - pad.right, y),
        gridPaint,
      );
      // Price labels
      final price = maxP - (range / 4) * g;
      final tp = TextPainter(
        text: TextSpan(
          text: price.toStringAsFixed(0),
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 9,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(w - pad.right + 4, y - 5),
      );
    }

    // Demand zone
    final demandTop = py(2320);
    final demandBot = py(2312);
    canvas.drawRect(
      Rect.fromLTRB(
        pad.left,
        demandTop,
        w - pad.right,
        demandBot,
      ),
      Paint()
        ..color = AppColors.green.withOpacity(0.06),
    );
    _drawDashedLine(
      canvas,
      Offset(pad.left, demandTop),
      Offset(w - pad.right, demandTop),
      AppColors.green.withOpacity(0.3),
    );

    // Supply zone
    final supplyTop = py(2335);
    final supplyBot = py(2328);
    if (supplyTop < h && supplyBot < h) {
      canvas.drawRect(
        Rect.fromLTRB(
          pad.left,
          supplyTop,
          w - pad.right,
          supplyBot,
        ),
        Paint()
          ..color = AppColors.red.withOpacity(0.05),
      );
    }

    // FVG zone
    final fvgStart = (visibleCandles.length * 0.35).toInt();
    final fvgEnd = (visibleCandles.length * 0.5).toInt();
    if (fvgStart < visibleCandles.length) {
      canvas.drawRect(
        Rect.fromLTRB(
          px(fvgStart),
          py(2315),
          px(fvgEnd),
          py(2310),
        ),
        Paint()
          ..color = AppColors.accent.withOpacity(0.07),
      );
    }

    // Draw candles
    for (int i = 0; i < visibleCandles.length; i++) {
      final c = visibleCandles[i];
      final x = px(i);
      final color =
          c.isBull ? AppColors.green : AppColors.red;
      final bw = (candleW * 0.6).clamp(2.0, 12.0);

      // Wick
      final wickPaint = Paint()
        ..color = color
        ..strokeWidth = 1.0;
      canvas.drawLine(
        Offset(x, py(c.high)),
        Offset(x, py(c.low)),
        wickPaint,
      );

      // Body
      final bodyTop = py(c.isBull ? c.close : c.open);
      final bodyBot = py(c.isBull ? c.open : c.close);
      final bodyH = (bodyBot - bodyTop).abs().clamp(1.0, double.infinity);

      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - bw / 2, bodyTop, bw, bodyH),
        const Radius.circular(1.5),
      );
      canvas.drawRRect(
        rr,
        Paint()
          ..color = color.withOpacity(0.15),
      );
      canvas.drawRRect(
        rr,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    // MSS marker
    final mssIdx = (visibleCandles.length * 0.65).toInt();
    if (mssIdx < visibleCandles.length) {
      final mssX = px(mssIdx);
      final mssY = py(visibleCandles[mssIdx].high + 2);

      final mssPaint = TextPainter(
        text: const TextSpan(
          text: 'MSS',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      mssPaint.paint(
        canvas,
        Offset(mssX - mssPaint.width / 2, mssY - 12),
      );

      _drawDashedLine(
        canvas,
        Offset(mssX, mssY),
        Offset(mssX, pad.top + chartH),
        AppColors.gold.withOpacity(0.3),
      );
    }

    // Current price line
    final lastClose = visibleCandles.last.close;
    final priceY = py(lastClose);
    _drawDashedLine(
      canvas,
      Offset(pad.left, priceY),
      Offset(w - pad.right - 44, priceY),
      AppColors.accent.withOpacity(0.5),
    );

    // Price label box
    final priceLabelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w - pad.right - 40, priceY - 9, 38, 18),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      priceLabelRect,
      Paint()..color = AppColors.accent,
    );
    final priceTp = TextPainter(
      text: TextSpan(
        text: lastClose.toStringAsFixed(1),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    priceTp.paint(
      canvas,
      Offset(
        w - pad.right - 40 + (38 - priceTp.width) / 2,
        priceY - priceTp.height / 2,
      ),
    );

    // BUY ZONE badge
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pad.left + 6, pad.top + 6, 110, 34),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      badgeRect,
      Paint()
        ..color = Colors.black.withOpacity(0.6),
    );
    final badgeTp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '● BUY ZONE ACTIVE\n',
            style: TextStyle(
              color: AppColors.green,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: '2,316 – 2,320',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 8,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    badgeTp.paint(
      canvas,
      Offset(pad.left + 10, pad.top + 9),
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = (dx * dx + dy * dy);
    if (length == 0) return;
    final unitX = dx / length * dashWidth;
    final unitY = dy / length * dashWidth;

    double x = start.dx;
    double y = start.dy;
    bool draw = true;
    double traveled = 0;
    final total = (dx.abs() + dy.abs());

    while (traveled < total) {
      final nextX = x + unitX * (total / dashWidth);
      final nextY = y + unitY * (total / dashWidth);
      if (draw) {
        canvas.drawLine(Offset(x, y), Offset(x + unitX * 2, y + unitY * 2), paint);
      }
      x += unitX * (dashWidth + dashSpace) / dashWidth * 2;
      y += unitY * (dashWidth + dashSpace) / dashWidth * 2;
      traveled += dashWidth + dashSpace;
      draw = !draw;
    }
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter old) =>
      old.progress != progress || old.candles != candles;
}