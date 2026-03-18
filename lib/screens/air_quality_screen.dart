import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AirQualityScreen extends StatefulWidget {
  const AirQualityScreen({super.key});

  @override
  State<AirQualityScreen> createState() => _AirQualityScreenState();
}

class _AirQualityScreenState extends State<AirQualityScreen>
    with TickerProviderStateMixin {
  // ---- Demo values (replace with API/sensor in real app) ----
  int aqi = 105; // PM2.5 main number
  final math.Random _rand = math.Random();
  late Timer _timer;

  // Used for chart pulse + shiny bars shimmer
  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();

    // Simulate AQI changing like your video
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      final delta = _rand.nextBool() ? 1 : -1;
      setState(() {
        aqi = (aqi + delta).clamp(20, 220);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ------------------- AQI helpers -------------------
  _AqiMeta metaForAqi(int value) {
    if (value <= 50) {
      return _AqiMeta(
        label: "Good",
        pillColor: const Color(0xFF2563EB),
        accent: const Color(0xFF2563EB),
        message: "Air is clean. Enjoy your day!",
      );
    } else if (value <= 100) {
      return _AqiMeta(
        label: "Moderate",
        pillColor: const Color(0xFFF59E0B),
        accent: const Color(0xFFFF8A00),
        message: "Sensitive groups should take care outdoors.",
      );
    } else if (value <= 150) {
      return _AqiMeta(
        label: "Unhealthy",
        pillColor: const Color(0xFFEF4444),
        accent: const Color(0xFFEF4444),
        // ✅ Full sentence (not cut)
        message:
            "Health alert: everyone may experience more serious health effects.",
      );
    } else {
      return _AqiMeta(
        label: "Very Unhealthy",
        pillColor: const Color(0xFF7F1D1D),
        accent: const Color(0xFF7F1D1D),
        message: "Avoid outdoor activity. Keep purifier running high.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = metaForAqi(aqi);

    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      body: SafeArea(
        child: Stack(
          children: [
            // subtle background gradient
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFEAF2FF),
                      Color(0xFFF6F9FF),
                      Color(0xFFEFF6FF),
                    ],
                  ),
                ),
              ),
            ),

            Column(
              children: [
                const SizedBox(height: 10),

                // ✅ (1) Title MUST be left aligned
                _topHeader(),

                const SizedBox(height: 14),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    // Keep extra bottom space for AppShell bottom nav
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
                    child: Column(
                      children: [
                        _overallStatusCard(m),
                        const SizedBox(height: 16),
                        _pollutantLevelsCard(m),
                        const SizedBox(height: 16),
                        _historyCard(m),
                        const SizedBox(height: 14),
                        _tempHumidityRow(),
                        const SizedBox(height: 16),
                        _healthRecommendationsCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------- HEADER -------------------

  Widget _topHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Air Quality Monitor",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Real-time pollutant analysis",
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------- OVERALL STATUS -------------------

  Widget _overallStatusCard(_AqiMeta m) {
    return _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Overall Status",
                style: GoogleFonts.poppins(
                  fontSize: 12.8,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: m.pillColor,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: m.pillColor.withAlpha(90),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  m.label,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ✅ (2)(6) Number + unit inside card, PM2.5 label inside card (bottom-left)
          AnimatedContainer(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  m.accent.withAlpha(190),
                  m.accent,
                  m.accent.withAlpha(235),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: m.accent.withAlpha(70),
                  blurRadius: 24,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number + µg/m³ (unit in right corner like screenshot)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeOutCubic,
                        transitionBuilder: (child, anim) {
                          return ScaleTransition(
                            scale: Tween<double>(begin: 0.92, end: 1.0)
                                .animate(anim),
                            child: FadeTransition(opacity: anim, child: child),
                          );
                        },
                        child: Text(
                          "$aqi",
                          key: ValueKey(aqi),
                          style: GoogleFonts.poppins(
                            fontSize: 56,
                            height: 1.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        "µg/m³",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withAlpha(235),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "PM2.5 Particle Level",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withAlpha(230),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ✅ (7) full statement (not cut)
          Text(
            m.message,
            softWrap: true,
            style: GoogleFonts.poppins(
              fontSize: 11.8,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------- POLLUTANTS -------------------

  Widget _pollutantLevelsCard(_AqiMeta m) {
    final items = <_Pollutant>[
      _Pollutant(
        leftText: "2.5",
        title: "PM2.5",
        sub: "FINE PARTICLES",
        value: aqi,
        unit: "µg/m³",
        status: m.label,
        statusColor: m.pillColor,
        fillColor: m.accent,
        max: 200,
      ),
      _Pollutant(
        leftText: "10",
        title: "PM10",
        sub: "COARSE PARTICLES",
        value: (aqi + 39).clamp(10, 260),
        unit: "µg/m³",
        status: "Moderate",
        statusColor: const Color(0xFFF59E0B),
        fillColor: const Color(0xFFFF8A00),
        max: 300,
      ),
      _Pollutant(
        leftText: "O₃",
        title: "O₃",
        sub: "OZONE",
        value: (aqi - 24).clamp(10, 200),
        unit: "ppb",
        status: m.label,
        statusColor: m.pillColor,
        fillColor: m.accent,
        max: 200,
      ),
      _Pollutant(
        leftText: "CO",
        title: "CO",
        sub: "CARBON MONOXIDE",
        value: 12 + (aqi % 5),
        unit: "ppm",
        status: "Good",
        statusColor: const Color(0xFF2563EB),
        fillColor: const Color(0xFF2563EB),
        max: 30,
      ),
      _Pollutant(
        leftText: "NO₂",
        title: "NO₂",
        sub: "NITROGEN DIOXIDE",
        value: 35 + (aqi % 12),
        unit: "ppb",
        status: "Good",
        statusColor: const Color(0xFF2563EB),
        fillColor: const Color(0xFF2563EB),
        max: 120,
      ),
      _Pollutant(
        leftText: "SO₂",
        title: "SO₂",
        sub: "SULFUR DIOXIDE",
        value: 20 + (aqi % 4),
        unit: "ppb",
        status: "Good",
        statusColor: const Color(0xFF2563EB),
        fillColor: const Color(0xFF2563EB),
        max: 80,
      ),
    ];

    return _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ (3) Pollutant Levels left icon like screenshot: blue circle + bolt
          Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withAlpha(70),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: const Icon(Icons.bolt, color: Colors.white, size: 17),
              ),
              const SizedBox(width: 10),
              Text(
                "Pollutant Levels",
                style: GoogleFonts.poppins(
                  fontSize: 13.4,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Column(
            children: items
                .map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _pollutantTile(p),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _pollutantTile(_Pollutant p) {
    final progress = (p.value / p.max).clamp(0.0, 1.0);

    // ✅ (4) tinted / blur-like background per pollutant
    final tintA = p.fillColor.withAlpha(28);
    final tintB = p.fillColor.withAlpha(14);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tintA, tintB],
        ),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(14),
            blurRadius: 18,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Left “2.5 / 10 / O3 …” block
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: p.fillColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: p.fillColor.withAlpha(70),
                      blurRadius: 18,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    p.leftText,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.title,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.sub,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Right value
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: Text(
                      "${p.value}",
                      key: ValueKey("${p.title}_${p.value}"),
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: p.fillColor,
                      ),
                    ),
                  ),
                  Text(
                    p.unit,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _ShinyProgressBar(
                  progress: progress,
                  color: p.fillColor,
                  pulse: _pulseCtrl,
                ),
              ),
              const SizedBox(width: 10),

              // status pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: p.statusColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: p.statusColor.withAlpha(45)),
                ),
                child: Text(
                  p.status,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: p.statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ (5) Shiny progress bar like your video
  // Gradient + moving highlight
  // ---------------------------------------------------
  // HISTORY
  // ---------------------------------------------------

  Widget _historyCard(_AqiMeta m) {
    final List<double> points = List.generate(8, (i) {
      final base = aqi.toDouble();
      final v = base - 18 + (i * 4) + (math.sin(i.toDouble()) * 8);
      return v.clamp(20.0, 220.0).toDouble();
    });

    return _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "24-Hour PM2.5 History",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              Opacity(
                opacity: 0.65,
                child: SvgPicture.asset(
                  "assets/icons/wave.svg",
                  height: 18,
                  width: 18,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF64748B),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 170,
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(210),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) {
                      return CustomPaint(
                        painter: _HistoryPainter(
                          points: points,
                          accent: m.accent,
                          pulse: _pulseCtrl.value,
                        ),
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _TimeLabel("00:00"),
                        _TimeLabel("04:00"),
                        _TimeLabel("08:00"),
                        _TimeLabel("12:00"),
                        _TimeLabel("16:00"),
                        _TimeLabel("20:00"),
                        _TimeLabel("Now"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // TEMP + HUMIDITY
  // ---------------------------------------------------

  Widget _tempHumidityRow() {
    return Row(
      children: [
        Expanded(
          child: _miniMetricCard(
            iconBg: const Color(0xFFFF8A00),
            icon: Icons.thermostat,
            title: "TEMPERATURE",
            value: "22°C",
            barColor: const Color(0xFFFF8A00),
            fill: 0.55,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _miniMetricCard(
            iconBg: const Color(0xFF2563EB),
            icon: Icons.water_drop,
            title: "HUMIDITY",
            value: "55%",
            barColor: const Color(0xFF2563EB),
            fill: 0.55,
          ),
        ),
      ],
    );
  }

  Widget _miniMetricCard({
    required Color iconBg,
    required IconData icon,
    required String title,
    required String value,
    required Color barColor,
    required double fill,
  }) {
    return _softCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: iconBg.withAlpha(70),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                )
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: fill,
                      child: Container(
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // HEALTH RECOMMENDATIONS
  // ---------------------------------------------------

  Widget _healthRecommendationsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2563EB),
            Color(0xFF5B21B6),
            Color(0xFF7C3AED),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 30,
            offset: const Offset(0, 18),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                "Health Recommendations",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _recoPill("Avoid prolonged outdoor activities", Icons.circle),
          const SizedBox(height: 10),
          _recoPill("Keep windows closed when outdoor air quality is poor",
              Icons.air),
          const SizedBox(height: 10),
          _recoPill("Run purifier on high speed for faster air cleaning",
              Icons.show_chart),
        ],
      ),
    );
  }

  Widget _recoPill(String text, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(36),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white.withAlpha(230)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                height: 1.25,
                fontWeight: FontWeight.w800,
                color: Colors.white.withAlpha(240),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------- SHARED CARD STYLE -------------------

  Widget _softCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(150),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(190)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(18),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ------------------- SHINY BAR WIDGET -------------------

class _ShinyProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final AnimationController pulse;

  const _ShinyProgressBar({
    required this.progress,
    required this.color,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 9,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth * progress;

          return Stack(
            children: [
              // Base fill with gradient
              AnimatedContainer(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                width: w,
                height: 9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      color.withAlpha(230),
                      color,
                      color.withAlpha(210),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(70),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),

              // Moving shiny highlight
              if (w > 18)
                AnimatedBuilder(
                  animation: pulse,
                  builder: (_, __) {
                    final t = pulse.value; // 0..1
                    final shineX = (w - 24) * t;

                    return Positioned(
                      left: shineX,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withAlpha(0),
                              Colors.white.withAlpha(140),
                              Colors.white.withAlpha(0),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

// ------------------- SMALL WIDGETS & MODELS -------------------

class _TimeLabel extends StatelessWidget {
  final String text;
  const _TimeLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF94A3B8),
      ),
    );
  }
}

class _AqiMeta {
  final String label;
  final Color pillColor;
  final Color accent;
  final String message;

  _AqiMeta({
    required this.label,
    required this.pillColor,
    required this.accent,
    required this.message,
  });
}

class _Pollutant {
  final String leftText;
  final String title;
  final String sub;
  final int value;
  final String unit;
  final String status;
  final Color statusColor;
  final Color fillColor;
  final double max;

  _Pollutant({
    required this.leftText,
    required this.title,
    required this.sub,
    required this.value,
    required this.unit,
    required this.status,
    required this.statusColor,
    required this.fillColor,
    required this.max,
  });
}

/// Draws the “arches/bars” look at the bottom of the chart area
class _HistoryPainter extends CustomPainter {
  final List<double> points;
  final Color accent;
  final double pulse;

  _HistoryPainter({
    required this.points,
    required this.accent,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    canvas.drawRect(Offset.zero & size, bg);

    final baseY = size.height - 30;
    final w = size.width;
    final gap = w / 8;

    for (int i = 0; i < 7; i++) {
      final x = gap * i + 4;
      final arcW = gap - 8;
      final amp = 8 + (pulse * 4);

      final rect = Rect.fromLTWH(x, baseY - amp, arcW, amp * 2);
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..color = accent.withAlpha(220);

      canvas.drawArc(rect, math.pi, math.pi, false, p);
    }

    final line = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(0, baseY + 12),
      Offset(size.width, baseY + 12),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant _HistoryPainter oldDelegate) {
    return oldDelegate.pulse != pulse ||
        oldDelegate.accent != accent ||
        oldDelegate.points != points;
  }
}
