import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';
import '../../shared/models/signal_model.dart';
import '../../shared/widgets/apex_card.dart';

class SignalsScreen extends StatefulWidget {
  const SignalsScreen({super.key});

  @override
  State<SignalsScreen> createState() => _SignalsScreenState();
}

class _SignalsScreenState extends State<SignalsScreen>
    with TickerProviderStateMixin {
  int _selectedFilter = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<String> _filters = [
    'All',
    'XAUUSD',
    'EURUSD',
    'GBPUSD',
    'USDJPY',
    'GBPJPY',
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

  List<SignalModel> get _filteredSignals {
    if (_selectedFilter == 0) return SignalData.all;
    final pair = _filters[_selectedFilter];
    return SignalData.all
        .where((s) => s.pair == pair)
        .toList();
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Live Signals',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const LiveChip(),
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
                        duration: const Duration(milliseconds: 200),
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

              // Signals list
              Expanded(
                child: _filteredSignals.isEmpty
                    ? _EmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filteredSignals.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          return _SignalCard(
                            signal: _filteredSignals[i],
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

// ─── Signal Card ──────────────────────────────────────────────

class _SignalCard extends StatefulWidget {
  final SignalModel signal;
  final int index;

  const _SignalCard({
    required this.signal,
    required this.index,
  });

  @override
  State<_SignalCard> createState() => _SignalCardState();
}

class _SignalCardState extends State<_SignalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slide = Tween(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(
      Duration(milliseconds: widget.index * 80),
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
    final signal = widget.signal;

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: GestureDetector(
          onTap: () => context.go(AppRoutes.chart),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: AppRadius.lg,
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.hardEdge,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Direction stripe
                  Container(
                    width: 3,
                    color: signal.directionColor,
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    signal.pair,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _DirectionChip(
                                    label: signal.directionLabel,
                                    color: signal.directionColor,
                                  ),
                                  const SizedBox(width: 6),
                                  _TimeframeChip(
                                    label: signal.timeframeLabel,
                                  ),
                                ],
                              ),
                              _ConfidenceArc(
                                value: signal.aiConfidence / 100,
                                label:
                                    '${signal.aiConfidence.toInt()}%',
                                color: signal.aiConfidence >= 80
                                    ? AppColors.green
                                    : AppColors.accent,
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          Container(
                            height: 1,
                            color: AppColors.border,
                          ),
                          const SizedBox(height: 12),

                          // Price levels
                          Row(
                            children: [
                              Expanded(
                                child: _PriceLevel(
                                  label: 'Entry',
                                  value: signal.entry
                                      .toStringAsFixed(
                                    signal.entry > 100 ? 2 : 4,
                                  ),
                                  color: AppColors.text1,
                                ),
                              ),
                              Expanded(
                                child: _PriceLevel(
                                  label: 'Take Profit',
                                  value: signal.takeProfit2
                                      .toStringAsFixed(
                                    signal.takeProfit2 > 100 ? 2 : 4,
                                  ),
                                  color: AppColors.green,
                                ),
                              ),
                              Expanded(
                                child: _PriceLevel(
                                  label: 'Stop Loss',
                                  value: signal.stopLoss
                                      .toStringAsFixed(
                                    signal.stopLoss > 100 ? 2 : 4,
                                  ),
                                  color: AppColors.red,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // RR bar
                          _RRBar(rr: signal.riskReward),

                          const SizedBox(height: 8),

                          // Footer
                          Text(
                            '${signal.strategy} · ${signal.session} · ${signal.timeAgo}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.text3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────

class _DirectionChip extends StatelessWidget {
  final String label;
  final Color color;

  const _DirectionChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppRadius.sm,
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TimeframeChip extends StatelessWidget {
  final String label;

  const _TimeframeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.1),
        borderRadius: AppRadius.sm,
        border: Border.all(
          color: AppColors.gold.withOpacity(0.2),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.gold,
        ),
      ),
    );
  }
}

class _ConfidenceArc extends StatelessWidget {
  final double value;
  final String label;
  final Color color;

  const _ConfidenceArc({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 4,
            backgroundColor: AppColors.bg4,
            valueColor: AlwaysStoppedAnimation(color),
            strokeCap: StrokeCap.round,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
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

class _PriceLevel extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PriceLevel({
    required this.label,
    required this.value,
    required this.color,
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

class _RRBar extends StatelessWidget {
  final double rr;

  const _RRBar({required this.rr});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'SL',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.text3,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 10,
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.4),
              borderRadius: AppRadius.full,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.12),
            borderRadius: AppRadius.full,
          ),
          child: Text(
            '${rr.toStringAsFixed(1)}R',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 15,
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.4),
              borderRadius: AppRadius.full,
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'TP',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.text3,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.bg3,
              borderRadius: AppRadius.lg,
            ),
            child: const Icon(
              Icons.bolt_outlined,
              color: AppColors.text3,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No signals for this pair',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.text2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check back during active sessions',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.text3,
            ),
          ),
        ],
      ),
    );
  }
}