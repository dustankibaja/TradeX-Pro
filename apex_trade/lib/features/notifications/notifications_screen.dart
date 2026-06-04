import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<_NotifData> _notifications = [
    _NotifData(
      icon: '⚡',
      iconBg: AppColors.green,
      title: 'New Signal: XAUUSD BUY',
      body: 'Entry 2,318.40 · TP 2,334 · AI confidence 87%',
      time: '2 minutes ago',
      isUnread: true,
      category: 'Signal',
    ),
    _NotifData(
      icon: '🏆',
      iconBg: AppColors.gold,
      title: 'TP1 Hit — EURUSD SELL',
      body: '+\$78.20 profit secured. TP2 still active.',
      time: '24 minutes ago',
      isUnread: true,
      category: 'Trade',
      bodyColor: AppColors.green,
    ),
    _NotifData(
      icon: '📊',
      iconBg: AppColors.accent,
      title: 'London Session Open',
      body: 'High volatility expected. 3 setups in watch list.',
      time: '1 hour ago',
      isUnread: true,
      category: 'Session',
    ),
    _NotifData(
      icon: '⚡',
      iconBg: AppColors.green,
      title: 'Signal Closed — GBPJPY BUY',
      body: 'TP2 hit. Total: +\$374 · +2.8R',
      time: '3 hours ago',
      isUnread: false,
      category: 'Signal',
      bodyColor: AppColors.green,
    ),
    _NotifData(
      icon: '⚠️',
      iconBg: AppColors.red,
      title: 'Risk Alert — USDJPY',
      body: 'Position moved to breakeven. Market volatile.',
      time: '5 hours ago',
      isUnread: false,
      category: 'Alert',
    ),
    _NotifData(
      icon: '📈',
      iconBg: AppColors.accent,
      title: 'Weekly Performance Ready',
      body: 'Your weekly report is ready. Win rate: 73.4%',
      time: 'Yesterday',
      isUnread: false,
      category: 'Report',
    ),
    _NotifData(
      icon: '⚡',
      iconBg: AppColors.green,
      title: 'New Signal: EURUSD SELL',
      body: 'Entry 1.0861 · TP 1.0820 · AI confidence 75%',
      time: 'Yesterday',
      isUnread: false,
      category: 'Signal',
    ),
    _NotifData(
      icon: '🎯',
      iconBg: AppColors.gold,
      title: 'Monthly Goal Reached!',
      body: 'You have hit your +20% monthly target. Keep going!',
      time: '2 days ago',
      isUnread: false,
      category: 'Achievement',
    ),
  ];

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

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isUnread = false;
      }
    });
  }

  List<_NotifData> get _unread =>
      _notifications.where((n) => n.isUnread).toList();
  List<_NotifData> get _read =>
      _notifications.where((n) => !n.isUnread).toList();

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
                  AppSpacing.lg,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (_unread.isNotEmpty)
                      GestureDetector(
                        onTap: _markAllRead,
                        child: const Text(
                          'Mark all read',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Unread section
                    if (_unread.isNotEmpty) ...[
                      _SectionLabel(
                        label: 'New · ${_unread.length}',
                      ),
                      ..._unread.asMap().entries.map(
                        (e) => _NotifItem(
                          data: e.value,
                          index: e.key,
                          onTap: () => setState(
                            () => e.value.isUnread = false,
                          ),
                        ),
                      ),
                    ],

                    // Read section
                    if (_read.isNotEmpty) ...[
                      _SectionLabel(label: 'Earlier'),
                      ..._read.asMap().entries.map(
                        (e) => _NotifItem(
                          data: e.value,
                          index: e.key,
                          onTap: () {},
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
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

// ─── Section Label ────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.text3,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Notification Item ────────────────────────────────────────

class _NotifItem extends StatefulWidget {
  final _NotifData data;
  final int index;
  final VoidCallback onTap;

  const _NotifItem({
    required this.data,
    required this.index,
    required this.onTap,
  });

  @override
  State<_NotifItem> createState() => _NotifItemState();
}

class _NotifItemState extends State<_NotifItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slide = Tween(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(
      Duration(milliseconds: widget.index * 50),
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
    final data = widget.data;

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: data.isUnread
                ? AppColors.accent.withOpacity(0.03)
                : Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: data.iconBg.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      data.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: data.isUnread
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: AppColors.text1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          data.body,
                          style: TextStyle(
                            fontSize: 12,
                            color: data.bodyColor ??
                                AppColors.text2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: data.iconBg
                                    .withOpacity(0.1),
                                borderRadius: AppRadius.full,
                              ),
                              child: Text(
                                data.category,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: data.iconBg,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              data.time,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.text3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Unread dot
                  if (data.isUnread)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
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

// ─── Data class ───────────────────────────────────────────────

class _NotifData {
  final String icon;
  final Color iconBg;
  final String title;
  final String body;
  final String time;
  bool isUnread;
  final String category;
  final Color? bodyColor;

  _NotifData({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.body,
    required this.time,
    required this.isUnread,
    required this.category,
    this.bodyColor,
  });
}