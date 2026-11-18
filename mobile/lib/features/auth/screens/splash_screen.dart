import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_mobile/app/theme.dart';
import 'package:task_mobile/features/auth/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _haloPulse;
  late Animation<Offset> _mottoSlide;
  late Animation<double> _mottoFade;
  late Animation<double> _dotsFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Stage 1: Logo Scale & Fade
    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.40, curve: Curves.easeIn),
      ),
    );

    // Gentle ambient halo breathing
    _haloPulse = Tween<double>(begin: 0.8, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Stage 2: Motto Capsule Slide-Up & Fade
    _mottoSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.80, curve: Curves.easeOutCubic),
      ),
    );
    _mottoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.75, curve: Curves.easeIn),
      ),
    );

    // Stage 3: Executive 3-dot pulse fade
    _dotsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.70, 0.95, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Route transition once complete (extended to 4 seconds display)
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      final auth = ref.read(authProvider);
      final storage = ref.read(storageServiceProvider);
      final rememberMe = storage.getRememberMe();
      final hasFirebaseUser = FirebaseAuth.instance.currentUser != null;

      if ((auth.isAuthenticated || hasFirebaseUser) && rememberMe) {
        context.go('/dashboard');
      } else {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkCanvasBg : AppTheme.canvasBg,
      body: Stack(
        children: [
          // Ambient Mesh Radial Gradient Canvas
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.6, -0.6),
                  radius: 1.2,
                  colors: isDark
                      ? const [
                          Color(0x293E679B), // Subtle lifted slate blue glow
                          Colors.transparent,
                        ]
                      : const [
                          Color(0xFFEBF1F8), // Soft slate blue mist
                          Color(0xFFF7F8FA), // Airy off-white center
                        ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.7, 0.7),
                  radius: 1.0,
                  colors: isDark
                      ? const [
                          Color(0x0FFBE094), // Warm butter gold ambient glow
                          Colors.transparent,
                        ]
                      : const [
                          Color(0xFFFDF8EA), // Warm golden ambient glow
                          Colors.transparent,
                        ],
                ),
              ),
            ),
          ),

          // Central Animated Staged Content
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo with Ambient Glow
                    Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoFade.value,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ambient breathing halo behind logo
                            Transform.scale(
                              scale: _haloPulse.value,
                              child: Container(
                                width: 180,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.brandGold.withValues(alpha: isDark ? 0.20 : 0.35),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Brand Wordmark Logo inside dark container badge if dark mode
                            Container(
                              padding: isDark ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10) : EdgeInsets.zero,
                              decoration: isDark
                                  ? BoxDecoration(
                                      color: AppTheme.cardBg(context),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: AppTheme.cardBorder(context)),
                                      boxShadow: AppTheme.cardShadow(context),
                                    )
                                  : null,
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 230,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Motto Capsule: "✦ What are your Tasks?"
                    SlideTransition(
                      position: _mottoSlide,
                      child: Opacity(
                        opacity: _mottoFade.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg(context),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppTheme.cardBorder(context), width: 1.0),
                            boxShadow: AppTheme.cardShadow(context),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '✦ ',
                                style: TextStyle(
                                  color: Color(0xFFD9A014),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontFamily: 'Inter',
                                    color: AppTheme.textPrimary(context),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                  children: [
                                    const TextSpan(text: 'What are your '),
                                    TextSpan(
                                      text: 'Tasks?',
                                      style: TextStyle(
                                        color: AppTheme.accentBlue(context),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Bottom 3-dot pulse progress
          Positioned(
            bottom: 45,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _dotsFade,
              builder: (context, child) {
                return Opacity(
                  opacity: _dotsFade.value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPulsingDot(AppTheme.accentBlue(context), 0),
                      const SizedBox(width: 8),
                      _buildPulsingDot(AppTheme.brandGold, 200),
                      const SizedBox(width: 8),
                      _buildPulsingDot(AppTheme.accentBlue(context), 400),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingDot(Color color, int delayMs) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: color == AppTheme.brandGold
            ? Border.all(color: const Color(0xFFE5C368), width: 0.8)
            : null,
      ),
    );
  }
}
