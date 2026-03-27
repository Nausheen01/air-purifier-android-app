// redesign the icon
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedAqiCard extends StatefulWidget {
  final int aqi;
  final int pm25;
  final int previousAqi;

  /// In your video AQI tile is SHIELD and rotates
  final String aqiTileIconAsset;

  final String trendUpAsset;
  final String trendDownAsset;

  const AnimatedAqiCard({
    super.key,
    required this.aqi,
    required this.pm25,
    required this.previousAqi,
    this.aqiTileIconAsset = 'assets/icons/shield.svg',
    this.trendUpAsset = 'assets/icons/trend-up.svg',
    this.trendDownAsset = 'assets/icons/trend-down.svg',
  });

  @override
  State<AnimatedAqiCard> createState() => _AnimatedAqiCardState();
}

class _AnimatedAqiCardState extends State<AnimatedAqiCard>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final Animation<double> _fade;
  late final Animation<double> _slide;

  // ✅ icon box rotation (360)
  late final AnimationController _tileRotate;

  // ✅ subtle float like original
  late final AnimationController _float;
  late final Animation<double> _floatAnim;

  // ✅ PM bar shine animation
  late final AnimationController _shine;

  @override
  void initState() {
    super.initState();

    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fade = CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic);
    _slide = Tween<double>(begin: 14, end: 0).animate(
      CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic),
    );

    _tileRotate = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -2.2, end: 2.2).animate(
      CurvedAnimation(parent: _float, curve: Curves.easeInOut),
    );

    _shine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _enter.forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    _tileRotate.dispose();
    _float.dispose();
    _shine.dispose();
    super.dispose();
  }

  _AqiTheme _themeFor(int aqi) {
    if (aqi <= 50) {
      return _AqiTheme(
        label: 'Good',
        statusLine: 'Improving Air Quality',
        statusColor: const Color(0xFF16A34A),
        bgTop: const Color(0xFFD7ECFF),
        bgBottom: const Color(0xFF69A9FF),
        accent: const Color(0xFF1D5CFF),
      );
    }
    if (aqi <= 100) {
      return _AqiTheme(
        label: 'Moderate',
        statusLine: 'Improving Air Quality',
        statusColor: const Color(0xFF16A34A),
        bgTop: const Color(0xFFFFE0C7),
        bgBottom: const Color(0xFFFF8634),
        accent: const Color(0xFFFF5A00),
      );
    }
    return _AqiTheme(
      label: 'Unhealthy',
      statusLine: 'Needs Attention',
      statusColor: const Color(0xFFEF4444),
      bgTop: const Color(0xFFFFC7CB),
      bgBottom: const Color(0xFFFF4955),
      accent: const Color(0xFFFF1B2D),
    );
  }

  double _pm25Percent(int pm25) => (pm25 / 150).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final now = _themeFor(widget.aqi);
    final prev = _themeFor(widget.previousAqi);
    final improving = widget.aqi <= widget.previousAqi;

    return AnimatedBuilder(
      animation: Listenable.merge([_fade, _slide, _tileRotate, _float, _shine]),
      builder: (context, _) {
        return Opacity(
          opacity: _fade.value,
          child: Transform.translate(
            offset: Offset(0, _slide.value),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(
                begin: widget.previousAqi.toDouble(),
                end: widget.aqi.toDouble(),
              ),
              builder: (context, aqiAnim, __) {
                final denom =
                    max(1, (widget.aqi - widget.previousAqi).abs()).toDouble();
                final t = ((aqiAnim - widget.previousAqi).abs() / denom)
                    .clamp(0.0, 1.0);

                final bgTop = Color.lerp(prev.bgTop, now.bgTop, t)!;
                final bgBottom = Color.lerp(prev.bgBottom, now.bgBottom, t)!;
                final accent = Color.lerp(prev.accent, now.accent, t)!;

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [bgTop, bgBottom],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.60),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.38),
                        blurRadius: 36,
                        offset: const Offset(0, 22),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'AIR QUALITY INDEX',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: Colors.black.withOpacity(0.55),
                            ),
                          ),
                          _StatusPill(label: now.label, accent: accent),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // AQI Row
                      Row(
                        children: [
                          Transform.translate(
                            offset: Offset(0, _floatAnim.value),
                            child: Transform.rotate(
                              angle: -0.18,
                              child: RotationTransition(
                                turns: _tileRotate,
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        accent.withOpacity(0.95),
                                        accent.withOpacity(0.70),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.withOpacity(0.45),
                                        blurRadius: 18,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      widget.aqiTileIconAsset,
                                      height: 22,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            '${aqiAnim.round()}',
                            style: GoogleFonts.inter(
                              fontSize: 54,
                              height: 1.0,
                              fontWeight: FontWeight.w900,
                              color: accent,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          SvgPicture.asset(
                            improving ? widget.trendDownAsset : widget.trendUpAsset,
                            height: 16,
                            colorFilter: ColorFilter.mode(
                              now.statusColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            now.statusLine,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: now.statusColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // PM 2.5 Inner Card
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.82),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 22,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${widget.pm25}',
                                  style: GoogleFonts.inter(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    height: 1.0,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    'µg/m³ PM2.5',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black.withOpacity(0.65),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            _PmBarExact(
                              percent: _pm25Percent(widget.pm25),
                              accent: accent,
                              shineT: _shine.value,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ✅ PM bar closer to original: progress + moving shine band
class _PmBarExact extends StatelessWidget {
  final double percent;
  final Color accent;
  final double shineT;

  const _PmBarExact({
    required this.percent,
    required this.accent,
    required this.shineT,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: percent),
      builder: (context, p, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 9,
            child: Stack(
              children: [
                // track
                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.10)),
                ),

                // progress
                FractionallySizedBox(
                  widthFactor: p,
                  child: Container(
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // moving shine band (only inside progress)
                FractionallySizedBox(
                  widthFactor: p,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final w = c.maxWidth;
                        final bandW = max(18.0, w * 0.18);
                        final x = (w + bandW) * shineT - bandW;

                        return Transform.translate(
                          offset: Offset(x, 0),
                          child: Container(
                            width: bandW,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.35),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color accent;
  const _StatusPill({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.42),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _AqiTheme {
  final String label;
  final String statusLine;
  final Color statusColor;
  final Color bgTop;
  final Color bgBottom;
  final Color accent;

  _AqiTheme({
    required this.label,
    required this.statusLine,
    required this.statusColor,
    required this.bgTop,
    required this.bgBottom,
    required this.accent,
  });
}
