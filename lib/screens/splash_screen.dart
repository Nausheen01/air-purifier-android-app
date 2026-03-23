// splas screen 

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const String _logoPath = 'assets/images/air_logo.png';

  late final AnimationController _introCtrl;
  late final AnimationController _rotateCtrl;
  late final AnimationController _dotsCtrl;

  Timer? _navTimer;
  bool _ready = false;

  @override
  void initState() {
    super.initState();

    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400), // smooth slow 360°
    );

    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _startAfterPrecache();
  }

  Future<void> _startAfterPrecache() async {
    // Wait one microtask so context is safe
    await Future<void>.delayed(Duration.zero);

    // ✅ Prevent 1–2s “hang”: preload image before animation begins
    await precacheImage(const AssetImage(_logoPath), context);

    if (!mounted) return;

    setState(() => _ready = true);

    _introCtrl.forward();
    _rotateCtrl.repeat();
    _dotsCtrl.repeat();

    // ✅ ONLY ONE navigation timer
    _navTimer?.cancel();
    _navTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _introCtrl.dispose();
    _rotateCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _introCtrl, curve: Curves.easeOut);
    final scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _introCtrl, curve: Curves.easeOutCubic),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF3FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ No background/glow behind logo
                  AnimatedBuilder(
                    animation: _rotateCtrl,
                    builder: (_, child) {
                      final angle = _ready
                          ? _rotateCtrl.value * 2 * math.pi
                          : 0.0;
                      return Transform.rotate(angle: angle, child: child);
                    },
                    child: Image.asset(
                      _logoPath,
                      width: 130,
                      height: 130,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Air Purify +',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: Color(0xFF0B4DA1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Clean Air, Healthy Life',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _LoadingDots(controller: _dotsCtrl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  final AnimationController controller;
  const _LoadingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final v = controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (v + i * 0.18) % 1.0;
            final active = phase < 0.5 ? phase / 0.5 : (1 - phase) / 0.5;
            final opacity = 0.35 + (active * 0.65);
            final scale = 0.85 + (active * 0.35);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B4DA1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
