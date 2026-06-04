import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() =>
      _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  int _selectedPlan = 2;
  bool _isAnnual = false;
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
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    0,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.profile),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.bg3,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.borderLight,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: AppColors.text2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Premium Plans',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text1,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Subtitle
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.sm,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  child: const Text(
                    'Unlock institutional-grade AI signals\nand automated trading',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.text2,
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              // Billing toggle
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isAnnual = false),
                        child: Text(
                          'Monthly',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: !_isAnnual
                                ? AppColors.text1
                                : AppColors.text3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isAnnual = !_isAnnual),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 44,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _isAnnual
                                ? AppColors.accent
                                : AppColors.bg4,
                            borderRadius: AppRadius.full,
                          ),
                          child: AnimatedAlign(
                            duration:
                                const Duration(milliseconds: 250),
                            alignment: _isAnnual
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 18,
                              height: 18,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isAnnual = true),
                        child: Row(
                          children: [
                            Text(
                              'Annual',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _isAnnual
                                    ? AppColors.text1
                                    : AppColors.text3,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.green
                                    .withOpacity(0.15),
                                borderRadius: AppRadius.full,
                              ),
                              child: const Text(
                                'Save 30%',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.green,
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

              // Plan cards
              SliverToBoxAdapter(
                child: _PlanCard(
                  planIndex: 0,
                  selectedPlan: _selectedPlan,
                  isAnnual: _isAnnual,
                  name: 'Starter',
                  monthlyPrice: 0,
                  color: AppColors.text2,
                  features: const [
                    _Feature('5 signals per day', true),
                    _Feature('Basic analytics', true),
                    _Feature('Market overview', true),
                    _Feature('AI confidence scoring', false),
                    _Feature('Auto-trading', false),
                    _Feature('VIP signal group', false),
                  ],
                  onSelect: () =>
                      setState(() => _selectedPlan = 0),
                ),
              ),

              SliverToBoxAdapter(
                child: _PlanCard(
                  planIndex: 1,
                  selectedPlan: _selectedPlan,
                  isAnnual: _isAnnual,
                  name: 'Pro',
                  monthlyPrice: 49,
                  color: AppColors.accent,
                  badge: 'Most Popular',
                  badgeColor: AppColors.accent,
                  features: const [
                    _Feature('Unlimited signals', true),
                    _Feature('AI confidence + SMC tags', true),
                    _Feature('Advanced analytics', true),
                    _Feature('Risk management tools', true),
                    _Feature('Priority notifications', true),
                    _Feature('Auto-trading bot', false),
                  ],
                  onSelect: () =>
                      setState(() => _selectedPlan = 1),
                ),
              ),

              SliverToBoxAdapter(
                child: _PlanCard(
                  planIndex: 2,
                  selectedPlan: _selectedPlan,
                  isAnnual: _isAnnual,
                  name: 'Elite',
                  monthlyPrice: 149,
                  color: AppColors.gold,
                  badge: 'Best Value',
                  badgeColor: AppColors.gold,
                  features: const [
                    _Feature('Everything in Pro', true),
                    _Feature('Automated MT4/MT5 trading', true),
                    _Feature('VIP signal group', true),
                    _Feature('Priority 1:1 support', true),
                    _Feature('Custom AI model tuning', true),
                    _Feature('Institutional research', true),
                  ],
                  onSelect: () =>
                      setState(() => _selectedPlan = 2),
                ),
              ),

              // CTA Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedPlan == 2
                                ? AppColors.gold
                                : AppColors.accent,
                            foregroundColor: _selectedPlan == 2
                                ? Colors.black
                                : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.md,
                            ),
                          ),
                          child: Text(
                            _selectedPlan == 0
                                ? 'Continue with Starter'
                                : _selectedPlan == 1
                                    ? 'Upgrade to Pro — \$${_isAnnual ? 34 : 49}/mo'
                                    : 'Upgrade to Elite — \$${_isAnnual ? 104 : 149}/mo',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Cancel anytime · No hidden fees · Instant access',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.text3,
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

// ─── Plan Card ────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final int planIndex;
  final int selectedPlan;
  final bool isAnnual;
  final String name;
  final int monthlyPrice;
  final Color color;
  final String? badge;
  final Color? badgeColor;
  final List<_Feature> features;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.planIndex,
    required this.selectedPlan,
    required this.isAnnual,
    required this.name,
    required this.monthlyPrice,
    required this.color,
    this.badge,
    this.badgeColor,
    required this.features,
    required this.onSelect,
  });

  bool get isSelected => planIndex == selectedPlan;

  double get price =>
      isAnnual ? monthlyPrice * 0.7 : monthlyPrice.toDouble();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.md,
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.06)
              : AppColors.bg2,
          borderRadius: AppRadius.xl,
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.4)
                : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan name + badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? color : AppColors.text1,
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor!.withOpacity(0.15),
                      borderRadius: AppRadius.full,
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  monthlyPrice == 0
                      ? 'Free'
                      : '\$${price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? color : AppColors.text1,
                    letterSpacing: -1,
                    fontFamily: 'monospace',
                  ),
                ),
                if (monthlyPrice > 0) ...[
                  const SizedBox(width: 4),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text(
                      '/ month',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.text2,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            if (isAnnual && monthlyPrice > 0) ...[
              const SizedBox(height: 2),
              Text(
                'Billed \$${(price * 12).toStringAsFixed(0)}/year',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.text3,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Features
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      f.included
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 16,
                      color: f.included
                          ? AppColors.green
                          : AppColors.text3,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      f.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: f.included
                            ? AppColors.text1
                            : AppColors.text3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature {
  final String label;
  final bool included;

  const _Feature(this.label, this.included);
}