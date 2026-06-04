import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
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
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
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
              // Hero section
              SliverToBoxAdapter(
                child: _ProfileHero(),
              ),

              // Stats row
              SliverToBoxAdapter(
                child: _ProfileStats(),
              ),

              // Menu sections
              SliverToBoxAdapter(
                child: _MenuSection(
                  title: 'Account',
                  items: [
                    _MenuItem(
                      icon: '⚡',
                      iconBg: AppColors.gold,
                      title: 'Subscription',
                      subtitle: 'Elite Plan — Active',
                      subtitleColor: AppColors.gold,
                      onTap: () =>
                          context.go(AppRoutes.subscription),
                    ),
                    _MenuItem(
                      icon: '📊',
                      iconBg: AppColors.accent,
                      title: 'Trade History',
                      subtitle: '47 trades this month',
                      onTap: () =>
                          context.go(AppRoutes.history),
                    ),
                    _MenuItem(
                      icon: '🔗',
                      iconBg: AppColors.green,
                      title: 'Connected Brokers',
                      subtitle: 'MT5 — Connected',
                      subtitleColor: AppColors.green,
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: '📱',
                      iconBg: AppColors.accent2,
                      title: 'Linked Devices',
                      subtitle: '2 devices active',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: _MenuSection(
                  title: 'Preferences',
                  items: [
                    _MenuItem(
                      icon: '⚙️',
                      iconBg: AppColors.text3,
                      title: 'Settings',
                      subtitle: 'Notifications, security',
                      onTap: () =>
                          context.go(AppRoutes.settings),
                    ),
                    _MenuItem(
                      icon: '🎨',
                      iconBg: AppColors.accent,
                      title: 'Appearance',
                      subtitle: 'Dark mode — On',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: '🌐',
                      iconBg: AppColors.green,
                      title: 'Language',
                      subtitle: 'English (US)',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: _MenuSection(
                  title: 'Support',
                  items: [
                    _MenuItem(
                      icon: '💬',
                      iconBg: AppColors.accent,
                      title: 'Help Center',
                      subtitle: 'FAQs and guides',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: '📧',
                      iconBg: AppColors.green,
                      title: 'Contact Support',
                      subtitle: 'support@apextrade.io',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: '⭐',
                      iconBg: AppColors.gold,
                      title: 'Rate the App',
                      subtitle: 'Leave us a review',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: _MenuSection(
                  title: 'Danger Zone',
                  items: [
                    _MenuItem(
                      icon: '🚪',
                      iconBg: AppColors.red,
                      title: 'Sign Out',
                      titleColor: AppColors.red,
                      onTap: () =>
                          context.go(AppRoutes.auth),
                    ),
                  ],
                ),
              ),

              // Version
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Text(
                      'APEX TRADE v1.0.0 — Phase 1 MVP\nBuilt with ❤️ for institutional traders',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.text3,
                        height: 1.6,
                      ),
                    ),
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

// ─── Profile Hero ─────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.accent.withOpacity(0.08),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, Color(0xFF6C63FF)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.4),
                    width: 3,
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'AC',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.bg0,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Text(
            'Alex Chen',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.text1,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'alex.chen@gmail.com',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.text2,
            ),
          ),

          const SizedBox(height: 12),

          // Elite badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gold.withOpacity(0.2),
                  AppColors.gold.withOpacity(0.1),
                ],
              ),
              borderRadius: AppRadius.full,
              border: Border.all(
                color: AppColors.gold.withOpacity(0.3),
              ),
            ),
            child: const Text(
              '⚡ ELITE TRADER',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Stats ────────────────────────────────────────────

class _ProfileStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            value: '847',
            label: 'Signals',
            color: AppColors.text1,
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.border,
          ),
          _StatItem(
            value: '73.4%',
            label: 'Win Rate',
            color: AppColors.green,
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.border,
          ),
          _StatItem(
            value: '\$24.8K',
            label: 'Portfolio',
            color: AppColors.gold,
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.border,
          ),
          _StatItem(
            value: '1.82R',
            label: 'Avg RR',
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
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
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.text3,
          ),
        ),
      ],
    );
  }
}

// ─── Menu Section ─────────────────────────────────────────────

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: AppSpacing.sm,
              left: 2,
            ),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.text3,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: AppRadius.lg,
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: items.asMap().entries.map((e) {
                final isLast = e.key == items.length - 1;
                return Column(
                  children: [
                    _MenuItemWidget(item: e.value),
                    if (!isLast)
                      Container(
                        height: 1,
                        margin: const EdgeInsets.only(left: 56),
                        color: AppColors.border,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final String icon;
  final Color iconBg;
  final String title;
  final Color? titleColor;
  final String? subtitle;
  final Color? subtitleColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.title,
    this.titleColor,
    this.subtitle,
    this.subtitleColor,
    required this.onTap,
  });
}

class _MenuItemWidget extends StatelessWidget {
  final _MenuItem item;

  const _MenuItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.iconBg.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Text(
                item.icon,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: item.titleColor ?? AppColors.text1,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      item.subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: item.subtitleColor ??
                            AppColors.text3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.titleColor == null)
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.text3,
              ),
          ],
        ),
      ),
    );
  }
}