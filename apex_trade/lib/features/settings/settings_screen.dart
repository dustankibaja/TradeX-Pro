import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  // Toggle states
  bool _autoTrading = true;
  bool _newSignals = true;
  bool _tpSlAlerts = true;
  bool _sessionReminders = false;
  bool _marketNews = true;
  bool _emailNotifs = false;
  bool _twoFactor = false;
  bool _biometrics = true;
  bool _darkMode = true;

  // Risk settings
  double _riskPercent = 2.0;
  double _minConfidence = 75.0;

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
                    AppSpacing.xl,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            context.go(AppRoutes.profile),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.bg3,
                            borderRadius:
                                BorderRadius.circular(10),
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
                        'Settings',
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

              // Trading section
              SliverToBoxAdapter(
                child: _SettingsSection(
                  title: 'Trading',
                  children: [
                    _ToggleItem(
                      icon: Icons.smart_toy_rounded,
                      iconBg: AppColors.green,
                      title: 'Auto-Trading',
                      subtitle: 'Execute signals automatically',
                      value: _autoTrading,
                      onChanged: (v) =>
                          setState(() => _autoTrading = v),
                    ),
                    _SliderItem(
                      icon: Icons.shield_rounded,
                      iconBg: AppColors.red,
                      title: 'Risk Per Trade',
                      subtitle:
                          'Max ${_riskPercent.toStringAsFixed(1)}% account risk',
                      value: _riskPercent,
                      min: 0.5,
                      max: 5.0,
                      divisions: 9,
                      color: AppColors.red,
                      valueLabel:
                          '${_riskPercent.toStringAsFixed(1)}%',
                      onChanged: (v) =>
                          setState(() => _riskPercent = v),
                    ),
                    _SliderItem(
                      icon: Icons.bolt_rounded,
                      iconBg: AppColors.gold,
                      title: 'Min AI Confidence',
                      subtitle:
                          'Only show signals above ${_minConfidence.toInt()}%',
                      value: _minConfidence,
                      min: 50,
                      max: 95,
                      divisions: 9,
                      color: AppColors.gold,
                      valueLabel: '${_minConfidence.toInt()}%',
                      onChanged: (v) =>
                          setState(() => _minConfidence = v),
                    ),
                  ],
                ),
              ),

              // Notifications section
              SliverToBoxAdapter(
                child: _SettingsSection(
                  title: 'Notifications',
                  children: [
                    _ToggleItem(
                      icon: Icons.bolt_rounded,
                      iconBg: AppColors.accent,
                      title: 'New Signals',
                      subtitle: 'Get alerted on new signals',
                      value: _newSignals,
                      onChanged: (v) =>
                          setState(() => _newSignals = v),
                    ),
                    _ToggleItem(
                      icon: Icons.flag_rounded,
                      iconBg: AppColors.green,
                      title: 'TP / SL Hit Alerts',
                      subtitle: 'When targets are reached',
                      value: _tpSlAlerts,
                      onChanged: (v) =>
                          setState(() => _tpSlAlerts = v),
                    ),
                    _ToggleItem(
                      icon: Icons.access_time_rounded,
                      iconBg: AppColors.gold,
                      title: 'Session Reminders',
                      subtitle: 'London, NY, Tokyo opens',
                      value: _sessionReminders,
                      onChanged: (v) =>
                          setState(() => _sessionReminders = v),
                    ),
                    _ToggleItem(
                      icon: Icons.newspaper_rounded,
                      iconBg: AppColors.accent2,
                      title: 'Market News',
                      subtitle: 'High impact news events',
                      value: _marketNews,
                      onChanged: (v) =>
                          setState(() => _marketNews = v),
                    ),
                    _ToggleItem(
                      icon: Icons.email_rounded,
                      iconBg: AppColors.text2,
                      title: 'Email Notifications',
                      subtitle: 'Weekly performance reports',
                      value: _emailNotifs,
                      onChanged: (v) =>
                          setState(() => _emailNotifs = v),
                    ),
                  ],
                ),
              ),

              // Security section
              SliverToBoxAdapter(
                child: _SettingsSection(
                  title: 'Security',
                  children: [
                    _ToggleItem(
                      icon: Icons.lock_rounded,
                      iconBg: AppColors.accent,
                      title: 'Two-Factor Auth',
                      subtitle: 'Extra layer of security',
                      value: _twoFactor,
                      onChanged: (v) =>
                          setState(() => _twoFactor = v),
                    ),
                    _ToggleItem(
                      icon: Icons.fingerprint_rounded,
                      iconBg: AppColors.green,
                      title: 'Biometric Login',
                      subtitle: 'Face ID / Fingerprint',
                      value: _biometrics,
                      onChanged: (v) =>
                          setState(() => _biometrics = v),
                    ),
                    _TapItem(
                      icon: Icons.key_rounded,
                      iconBg: AppColors.gold,
                      title: 'Change Password',
                      subtitle: 'Last changed 30 days ago',
                      onTap: () {},
                    ),
                    _TapItem(
                      icon: Icons.devices_rounded,
                      iconBg: AppColors.accent2,
                      title: 'Active Sessions',
                      subtitle: '2 devices logged in',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              // Appearance section
              SliverToBoxAdapter(
                child: _SettingsSection(
                  title: 'Appearance',
                  children: [
                    _ToggleItem(
                      icon: Icons.dark_mode_rounded,
                      iconBg: AppColors.text2,
                      title: 'Dark Mode',
                      subtitle: 'Always on for best experience',
                      value: _darkMode,
                      onChanged: (v) =>
                          setState(() => _darkMode = v),
                    ),
                    _TapItem(
                      icon: Icons.palette_rounded,
                      iconBg: AppColors.accent,
                      title: 'Accent Color',
                      subtitle: 'Blue (Default)',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              // Data section
              SliverToBoxAdapter(
                child: _SettingsSection(
                  title: 'Data & Privacy',
                  children: [
                    _TapItem(
                      icon: Icons.download_rounded,
                      iconBg: AppColors.green,
                      title: 'Export Trade Data',
                      subtitle: 'Download as CSV or PDF',
                      onTap: () {},
                    ),
                    _TapItem(
                      icon: Icons.privacy_tip_rounded,
                      iconBg: AppColors.accent,
                      title: 'Privacy Policy',
                      subtitle: 'Last updated Jan 2025',
                      onTap: () {},
                    ),
                    _TapItem(
                      icon: Icons.description_rounded,
                      iconBg: AppColors.text2,
                      title: 'Terms of Service',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              // Danger zone
              SliverToBoxAdapter(
                child: _SettingsSection(
                  title: 'Danger Zone',
                  children: [
                    _TapItem(
                      icon: Icons.logout_rounded,
                      iconBg: AppColors.red,
                      title: 'Sign Out',
                      titleColor: AppColors.red,
                      onTap: () =>
                          context.go(AppRoutes.auth),
                    ),
                    _TapItem(
                      icon: Icons.delete_forever_rounded,
                      iconBg: AppColors.red,
                      title: 'Delete Account',
                      titleColor: AppColors.red,
                      subtitle: 'This action cannot be undone',
                      onTap: () {},
                    ),
                  ],
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

// ─── Settings Section ─────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
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
              children: children.asMap().entries.map((e) {
                final isLast = e.key == children.length - 1;
                return Column(
                  children: [
                    e.value,
                    if (!isLast)
                      Container(
                        height: 1,
                        margin:
                            const EdgeInsets.only(left: 56),
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

// ─── Toggle Item ──────────────────────────────────────────────

class _ToggleItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleItem({
    required this.icon,
    required this.iconBg,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: iconBg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text1,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.text3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: value
                    ? AppColors.accent
                    : AppColors.bg4,
                borderRadius: AppRadius.full,
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                alignment: value
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Slider Item ──────────────────────────────────────────────

class _SliderItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color color;
  final String valueLabel;
  final ValueChanged<double> onChanged;

  const _SliderItem({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.color,
    required this.valueLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBg.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: iconBg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text1,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.text3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: AppRadius.full,
                ),
                child: Text(
                  valueLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: AppColors.bg4,
              thumbColor: color,
              overlayColor: color.withOpacity(0.1),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 7,
              ),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tap Item ─────────────────────────────────────────────────

class _TapItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final Color? titleColor;
  final String? subtitle;
  final VoidCallback onTap;

  const _TapItem({
    required this.icon,
    required this.iconBg,
    required this.title,
    this.titleColor,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBg.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 16, color: iconBg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? AppColors.text1,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.text3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (titleColor == null)
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