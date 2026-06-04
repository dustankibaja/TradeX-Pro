import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// Shimmer animation widget — used while data is loading
class ShimmerLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ??
                const BorderRadius.all(Radius.circular(8)),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
              colors: const [
                AppColors.bg3,
                AppColors.bg4,
                AppColors.bg3,
              ],
            ),
          ),
        );
      },
    );
  }
}

// Shimmer card — full card placeholder while loading
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerLoader(
                width: 80,
                height: 14,
                borderRadius: AppRadius.sm,
              ),
              ShimmerLoader(
                width: 48,
                height: 22,
                borderRadius: AppRadius.full,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ShimmerLoader(
            width: 140,
            height: 28,
            borderRadius: AppRadius.sm,
          ),
          const SizedBox(height: 8),
          ShimmerLoader(
            width: 100,
            height: 12,
            borderRadius: AppRadius.sm,
          ),
        ],
      ),
    );
  }
}

// Shimmer signal card placeholder
class ShimmerSignalCard extends StatelessWidget {
  const ShimmerSignalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ShimmerLoader(width: 70, height: 18),
                  const SizedBox(width: 8),
                  ShimmerLoader(
                    width: 40,
                    height: 22,
                    borderRadius: AppRadius.full,
                  ),
                ],
              ),
              ShimmerLoader(
                width: 56,
                height: 56,
                borderRadius: AppRadius.full,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: AppColors.border,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoader(width: 40, height: 10),
                    const SizedBox(height: 6),
                    ShimmerLoader(width: 70, height: 14),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoader(width: 60, height: 10),
                    const SizedBox(height: 6),
                    ShimmerLoader(width: 70, height: 14),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoader(width: 50, height: 10),
                    const SizedBox(height: 6),
                    ShimmerLoader(width: 70, height: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Shimmer list item placeholder
class ShimmerListItem extends StatelessWidget {
  const ShimmerListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ShimmerLoader(
            width: 40,
            height: 40,
            borderRadius: AppRadius.md,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoader(width: 120, height: 14),
                const SizedBox(height: 6),
                ShimmerLoader(width: 80, height: 11),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerLoader(width: 60, height: 14),
              const SizedBox(height: 6),
              ShimmerLoader(
                width: 44,
                height: 20,
                borderRadius: AppRadius.full,
              ),
            ],
          ),
        ],
      ),
    );
  }
}