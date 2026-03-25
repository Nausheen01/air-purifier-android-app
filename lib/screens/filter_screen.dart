// change the filter screen UI
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  FilterType _selected = FilterType.hepa;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _select(FilterType t) {
    if (t == _selected) return;
    setState(() => _selected = t);
    _c.forward(from: 0); // re-run landing animations like your video
  }

  @override
  Widget build(BuildContext context) {
    final theme = FilterTheme.byType(_selected);
    final data = FilterData.byType(_selected);

    // ✅ prevents “cards cut out” behind bottom nav
    final bottomSafe = MediaQuery.of(context).padding.bottom + 120;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEEF4FF), Color(0xFFF7FAFF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(18, 10, 18, bottomSafe),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  "Filter Management",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2F66FF),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Complete filter health & maintenance system",
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    height: 1.25,
                    color: Colors.black.withOpacity(0.55),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),

                // ✅ Chips (icons + tile color differ per filter, like your video)
                Row(
                  children: [
                    Expanded(
                      child: FilterChipCard(
                        selected: _selected == FilterType.hepa,
                        title: "HEPA H13",
                        subtitle:
                            "${FilterData.byType(FilterType.hepa).lifePct.toStringAsFixed(0)}% Life",
                        svgIcon: "assets/icons/funnel.svg",
                        theme: FilterTheme.byType(FilterType.hepa),
                        onTap: () => _select(FilterType.hepa),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilterChipCard(
                        selected: _selected == FilterType.preFilter,
                        title: "Pre-Filter",
                        subtitle:
                            "${FilterData.byType(FilterType.preFilter).lifePct.toStringAsFixed(0)}% Life",
                        svgIcon: "assets/icons/stack.svg",
                        theme: FilterTheme.byType(FilterType.preFilter),
                        onTap: () => _select(FilterType.preFilter),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilterChipCard(
                        selected: _selected == FilterType.carbon,
                        title: "Activated Carbon",
                        subtitle:
                            "${FilterData.byType(FilterType.carbon).lifePct.toStringAsFixed(0)}% Life",
                        svgIcon: "assets/icons/wind.svg",
                        theme: FilterTheme.byType(FilterType.carbon),
                        onTap: () => _select(FilterType.carbon),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilterChipCard(
                        selected: _selected == FilterType.uvc,
                        title: "UV-C Light",
                        subtitle:
                            "${FilterData.byType(FilterType.uvc).lifePct.toStringAsFixed(0)}% Life",
                        svgIcon: "assets/icons/sun.svg",
                        theme: FilterTheme.byType(FilterType.uvc),
                        onTap: () => _select(FilterType.uvc),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ✅ Detail card (changes together when you select filter)
                _FilterDetailCard(
                  data: data,
                  theme: theme,
                  controller: _c,
                ),

                const SizedBox(height: 16),

                // ✅ Performance (shield icon + animated bars + axis numbers)
                _PerformanceCard(
                  theme: theme,
                  data: data,
                  controller: _c,
                ),

                const SizedBox(height: 16),

                // ✅ 1) Separate card: Replacement Filters (like your video)
                const _ReplacementFiltersCard(),

                const SizedBox(height: 16),

                // ✅ 2) Separate card: Maintenance Guide (like your video)
                const _MaintenanceGuideCard(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum FilterType { hepa, preFilter, carbon, uvc }

class FilterTheme {
  final Color accent;
  final LinearGradient selectedGradient;
  final Color iconTileBg; // small square bg in unselected chips
  final Color buyNowColor;

  const FilterTheme({
    required this.accent,
    required this.selectedGradient,
    required this.iconTileBg,
    required this.buyNowColor,
  });

  static FilterTheme byType(FilterType t) {
    switch (t) {
      case FilterType.hepa:
        return const FilterTheme(
          accent: Color(0xFF2F66FF),
          selectedGradient:
              LinearGradient(colors: [Color(0xFF2F66FF), Color(0xFF7B61FF)]),
          iconTileBg: Color(0xFFEAF1FF),
          buyNowColor: Color(0xFF2F66FF),
        );
      case FilterType.preFilter:
        return const FilterTheme(
          accent: Color(0xFF7C3AED),
          selectedGradient:
              LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFA855F7)]),
          iconTileBg: Color(0xFFF2EAFE),
          buyNowColor: Color(0xFF7C3AED),
        );
      case FilterType.carbon:
        return const FilterTheme(
          accent: Color(0xFF22C55E),
          selectedGradient:
              LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF16A34A)]),
          iconTileBg: Color(0xFFEAFBF1),
          buyNowColor: Color(0xFF16A34A),
        );
      case FilterType.uvc:
        return const FilterTheme(
          accent: Color(0xFFF59E0B),
          selectedGradient:
              LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFF97316)]),
          iconTileBg: Color(0xFFFFF4E3),
          buyNowColor: Color(0xFFF59E0B),
        );
    }
  }
}

