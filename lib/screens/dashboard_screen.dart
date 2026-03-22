// =============================
// PREMIUM AIR PURIFIER DASHBOARD (YOUR SAME DESIGN)
// ✅ FINAL: Bottom nav REMOVED (AppShell handles nav)
// File: lib/screens/dashboard_screen.dart
// =============================

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/animated_aqi_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  // --- states
  bool powerOn = true;
  int fanSpeed = 2; // 0 low, 1 medium, 2 high

  // --- AQI auto values
  int aqi = 76;
  int previousAqi = 82;
  int pm25 = 117;

  Timer? _aqiTimer;

  // --- static metrics
  final int temperature = 22;
  final int humidity = 55;
  final int filterLife = 65; // ✅ static always

  // --- rotations (power + fan)
  late final AnimationController _powerRotate;
  late final AnimationController _fanRotate;

  @override
  void initState() {
    super.initState();

    _powerRotate = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fanRotate = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _syncRotationsWithPower();
    _startAutoAqi();
  }

  void _syncRotationsWithPower() {
    if (powerOn) {
      _powerRotate.repeat();
      _fanRotate.repeat();
    } else {
      _powerRotate.stop();
      _fanRotate.stop();
    }
  }

  void _startAutoAqi() {
    final rnd = Random();
    _aqiTimer?.cancel();

    _aqiTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      final nextAqi = (aqi + (rnd.nextInt(15) - 7)).clamp(10, 200);
      final nextPm25 = (pm25 + (rnd.nextInt(21) - 10)).clamp(5, 150);

      setState(() {
        previousAqi = aqi;
        aqi = nextAqi;
        pm25 = nextPm25;
      });
    });
  }

  @override
  void dispose() {
    _aqiTimer?.cancel();
    _powerRotate.dispose();
    _fanRotate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),

      // ✅ IMPORTANT: NO bottomNavigationBar here anymore
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 16),

                AnimatedAqiCard(
                  aqi: aqi,
                  pm25: pm25,
                  previousAqi: previousAqi,
                ),

                const SizedBox(height: 18),
                _metricsRow(),

                const SizedBox(height: 20),
                _powerControl(),

                const SizedBox(height: 16),
                _fanControl(),

                const SizedBox(height: 18),
                _proTip(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your air quality overview',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.black.withOpacity(0.50),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ---------------- METRICS ----------------
  Widget _metricsRow() {
    return Row(
      children: [
        _metricCard(
          value: '$temperature°C',
          label: 'TEMPERATURE',
          icon: 'assets/icons/thermometer-simple.svg',
          color: const Color(0xFFFF7A1A),
        ),
        _metricCard(
          value: '$humidity%',
          label: 'HUMIDITY',
          icon: 'assets/icons/drop-simple.svg',
          color: const Color(0xFF1D5CFF),
        ),
        _metricCard(
          value: '$filterLife%',
          label: 'FILTER LIFE',
          icon: 'assets/icons/pulse.svg',
          color: const Color(0xFF6C63FF),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String value,
    required String label,
    required String icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        height: 132,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 22,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.75)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  height: 22,
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Colors.black.withOpacity(0.45),
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- POWER CONTROL ----------------
  Widget _powerControl() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B7CFA),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5B7CFA).withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/lightning.svg',
                    height: 18,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Power Control',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: powerOn
                          ? const [Color(0xFF4F6BFF), Color(0xFF7B61FF)]
                          : [Colors.grey.shade300, Colors.grey.shade400],
                    ),
                    boxShadow: powerOn
                        ? [
                            BoxShadow(
                              color: const Color(0xFF5B7CFA).withOpacity(0.25),
                              blurRadius: 22,
                              offset: const Offset(0, 14),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: RotationTransition(
                      turns: _powerRotate,
                      child: SvgPicture.asset(
                        'assets/icons/power.svg',
                        height: 22,
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Air Purifier',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        powerOn ? '• Running' : '• Off',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: powerOn ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: powerOn,
                  activeColor: const Color(0xFF5B7CFA),
                  onChanged: (v) {
                    setState(() {
                      powerOn = v;
                      _syncRotationsWithPower();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- FAN CONTROL ----------------
  Widget _fanControl() {
    final labels = ['Low', 'Medium', 'High'];

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: powerOn ? 1.0 : 0.55,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: powerOn ? Colors.white : const Color(0xFFEDEFF5),
          borderRadius: BorderRadius.circular(26),
          boxShadow: powerOn
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Row(
              children: [
                RotationTransition(
                  turns: _fanRotate,
                  child: Icon(
                    Icons.air,
                    color: powerOn
                        ? Colors.black.withOpacity(0.55)
                        : Colors.grey.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Fan Speed',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
                Text(
                  labels[fanSpeed],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: powerOn ? const Color(0xFF5B7CFA) : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            IgnorePointer(
              ignoring: !powerOn,
              child: Row(
                children: List.generate(3, (i) {
                  final selected = fanSpeed == i;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => fanSpeed = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: selected && powerOn
                              ? const LinearGradient(
                                  colors: [Color(0xFF4F6BFF), Color(0xFF7B61FF)],
                                )
                              : null,
                          color: selected
                              ? (powerOn ? null : Colors.grey.shade300)
                              : (powerOn ? Colors.grey.shade200 : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: selected && powerOn
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 18,
                                    offset: const Offset(0, 12),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            labels[i],
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              color: selected && powerOn
                                  ? Colors.white
                                  : Colors.black.withOpacity(0.45),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- PRO TIP ----------------
  Widget _proTip() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B7CFA), Color(0xFF7B61FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B7CFA).withOpacity(0.22),
            blurRadius: 26,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 2),
          Text("✨", style: GoogleFonts.inter(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pro Tip\nRun your air purifier for 30–60 minutes before sleeping for optimal air quality during rest.',
              style: GoogleFonts.inter(
                color: Colors.white,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// change the Aqi bar
