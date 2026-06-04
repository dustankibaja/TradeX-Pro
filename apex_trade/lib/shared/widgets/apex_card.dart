import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// Base card used everywhere in the app
class ApexCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;
  final bool showBorder;
  final Gradient? gradient;

  const ApexCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
    this.showBorder = true,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: gradient != null ? null : (color ?? AppColors.bg2),
          gradient: gradient,
          borderRadius: AppRadius.lg,
          border: showBorder
              ? Border.all(color: AppColors.border)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            splashColor: AppColors.accent.withOpacity(0.05),
            highlightColor: AppColors.accent.withOpacity(0.03),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// Smaller surface card
class ApexSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const ApexSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bg3,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: AppColors.border.withOpacity(0.5),
          ),
        ),
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }
}

// Gradient accent card — used for balance and hero cards
class ApexGradientCard extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const ApexGradientCard({
    super.key,
    required this.child,
    this.colors = const [
      Color(0xFF0D1D3E),
      Color(0xFF111827),
    ],
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: AppRadius.xl,
          border: Border.all(
            color: AppColors.accent.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
        child: child,
      ),
    );
  }
}

// Pill / chip widget
class ApexChip extends StatelessWidget {
  final String label;
  final Color color;
  final Widget? leading;
  final double fontSize;

  const ApexChip({
    super.key,
    required this.label,
    required this.color,
    this.leading,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppRadius.full,
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// Live indicator chip with pulsing dot
class LiveChip extends StatefulWidget {
  const LiveChip({super.key});

  @override
  State<LiveChip> createState() => _LiveChipState();
}

class _LiveChipState extends State<LiveChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.green.withOpacity(0.12),
        borderRadius: AppRadius.full,
        border: Border.all(
          color: AppColors.green.withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _opacity,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'LIVE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.green,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Section header row
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.text3,
            letterSpacing: 0.8,
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.accent,
              ),
            ),
          ),
      ],
    );
  }
}

// Divider with consistent styling
class ApexDivider extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  const ApexDivider({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
      ),
      height: 1,
      color: AppColors.border,
    );
  }
}