class FilterData {
  final FilterType type;
  final String title;
  final String description;
  final double lifePct;
  final int daysLeft;
  final String efficiencyLabel;
  final String statusPill;
  final Color statusColor;
  final String leadingSvg;

  final List<double> efficiencyBars;
  final List<double> airflowBars;

  const FilterData({
    required this.type,
    required this.title,
    required this.description,
    required this.lifePct,
    required this.daysLeft,
    required this.efficiencyLabel,
    required this.statusPill,
    required this.statusColor,
    required this.leadingSvg,
    required this.efficiencyBars,
    required this.airflowBars,
  });

  static FilterData byType(FilterType t) {
    switch (t) {
      case FilterType.hepa:
        return const FilterData(
          type: FilterType.hepa,
          title: "HEPA H13 Filter",
          description: "Captures 99.97% of particles",
          lifePct: 100,
          daysLeft: 180,
          efficiencyLabel: "High",
          statusPill: "Excellent",
          statusColor: Color(0xFF22C55E),
          leadingSvg: "assets/icons/funnel.svg",
          efficiencyBars: [100, 96, 92, 88, 82, 74, 66],
          airflowBars: [100, 95, 90, 84, 78, 70, 62],
        );
      case FilterType.preFilter:
        return const FilterData(
          type: FilterType.preFilter,
          title: "Pre-Filter",
          description: "Blocks hair, dust & larger particles",
          lifePct: 90,
          daysLeft: 90,
          efficiencyLabel: "High",
          statusPill: "Good",
          statusColor: Color(0xFF3B82F6),
          leadingSvg: "assets/icons/stack.svg",
          efficiencyBars: [98, 96, 93, 89, 84, 78, 72],
          airflowBars: [100, 97, 92, 86, 80, 73, 66],
        );
      case FilterType.carbon:
        return const FilterData(
          type: FilterType.carbon,
          title: "Activated Carbon",
          description: "Reduces odor & harmful gases",
          lifePct: 75,
          daysLeft: 120,
          efficiencyLabel: "Medium",
          statusPill: "Moderate",
          statusColor: Color(0xFFF59E0B),
          leadingSvg: "assets/icons/wind.svg",
          efficiencyBars: [95, 93, 90, 86, 80, 72, 64],
          airflowBars: [100, 96, 90, 83, 75, 66, 58],
        );
      case FilterType.uvc:
        return const FilterData(
          type: FilterType.uvc,
          title: "UV-C Light",
          description: "Helps neutralize bacteria & microbes",
          lifePct: 95,
          daysLeft: 365,
          efficiencyLabel: "High",
          statusPill: "Excellent",
          statusColor: Color(0xFF22C55E),
          leadingSvg: "assets/icons/sun.svg",
          efficiencyBars: [100, 99, 97, 95, 92, 88, 84],
          airflowBars: [100, 98, 95, 92, 88, 83, 78],
        );
    }
  }
}

