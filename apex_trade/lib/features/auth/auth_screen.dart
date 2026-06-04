import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  bool _isSignIn = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    // Simulate network call
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      setState(() => _isLoading = false);
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Back button
                GestureDetector(
                  onTap: () => context.go(AppRoutes.onboarding),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.bg3,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: AppColors.text2,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Header
                Text(
                  _isSignIn ? 'Welcome\nback 👋' : 'Create\naccount',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text1,
                    letterSpacing: -1,
                    height: 1.15,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _isSignIn
                      ? 'Sign in to your APEX account'
                      : 'Start trading smarter today',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.text2,
                  ),
                ),

                const SizedBox(height: 36),

                // Toggle tabs
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.bg2,
                    borderRadius: AppRadius.md,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      _AuthTab(
                        label: 'Sign In',
                        isActive: _isSignIn,
                        onTap: () => setState(() => _isSignIn = true),
                      ),
                      _AuthTab(
                        label: 'Sign Up',
                        isActive: !_isSignIn,
                        onTap: () => setState(() => _isSignIn = false),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Email field
                _InputLabel(label: 'Email Address'),
                const SizedBox(height: 6),
                _ApexTextField(
                  controller: _emailController,
                  hint: 'trader@apex.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                ),

                const SizedBox(height: 16),

                // Name field (sign up only)
                if (!_isSignIn) ...[
                  _InputLabel(label: 'Full Name'),
                  const SizedBox(height: 6),
                  _ApexTextField(
                    hint: 'Alex Chen',
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                ],

                // Password field
                _InputLabel(label: 'Password'),
                const SizedBox(height: 6),
                _ApexTextField(
                  controller: _passwordController,
                  hint: '••••••••',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffix: GestureDetector(
                    onTap: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: AppColors.text3,
                    ),
                  ),
                ),

                // Forgot password
                if (_isSignIn) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // Main CTA button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.accent.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.md,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            _isSignIn ? 'Sign In' : 'Create Account',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.border,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or continue with',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.text3,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.border,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Social buttons
                Row(
                  children: [
                    Expanded(
                      child: _SocialButton(
                        label: 'Google',
                        icon: Icons.g_mobiledata_rounded,
                        onTap: _handleAuth,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SocialButton(
                        label: 'Apple',
                        icon: Icons.apple_rounded,
                        onTap: _handleAuth,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Terms
                Center(
                  child: Text(
                    'By continuing you agree to our Terms of Service\nand Privacy Policy',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.text3,
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────

class _AuthTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _AuthTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent : Colors.transparent,
            borderRadius: AppRadius.sm,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.text3,
            ),
          ),
        ),
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String label;

  const _InputLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.text3,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _ApexTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffix;

  const _ApexTextField({
    this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.text1,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 15,
          color: AppColors.text3,
        ),
        filled: true,
        fillColor: AppColors.bg2,
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                size: 18,
                color: AppColors.text3,
              )
            : null,
        suffixIcon: suffix != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffix,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.accent.withOpacity(0.5),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.bg2,
          borderRadius: AppRadius.md,
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.text1),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.text1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}