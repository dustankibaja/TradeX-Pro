import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.accent,
                                Color(0xFF6C63FF),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.trending_up_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'APEX',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.auth),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bg3,
                          borderRadius: AppRadius.full,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page view
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) =>
                      setState(() => _currentPage = i),
                  children: const [
                    _SlidePage(
                      title: 'AI-Powered Trading\nSignals',
                      subtitle:
                          'Institutional-grade Smart Money Concepts signals delivered in real-time for Forex & Gold markets.',
                      child: _SignalIllustration(),
                    ),
                    _SlidePage(
                      title: 'Precision Risk\nManagement',
                      subtitle:
                          'Advanced TP/SL algorithms, RR ratios, and AI confidence scoring to protect and grow your account.',
                      child: _RiskIllustration(),
                    ),
                    _SlidePage(
                      title: 'Trade Like an\nInstitution',
                      subtitle:
                          'Join 12,400+ traders using APEX to capture institutional moves in Forex and Gold markets.',
                      child: _InstitutionIllustration(),
                    ),
                  ],
                ),
              ),

              // Bottom controls
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.xxxl,
                ),
                child: Column(
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => _DotIndicator(
                          isActive: i == _currentPage,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.md,
                          ),
                        ),
                        child: Text(
                          _currentPage == 2
                              ? 'Get Started'
                              : 'Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () => context.go(AppRoutes.auth),
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.text3,
                              ),
                            ),
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Slide Page ───────────────────────────────────────────────

class _SlidePage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SlidePage({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
      ),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              margin: const EdgeInsets.symmetric(
                vertical: AppSpacing.xl,
              ),
              decoration: BoxDecoration(
                color: AppColors.bg2,
                borderRadius: AppRadius.xl,
                border: Border.all(color: AppColors.border),
              ),
              clipBehavior: Clip.hardEdge,
              child: child,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text1,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.text2,
                    height: 1.6,
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

// ─── Dot Indicator ────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  final bool isActive;

  const _DotIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isActive ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.accent : AppColors.bg4,
        borderRadius: AppRadius.full,
      ),
    );
  }
}

// ─── Illustrations ────────────────────────────────────────────

class _SignalIllustration extends StatelessWidget {
  const _SignalIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg2,
      child: CustomPaint(
        painter: _SignalPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SignalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;

    for (int i = 1; i < 6; i++) {
      canvas.drawLine(
        Offset(0, h / 6 * i),
        Offset(w, h / 6 * i),
        gridPaint,
      );
    }

    final bars = [0.5, 0.7, 0.55, 0.85, 0.65, 0.9, 0.75, 0.95];
    final barW = w / (bars.length * 2);

    for (int i = 0; i < bars.length; i++) {
      final barH = h * 0.6 * bars[i];
      final x = (i * 2 + 0.5) * barW;
      final isLast = i == bars.length - 1;
      final barPaint = Paint()
        ..color = isLast
            ? AppColors.accent
            : AppColors.accent.withOpacity(0.3 + bars[i] * 0.4)
        ..style = PaintingStyle.fill;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, h * 0.75 - barH, barW, barH),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, barPaint);
    }

    final linePaint = Paint()
      ..color = AppColors.green
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final points = [
      Offset(w * 0.1, h * 0.65),
      Offset(w * 0.25, h * 0.48),
      Offset(w * 0.4, h * 0.55),
      Offset(w * 0.55, h * 0.32),
      Offset(w * 0.7, h * 0.42),
      Offset(w * 0.85, h * 0.22),
    ];

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    canvas.drawCircle(
      points.last,
      5,
      Paint()..color = AppColors.green,
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '+28.4%',
        style: TextStyle(
          color: AppColors.green,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(w * 0.55, h * 0.15));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RiskIllustration extends StatelessWidget {
  const _RiskIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg2,
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: 0.87,
                  strokeWidth: 8,
                  backgroundColor: AppColors.bg4,
                  valueColor: const AlwaysStoppedAnimation(
                    AppColors.green,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              const Column(
                children: [
                  Text(
                    '87%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                  ),
                  Text(
                    'AI Score',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.text3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          _RiskBar(
            label: 'XAUUSD',
            value: 0.78,
            color: AppColors.gold,
          ),
          const SizedBox(height: 10),
          _RiskBar(
            label: 'EURUSD',
            value: 0.71,
            color: AppColors.accent,
          ),
          const SizedBox(height: 10),
          _RiskBar(
            label: 'GBPUSD',
            value: 0.65,
            color: AppColors.green,
          ),
        ],
      ),
    );
  }
}

class _RiskBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _RiskBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.text2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: AppRadius.full,
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.bg4,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _InstitutionIllustration extends StatelessWidget {
  const _InstitutionIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg2,
      child: CustomPaint(
        painter: _InstitutionPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _InstitutionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final ringColors = [
      AppColors.accent.withOpacity(0.06),
      AppColors.accent.withOpacity(0.08),
      AppColors.accent.withOpacity(0.12),
    ];
    final radii = [w * 0.42, w * 0.30, w * 0.18];

    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(cx, cy),
        radii[i],
        Paint()
          ..color = ringColors[i]
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(cx, cy),
        radii[i],
        Paint()
          ..color = AppColors.accent.withOpacity(0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    canvas.drawCircle(
      Offset(cx, cy),
      28,
      Paint()
        ..color = AppColors.accent.withOpacity(0.2)
        ..style = PaintingStyle.fill,
    );

    final tp = TextPainter(
      text: const TextSpan(
        children: [
          TextSpan(
            text: '96%\n',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: 'ACCURACY',
            style: TextStyle(
              color: AppColors.text3,
              fontSize: 7,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));

    final orbitItems = [
      (Offset(cx, cy - radii[0]), AppColors.gold, '12.4K\nTraders'),
      (Offset(cx + radii[0], cy), AppColors.green, '73%\nWin Rate'),
      (Offset(cx - radii[0], cy), AppColors.red, '847\nSignals'),
      (Offset(cx, cy + radii[0]), AppColors.accent2, '4.2x\nAvg RR'),
    ];

    for (final item in orbitItems) {
      canvas.drawCircle(
        item.$1,
        22,
        Paint()
          ..color = item.$2.withOpacity(0.15)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        item.$1,
        22,
        Paint()
          ..color = item.$2.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      final lp = TextPainter(
        text: TextSpan(
          text: item.$3,
          style: TextStyle(
            color: item.$2,
            fontSize: 7,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      lp.paint(
        canvas,
        Offset(
          item.$1.dx - lp.width / 2,
          item.$1.dy - lp.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}