class FilterChipCard extends StatelessWidget {
  const FilterChipCard({
    super.key,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.svgIcon,
    required this.theme,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final String svgIcon;
  final FilterTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: selected ? theme.selectedGradient : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(selected ? 0.14 : 0.08),
              blurRadius: selected ? 20 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.20)
                    : theme.iconTileBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SvgPicture.asset(
                  svgIcon,
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    selected ? Colors.white : theme.accent,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12.8,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : const Color(0xFF1E2A3B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white.withOpacity(0.88)
                          : Colors.black.withOpacity(0.50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDetailCard extends StatelessWidget {
  const _FilterDetailCard({
    required this.data,
    required this.theme,
    required this.controller,
  });

  final FilterData data;
  final FilterTheme theme;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.40, curve: Curves.easeOut),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    ));
    final ringAnim =
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);

    final pct = (data.lifePct / 100).clamp(0.0, 1.0);

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: _CardShell(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.accent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.accent.withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        data.leadingSvg,
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title,
                          style: GoogleFonts.poppins(
                            fontSize: 13.8,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E2A3B),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          data.description,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.52),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusPill(text: data.statusPill, color: data.statusColor),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    flex: 11,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: AnimatedBuilder(
                        animation: ringAnim,
                        builder: (_, __) {
                          final animatedPct =
                              (pct * ringAnim.value).clamp(0.0, 1.0);
                          return _ProgressRing(
                            percent: animatedPct,
                            gradient: theme.selectedGradient,
                            centerTextTop:
                                "${data.lifePct.toStringAsFixed(0)}%",
                            centerTextBottom: "Remaining",
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 10,
                    child: Column(
                      children: [
                        _MiniStat(
                          accent: theme.accent,
                          iconSvg: "assets/icons/calendar-blank.svg",
                          label: "Days Left",
                          value: data.daysLeft.toString(),
                        ),
                        const SizedBox(height: 10),
                        _MiniStat(
                          accent: theme.accent,
                          iconSvg: "assets/icons/wind.svg",
                          label: "Efficiency",
                          value: data.efficiencyLabel,
                          valueIsText: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ✅ Replace button color changes with selection (like your video)
              Row(
                children: [
                  Expanded(
                    child: _BouncyButton(
                      bg: theme.accent,
                      fg: Colors.white,
                      icon: Icons.autorenew_rounded,
                      label: "Replace Now",
                      onTap: () {}, // ✅ no popup
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BouncyButton(
                      bg: const Color(0xFF14B86A),
                      fg: Colors.white,
                      svgIcon: "assets/icons/shopping-cart.svg",
                      label: "Order Filter",
                      onTap: () {}, // ✅ no popup
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({
    required this.theme,
    required this.data,
    required this.controller,
  });

  final FilterTheme theme;
  final FilterData data;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final barsAnim = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOutBack),
    );

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Performance Over Time",
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E2A3B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Efficiency & airflow degradation",
                      style: GoogleFonts.poppins(
                        fontSize: 11.2,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.52),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Center(
                  // ✅ shield icon (video)
                  child: SvgPicture.asset(
                    "assets/icons/shield.svg",
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.55),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: barsAnim,
              builder: (_, __) {
                return CustomPaint(
                  painter: _BarChartPainter(
                    efficiency: data.efficiencyBars,
                    airflow: data.airflowBars,
                    t: barsAnim.value,
                    effColor: theme.accent,
                    airColor: const Color(0xFF8B5CF6),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(label: "Efficiency", color: theme.accent),
              const SizedBox(width: 18),
              const _LegendDot(label: "Airflow", color: Color(0xFF8B5CF6)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReplacementFiltersCard extends StatelessWidget {
  const _ReplacementFiltersCard();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        children: [
          Row(
            children: [
              // cart icon on left in header like video
              SvgPicture.asset(
                "assets/icons/shopping-cart.svg",
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.55),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Replacement Filters",
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E2A3B),
                  ),
                ),
              ),
              Text(
                "Shop All →",
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2F66FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _ReplacementRow(
            theme: FilterTheme.byType(FilterType.hepa),
            icon: "assets/icons/funnel.svg",
            title: "HEPA H13",
            subtitle: "Lifespan: 180 days",
            price: "\$49.99",
          ),
          const SizedBox(height: 10),
          _ReplacementRow(
            theme: FilterTheme.byType(FilterType.preFilter),
            icon: "assets/icons/stack.svg",
            title: "Pre-Filter",
            subtitle: "Lifespan: 90 days",
            price: "\$19.99",
          ),
          const SizedBox(height: 10),
          _ReplacementRow(
            theme: FilterTheme.byType(FilterType.carbon),
            icon: "assets/icons/wind.svg",
            title: "Activated Carbon",
            subtitle: "Lifespan: 120 days",
            price: "\$34.99",
          ),
          const SizedBox(height: 10),
          _ReplacementRow(
            theme: FilterTheme.byType(FilterType.uvc),
            icon: "assets/icons/sun.svg",
            title: "UV-C Light",
            subtitle: "Lifespan: 365 days",
            price: "\$59.99",
          ),
        ],
      ),
    );
  }
}

class _ReplacementRow extends StatelessWidget {
  const _ReplacementRow({
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.price,
  });

  final FilterTheme theme;
  final String icon;
  final String title;
  final String subtitle;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.iconTileBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                width: 18,
                height: 18,
                colorFilter:
                    ColorFilter.mode(theme.accent, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E2A3B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.50),
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E2A3B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Buy Now",
                style: GoogleFonts.poppins(
                  fontSize: 11.2,
                  fontWeight: FontWeight.w800,
                  color: theme.buyNowColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MaintenanceGuideCard extends StatelessWidget {
  const _MaintenanceGuideCard();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // cube icon in video header (use stack as a close match if you want)
              Icon(Icons.grid_view_rounded,
                  size: 18, color: Colors.black.withOpacity(0.55)),
              const SizedBox(width: 8),
              Text(
                "Maintenance Guide",
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E2A3B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _GuideRow(
            bg: const Color(0xFFEAF1FF),
            iconColor: const Color(0xFF2F66FF),
            iconSvg: "assets/icons/video-camera.svg",
            title: "Watch Installation Tutorial",
            subtitle:
                "Learn how to replace filters properly in 3 minutes",
            actionText: "Watch Video →",
            actionColor: const Color(0xFF2F66FF),
          ),
          const SizedBox(height: 10),
          _GuideRow(
            bg: const Color(0xFFF2EAFE),
            iconColor: const Color(0xFF7C3AED),
            iconSvg: "assets/icons/calendar-blank.svg",
            title: "Set Reminder",
            subtitle:
                "Get notified when it's time to clean or replace filters",
            actionText: "Enable Alerts →",
            actionColor: const Color(0xFF7C3AED),
          ),
          const SizedBox(height: 10),
          _GuideRow(
            bg: const Color(0xFFEAFBF1),
            iconColor: const Color(0xFF22C55E),
            iconSvg: "assets/icons/speaker-simple-high.svg",
            title: "Clean Pre-Filter Monthly",
            subtitle:
                "Vacuum or wash pre-filter to extend HEPA filter lifespan",
            actionText: "",
            actionColor: const Color(0xFF22C55E),
          ),
        ],
      ),
    );
  }
}

class _GuideRow extends StatelessWidget {
  const _GuideRow({
    required this.bg,
    required this.iconColor,
    required this.iconSvg,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.actionColor,
  });

  final Color bg;
  final Color iconColor;
  final String iconSvg;
  final String title;
  final String subtitle;
  final String actionText;
  final Color actionColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconSvg,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E2A3B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11.1,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.55),
                  ),
                ),
                if (actionText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    actionText,
                    style: GoogleFonts.poppins(
                      fontSize: 11.2,
                      fontWeight: FontWeight.w900,
                      color: actionColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: child,
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.accent,
    required this.iconSvg,
    required this.label,
    required this.value,
    this.valueIsText = false,
  });

  final Color accent;
  final String iconSvg;
  final String label;
  final String value;
  final bool valueIsText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconSvg,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.55),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: valueIsText ? 14 : 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E2A3B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BouncyButton extends StatefulWidget {
  const _BouncyButton({
    required this.bg,
    required this.fg,
    required this.label,
    required this.onTap,
    this.icon,
    this.svgIcon,
  });

  final Color bg;
  final Color fg;
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final String? svgIcon;

  @override
  State<_BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<_BouncyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 140));
    _s = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapCancel: () => _c.reverse(),
      onTapUp: (_) {
        _c.reverse();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _s,
        builder: (_, __) {
          return Transform.scale(
            scale: _s.value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: widget.bg,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: widget.bg.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.svgIcon != null)
                    SvgPicture.asset(
                      widget.svgIcon!,
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(widget.fg, BlendMode.srcIn),
                    )
                  else if (widget.icon != null)
                    Icon(widget.icon!, size: 18, color: widget.fg),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: widget.fg,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.percent,
    required this.gradient,
    required this.centerTextTop,
    required this.centerTextBottom,
  });

  final double percent;
  final LinearGradient gradient;
  final String centerTextTop;
  final String centerTextBottom;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RingPainter(percent: percent, gradient: gradient),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 2),
            Text(
              centerTextTop,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E2A3B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              centerTextBottom,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Colors.black.withOpacity(0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final LinearGradient gradient;

  _RingPainter({required this.percent, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2;

    final trackPaint = Paint()
      ..color = const Color(0xFFE8F0FF)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final ringPaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: r))
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = const Color(0xFF2F66FF).withOpacity(0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(center, r - 6, glowPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r - 6),
      -math.pi / 2,
      math.pi * 2,
      false,
      trackPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r - 6),
      -math.pi / 2,
      (math.pi * 2) * percent,
      false,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.percent != percent || oldDelegate.gradient != gradient;
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.2,
            fontWeight: FontWeight.w700,
            color: Colors.black.withOpacity(0.60),
          ),
        ),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> efficiency;
  final List<double> airflow;
  final double t;
  final Color effColor;
  final Color airColor;

  _BarChartPainter({
    required this.efficiency,
    required this.airflow,
    required this.t,
    required this.effColor,
    required this.airColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final padL = 34.0;
    final padR = 10.0;
    final padT = 12.0;
    final padB = 26.0;

    final rect = Rect.fromLTWH(
      padL,
      padT,
      size.width - padL - padR,
      size.height - padT - padB,
    );

    final gridPaint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 1;

    final labelStyle = TextStyle(
      fontSize: 9.5,
      fontWeight: FontWeight.w700,
      color: Colors.black.withOpacity(0.35),
    );

    for (int i = 0; i <= 4; i++) {
      final y = rect.top + rect.height * (i / 4);
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), gridPaint);
      final v = (100 - (i * 25)).toString();
      _drawText(canvas, v, Offset(6, y - 6), labelStyle);
    }

    const xLabels = ["D1", "D30", "D60", "D90", "D120", "D150", "D180"];
    for (int i = 0; i < xLabels.length; i++) {
      final x = rect.left + rect.width * (i / (xLabels.length - 1));
      if (i % 2 == 0 || i == xLabels.length - 1) {
        _drawText(canvas, xLabels[i], Offset(x - 10, rect.bottom + 8), labelStyle);
      }
    }

    final n = math.min(efficiency.length, airflow.length);
    final groupW = rect.width / n;
    final barW = groupW * 0.26;
    final gap = groupW * 0.12;

    final effPaint = Paint()..color = effColor;
    final airPaint = Paint()..color = airColor;

    for (int i = 0; i < n; i++) {
      final baseX = rect.left + i * groupW + (groupW / 2);

      final effH = rect.height * ((efficiency[i].clamp(0, 100) / 100) * t);
      final airH = rect.height * ((airflow[i].clamp(0, 100) / 100) * t);

      final effRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(baseX - barW - (gap / 2), rect.bottom - effH, barW, effH),
        const Radius.circular(6),
      );
      final airRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(baseX + (gap / 2), rect.bottom - airH, barW, airH),
        const Radius.circular(6),
      );

      canvas.drawRRect(effRect, effPaint);
      canvas.drawRRect(airRect, airPaint);
    }
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.t != t ||
      old.efficiency != efficiency ||
      old.airflow != airflow ||
      old.effColor != effColor ||
      old.airColor != airColor;
}
