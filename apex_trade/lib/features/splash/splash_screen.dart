import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _barController;
  late AnimationController _glowController;

  // Logo animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  // Text animations
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  // Loading bar
  late Animation<double> _barProgress;

  // Glow pulse
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();

    // Make status bar transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    // Logo bounces in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoScale = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );
    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5),
      ),
    );

    // Text slides up
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );
    _textSlide = Tween(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    // Loading bar fills up
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _barProgress = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _barController,
        curve: Curves.easeInOut,
      ),
    );

    // Glow pulses
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _glowOpacity = Tween(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _startSequence() async {
    // Wait a moment then start logo
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    // Text comes in after logo
    await Future.delayed(const Duration(milliseconds: 400));
    _textController.forward();

    // Loading bar starts
    await Future.delayed(const Duration(milliseconds: 300));
    _barController.forward();

    // Navigate to onboarding when bar completes
    await Future.delayed(const Duration(milliseconds: 2400));
    if (mounted) {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _barController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: Stack(
        children: [
          // Background glow effect
          Positioned(
            top: -100,
            left: -100,
            right: -100,
            child: FadeTransition(
              opacity: _glowOpacity,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main content centered
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo mark
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoOpacity,
                    child: _LogoMark(),
                  ),
                ),

                const SizedBox(height: 24),

                // Brand name and tagline
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: Column(
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'APEX',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent,
                                  letterSpacing: -1,
                                ),
                              ),
                              TextSpan(
                                text: ' TRADE',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text1,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'AI-POWERED INSTITUTIONAL TRADING',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text3,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Loading bar
                FadeTransition(
                  opacity: _textOpacity,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 120,
                        child: AnimatedBuilder(
                          animation: _barProgress,
                          builder: (context, child) {
                            return Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: AppColors.bg3,
                                borderRadius: AppRadius.full,
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _barProgress.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.accent,
                                        AppColors.accent2,
                                      ],
                                    ),
                                    borderRadius: AppRadius.full,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accent
                                            .withOpacity(0.5),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Initializing AI Engine...',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.text3,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Version at bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textOpacity,
              child: const Text(
                'v1.0.0 — Phase 1 MVP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.text3,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Logo mark widget
class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accent, Color(0xFF6C63FF)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _LogoPainter(),
      ),
    );
  }
}

// Custom logo painter
class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // Chart line path
    final path = Path()
      ..moveTo(w * 0.18, h * 0.72)
      ..lineTo(w * 0.35, h * 0.50)
      ..lineTo(w * 0.50, h * 0.62)
      ..lineTo(w * 0.68, h * 0.32)
      ..lineTo(w * 0.82, h * 0.45);

    canvas.drawPath(path, paint);

    // Accent dot at peak
    final dotPaint = Paint()
      ..color = AppColors.green
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(w * 0.68, h * 0.32),
      3.5,
      dotPaint,
    );

    // Arrow head
    final arrowPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final arrow = Path()
      ..moveTo(w * 0.75, h * 0.38)
      ..lineTo(w * 0.82, h * 0.45)
      ..lineTo(w * 0.74, h * 0.52);

    canvas.drawPath(arrow, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}