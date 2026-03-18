// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

enum _SettingsTab { general, schedule, advanced }

class _SettingsScreenState extends State<SettingsScreen> {
  // ---------------- Tabs ----------------
  _SettingsTab tab = _SettingsTab.general;

  // ---------------- GENERAL: profile/statics ----------------
  String userName = 'John Doe';
  String userEmail = 'john.doe@email.com';

  // ---------------- GENERAL: auto-off timer ----------------
  int selectedTimerHours = 2;

  // ---------------- GENERAL: sliders ----------------
  double brightness = 0.75; // 0..1
  double alertVolume = 0.50; // 0..1

  // ---------------- GENERAL: notification toggles ----------------
  bool notifFilterAlerts = true;
  bool notifAirQualityAlerts = true;
  bool notifDeviceStatus = false;
  bool notifTipsUpdates = true;

  // ---------------- SCHEDULE: active schedules ----------------
  bool weekdaysEnabled = true;
  bool weekendsEnabled = true;

  // schedule labels exactly like screenshot
  String weekdaysTime = '7:00 AM - 10:00 PM';
  String weekendsTime = '9:00 AM - 11:00 PM';
  String weekdaysMode = 'Auto';
  String weekendsMode = 'Sleep';

  bool smartAutoSchedule = true;

  // ---------------- ADVANCED: connectivity ----------------
  bool wifiConnected = true;
  String wifiName = 'Home Network';
  bool bluetoothConnected = false;

  // ---------------- ADVANCED: smart features ----------------
  bool autoModeEnabled = true;
  bool sleepModeEnabled = false;
  bool turboBoostEnabled = false;
  bool childLockEnabled = false;

  // ---------------- ADVANCED: preferences ----------------
  String language = 'English (US)';
  String units = 'Imperial (°F, Miles)';

  // ---------------- Theme constants ----------------
  static const Color _bgTop = Color(0xFFE9F2FF);
  static const Color _bgBottom = Color(0xFFF7FAFF);

  static const Color _ink = Color(0xFF0F172A);
  static const Color _subInk = Color(0xFF64748B);

  static const Color _blue = Color(0xFF3B5BFF);
  static const Color _blue2 = Color(0xFF2F6BFF);

  static const Color _orange = Color(0xFFF59E0B);
  static const Color _purple = Color(0xFF8B5CF6);
  static const Color _pink = Color(0xFFEC4899);
  static const Color _green = Color(0xFF22C55E);

  // ---------------- Helpers ----------------
  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBottom,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_bgTop, _bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            children: [
              const SizedBox(height: 6),
              const _Header(),
              const SizedBox(height: 14),

              _SegmentTabs(
                value: tab,
                onChanged: (t) => setState(() => tab = t),
              ),
              const SizedBox(height: 14),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _buildTab(tab),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(_SettingsTab t) {
    switch (t) {
      case _SettingsTab.general:
        return _GeneralTab(
          key: const ValueKey('general'),
          userName: userName,
          userEmail: userEmail,
          selectedTimerHours: selectedTimerHours,
          onSelectTimer: (h) {
            setState(() => selectedTimerHours = h);
            _toast('Auto-off timer set to ${h}h');
          },
          brightness: brightness,
          onBrightness: (v) => setState(() => brightness = v),
          alertVolume: alertVolume,
          onAlertVolume: (v) => setState(() => alertVolume = v),
          notifFilterAlerts: notifFilterAlerts,
          notifAirQualityAlerts: notifAirQualityAlerts,
          notifDeviceStatus: notifDeviceStatus,
          notifTipsUpdates: notifTipsUpdates,
          onToggleFilter: (v) => setState(() => notifFilterAlerts = v),
          onToggleAir: (v) => setState(() => notifAirQualityAlerts = v),
          onToggleDevice: (v) => setState(() => notifDeviceStatus = v),
          onToggleTips: (v) => setState(() => notifTipsUpdates = v),
          onEditProfile: () {
            _bottomSheet(
              title: 'Edit Profile',
              child: _SheetText(
                'Connect this to your profile screen.\n\nFor now it is interactive and ready to link.',
              ),
            );
          },
        );

      case _SettingsTab.schedule:
        return _ScheduleTab(
          key: const ValueKey('schedule'),
          weekdaysEnabled: weekdaysEnabled,
          weekendsEnabled: weekendsEnabled,
          weekdaysTime: weekdaysTime,
          weekendsTime: weekendsTime,
          weekdaysMode: weekdaysMode,
          weekendsMode: weekendsMode,
          smartAutoSchedule: smartAutoSchedule,
          onToggleWeekdays: (v) => setState(() => weekdaysEnabled = v),
          onToggleWeekends: (v) => setState(() => weekendsEnabled = v),
          onToggleSmartAuto: (v) => setState(() => smartAutoSchedule = v),
          onAddNew: () {
            _bottomSheet(
              title: 'Add New Schedule',
              child: _SheetText(
                'Here you can open your schedule creator screen.\n\nExample: select days + time + mode.',
              ),
              primary: ('Create', () {
                Navigator.pop(context);
                _toast('Open schedule creator');
              }),
            );
          },
          onEditWeekdays: () {
            _scheduleEditSheet(title: 'Weekdays', time: weekdaysTime, mode: weekdaysMode, onSave: (t, m) {
              setState(() {
                weekdaysTime = t;
                weekdaysMode = m;
              });
              _toast('Weekdays updated');
            });
          },
          onEditWeekends: () {
            _scheduleEditSheet(title: 'Weekends', time: weekendsTime, mode: weekendsMode, onSave: (t, m) {
              setState(() {
                weekendsTime = t;
                weekendsMode = m;
              });
              _toast('Weekends updated');
            });
          },
          onTemplateTap: (name) {
            _toast('Applied "$name" template');
          },
        );

      case _SettingsTab.advanced:
        return _AdvancedTab(
          key: const ValueKey('advanced'),
          wifiConnected: wifiConnected,
          wifiName: wifiName,
          bluetoothConnected: bluetoothConnected,

          autoModeEnabled: autoModeEnabled,
          sleepModeEnabled: sleepModeEnabled,
          turboBoostEnabled: turboBoostEnabled,
          childLockEnabled: childLockEnabled,

          language: language,
          units: units,

          onWifiTap: () {
            _bottomSheet(
              title: 'Wi-Fi Connection',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SheetText(wifiConnected ? 'Connected to "$wifiName".' : 'Not connected.'),
                  const SizedBox(height: 10),
                  _SheetToggle(
                    label: 'Wi-Fi Enabled',
                    value: wifiConnected,
                    color: _green,
                    onChanged: (v) => setState(() => wifiConnected = v),
                  ),
                ],
              ),
              primary: ('Done', () => Navigator.pop(context)),
            );
          },

          onBluetoothTap: () {
            _bottomSheet(
              title: 'Bluetooth',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SheetText(bluetoothConnected ? 'Bluetooth is connected.' : 'Bluetooth is not connected.'),
                  const SizedBox(height: 10),
                  _SheetToggle(
                    label: 'Bluetooth Enabled',
                    value: bluetoothConnected,
                    color: _purple,
                    onChanged: (v) => setState(() => bluetoothConnected = v),
                  ),
                ],
              ),
              primary: ('Done', () => Navigator.pop(context)),
            );
          },

          onAutoModeTap: () => _featureSheet(
            title: 'Auto Mode',
            desc: 'Adjust speed based on AQI',
            value: autoModeEnabled,
            color: _purple,
            onChanged: (v) => setState(() => autoModeEnabled = v),
          ),
          onSleepModeTap: () => _featureSheet(
            title: 'Sleep Mode',
            desc: 'Quiet operation at night',
            value: sleepModeEnabled,
            color: const Color(0xFF60A5FA),
            onChanged: (v) => setState(() => sleepModeEnabled = v),
          ),
          onTurboBoostTap: () => _featureSheet(
            title: 'Turbo Boost',
            desc: 'Maximum purification power',
            value: turboBoostEnabled,
            color: _orange,
            onChanged: (v) => setState(() => turboBoostEnabled = v),
          ),
          onChildLockTap: () => _featureSheet(
            title: 'Child Lock',
            desc: 'Prevent accidental changes',
            value: childLockEnabled,
            color: _green,
            onChanged: (v) => setState(() => childLockEnabled = v),
          ),

          onLanguageTap: () {
            _choiceSheet(
              title: 'Language',
              current: language,
              choices: const ['English (US)', 'Hindi', 'English (UK)'],
              onPick: (v) => setState(() => language = v),
            );
          },
          onUnitsTap: () {
            _choiceSheet(
              title: 'Units',
              current: units,
              choices: const ['Imperial (°F, Miles)', 'Metric (°C, Km)'],
              onPick: (v) => setState(() => units = v),
            );
          },
          onPrivacyTap: () {
            _bottomSheet(
              title: 'Privacy & Security',
              child: _SheetText('Connect this to your Privacy screen.\n\nThis item is now responsive.'),
              primary: ('OK', () => Navigator.pop(context)),
            );
          },
          onUserGuideTap: () {
            _bottomSheet(
              title: 'User Guide',
              child: _SheetText('Open your user guide (PDF / web page) from here.'),
              primary: ('OK', () => Navigator.pop(context)),
            );
          },
          onContactSupportTap: () {
            _bottomSheet(
              title: 'Contact Support',
              child: _SheetText('Open your support screen or email/whatsapp from here.'),
              primary: ('OK', () => Navigator.pop(context)),
            );
          },
          onCheckUpdates: () => _toast('Checking for updates...'),
        );
    }
  }

  // ---------------- Bottom sheets ----------------

  void _bottomSheet({
    required String title,
    required Widget child,
    (String, VoidCallback)? primary,
  }) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 8,
            bottom: 18 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _ink)),
              const SizedBox(height: 10),
              child,
              const SizedBox(height: 12),
              if (primary != null)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_blue2, _blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextButton(
                      onPressed: primary.$2,
                      child: Text(
                        primary.$1,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _featureSheet({
    required String title,
    required String desc,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    _bottomSheet(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetText(desc),
          const SizedBox(height: 10),
          _SheetToggle(label: 'Enabled', value: value, color: color, onChanged: onChanged),
        ],
      ),
      primary: ('Done', () => Navigator.pop(context)),
    );
  }

  void _choiceSheet({
    required String title,
    required String current,
    required List<String> choices,
    required ValueChanged<String> onPick,
  }) {
    _bottomSheet(
      title: title,
      child: Column(
        children: choices
            .map(
              (c) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(c, style: const TextStyle(fontWeight: FontWeight.w800, color: _ink)),
                trailing: current == c ? const Icon(Icons.check_circle_rounded, color: _blue2) : null,
                onTap: () {
                  onPick(c);
                  Navigator.pop(context);
                  _toast('$title updated');
                },
              ),
            )
            .toList(),
      ),
    );
  }

  void _scheduleEditSheet({
    required String title,
    required String time,
    required String mode,
    required void Function(String newTime, String newMode) onSave,
  }) {
    String tempTime = time;
    String tempMode = mode;

    _bottomSheet(
      title: 'Edit $title',
      child: StatefulBuilder(
        builder: (ctx, setLocal) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetText('Change time and mode for this schedule.'),
              const SizedBox(height: 10),
              const Text('Time', style: TextStyle(fontWeight: FontWeight.w900, color: _ink)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: tempTime,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.04),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                items: const [
                  '6:00 AM - 9:00 AM',
                  '7:00 AM - 10:00 PM',
                  '9:00 AM - 11:00 PM',
                  '10:00 PM - 6:00 AM',
                  '9:00 AM - 6:00 PM',
                  '6:00 PM - 10:00 PM',
                ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setLocal(() => tempTime = v ?? tempTime),
              ),
              const SizedBox(height: 10),
              const Text('Mode', style: TextStyle(fontWeight: FontWeight.w900, color: _ink)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: tempMode,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.04),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                items: const ['Auto', 'Sleep', 'Turbo', 'Manual']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setLocal(() => tempMode = v ?? tempMode),
              ),
            ],
          );
        },
      ),
      primary: ('Save', () {
        Navigator.pop(context);
        onSave(tempTime, tempMode);
      }),
    );
  }
}

// ======================================================================
// HEADER
// ======================================================================

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Settings & Controls',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _SettingsScreenState._ink,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Customize your air purifier experience',
          style: TextStyle(
            fontSize: 13.5,
            height: 1.2,
            color: _SettingsScreenState._subInk,
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// SEGMENT TABS
// ======================================================================

class _SegmentTabs extends StatelessWidget {
  final _SettingsTab value;
  final ValueChanged<_SettingsTab> onChanged;

  const _SegmentTabs({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final idx = switch (value) {
      _SettingsTab.general => 0,
      _SettingsTab.schedule => 1,
      _SettingsTab.advanced => 2,
    };

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final segmentW = (w - 12) / 3;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                left: idx * segmentW,
                top: 0,
                bottom: 0,
                width: segmentW,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_SettingsScreenState._blue2, _SettingsScreenState._blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Row(
                children: [
                  _SegBtn(
                    label: 'General',
                    selected: value == _SettingsTab.general,
                    onTap: () => onChanged(_SettingsTab.general),
                  ),
                  _SegBtn(
                    label: 'Schedule',
                    selected: value == _SettingsTab.schedule,
                    onTap: () => onChanged(_SettingsTab.schedule),
                  ),
                  _SegBtn(
                    label: 'Advanced',
                    selected: value == _SettingsTab.advanced,
                    onTap: () => onChanged(_SettingsTab.advanced),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SegBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegBtn({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : _SettingsScreenState._ink,
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// GENERAL TAB (matches video)
// ======================================================================

class _GeneralTab extends StatelessWidget {
  final String userName;
  final String userEmail;

  final int selectedTimerHours;
  final ValueChanged<int> onSelectTimer;

  final double brightness;
  final ValueChanged<double> onBrightness;

  final double alertVolume;
  final ValueChanged<double> onAlertVolume;

  final bool notifFilterAlerts;
  final bool notifAirQualityAlerts;
  final bool notifDeviceStatus;
  final bool notifTipsUpdates;

  final ValueChanged<bool> onToggleFilter;
  final ValueChanged<bool> onToggleAir;
  final ValueChanged<bool> onToggleDevice;
  final ValueChanged<bool> onToggleTips;

  final VoidCallback onEditProfile;

  const _GeneralTab({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.selectedTimerHours,
    required this.onSelectTimer,
    required this.brightness,
    required this.onBrightness,
    required this.alertVolume,
    required this.onAlertVolume,
    required this.notifFilterAlerts,
    required this.notifAirQualityAlerts,
    required this.notifDeviceStatus,
    required this.notifTipsUpdates,
    required this.onToggleFilter,
    required this.onToggleAir,
    required this.onToggleDevice,
    required this.onToggleTips,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile card
        _Card(
          noTitleRow: true,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_SettingsScreenState._blue2, _SettingsScreenState._blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName,
                            style: const TextStyle(fontWeight: FontWeight.w800, color: _SettingsScreenState._ink, fontSize: 15.5)),
                        const SizedBox(height: 2),
                        Text(userEmail, style: const TextStyle(color: _SettingsScreenState._subInk, fontSize: 12.5)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onEditProfile,
                    child: const Text('Edit',
                        style: TextStyle(color: _SettingsScreenState._blue2, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ✅ FIX overflow: no fixed small height; safe padding + centered text
              Row(
                children: const [
                  Expanded(child: _StatBox(value: '247', label: 'Days Active')),
                  SizedBox(width: 10),
                  Expanded(child: _StatBox(value: '4.2k', label: 'Hours Run')),
                  SizedBox(width: 10),
                  Expanded(child: _StatBox(value: '98%', label: 'Efficiency')),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Auto-Off Timer
        _Card(
          title: 'Auto-Off Timer',
          iconBg: _SettingsScreenState._blue2,
          icon: Icons.schedule_rounded,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _TimerBtn(hours: 1, selected: selectedTimerHours == 1, onTap: () => onSelectTimer(1))),
                  const SizedBox(width: 10),
                  Expanded(child: _TimerBtn(hours: 2, selected: selectedTimerHours == 2, onTap: () => onSelectTimer(2))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _TimerBtn(hours: 4, selected: selectedTimerHours == 4, onTap: () => onSelectTimer(4))),
                  const SizedBox(width: 10),
                  Expanded(child: _TimerBtn(hours: 8, selected: selectedTimerHours == 8, onTap: () => onSelectTimer(8))),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Display & Sound
        _Card(
          title: 'Display & Sound',
          iconBg: _SettingsScreenState._orange,
          icon: Icons.wb_sunny_rounded,
          child: Column(
            children: [
              _SliderRow(
                icon: Icons.wb_sunny_outlined,
                label: 'Display Brightness',
                percent: (brightness * 100).round(),
                color: _SettingsScreenState._orange,
                value: brightness,
                onChanged: onBrightness,
              ),
              const SizedBox(height: 12),
              _SliderRow(
                icon: Icons.volume_up_rounded,
                label: 'Alert Volume',
                percent: (alertVolume * 100).round(),
                color: _SettingsScreenState._purple,
                value: alertVolume,
                onChanged: onAlertVolume,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Notifications
        _Card(
          title: 'Notifications',
          iconBg: _SettingsScreenState._pink,
          icon: Icons.notifications_rounded,
          child: Column(
            children: [
              _ToggleRow(
                bgTint: const Color(0xFFE9F2FF),
                title: 'Filter Alerts',
                subtitle: 'Remind me to replace filter',
                value: notifFilterAlerts,
                activeColor: _SettingsScreenState._blue2,
                onChanged: onToggleFilter,
              ),
              const SizedBox(height: 10),
              _ToggleRow(
                bgTint: const Color(0xFFFFF3D6),
                title: 'Air Quality Alerts',
                subtitle: 'Alert when AQI is unhealthy',
                value: notifAirQualityAlerts,
                activeColor: _SettingsScreenState._orange,
                onChanged: onToggleAir,
              ),
              const SizedBox(height: 10),
              _ToggleRow(
                bgTint: const Color(0xFFE9FFF4),
                title: 'Device Status',
                subtitle: 'Notify about device issues',
                value: notifDeviceStatus,
                activeColor: _SettingsScreenState._green,
                onChanged: onToggleDevice,
              ),
              const SizedBox(height: 10),
              _ToggleRow(
                bgTint: const Color(0xFFF2E9FF),
                title: 'Tips & Updates',
                subtitle: 'Get maintenance tips',
                value: notifTipsUpdates,
                activeColor: _SettingsScreenState._purple,
                onChanged: onToggleTips,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _SettingsScreenState._ink)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: const TextStyle(fontSize: 11.2, color: _SettingsScreenState._subInk)),
          ),
        ],
      ),
    );
  }
}

class _TimerBtn extends StatelessWidget {
  final int hours;
  final bool selected;
  final VoidCallback onTap;

  const _TimerBtn({required this.hours, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final border = selected ? _SettingsScreenState._blue2.withOpacity(0.45) : Colors.black.withOpacity(0.06);
    final bg = selected ? _SettingsScreenState._blue2.withOpacity(0.10) : Colors.white.withOpacity(0.86);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.2),
        ),
        child: Text(
          '${hours}h',
          style: const TextStyle(fontWeight: FontWeight.w800, color: _SettingsScreenState._ink),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int percent;
  final Color color;
  final double value;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.icon,
    required this.label,
    required this.percent,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _SettingsScreenState._ink),
              ),
            ),
            Text('$percent%', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _SettingsScreenState._subInk)),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            activeTrackColor: color,
            inactiveTrackColor: Colors.black.withOpacity(0.08),
            thumbColor: color,
            overlayColor: color.withOpacity(0.12),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(value: value.clamp(0, 1), onChanged: onChanged),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final Color bgTint;
  final String title;
  final String subtitle;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.bgTint,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: bgTint, borderRadius: BorderRadius.circular(12))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: _SettingsScreenState._ink, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: _SettingsScreenState._subInk, fontSize: 11.5)),
              ],
            ),
          ),
          _ColoredSwitch(value: value, color: activeColor, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ColoredSwitch extends StatelessWidget {
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _ColoredSwitch({required this.value, required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? color : Colors.black.withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
        ),
      ),
    );
  }
}

// ======================================================================
// SCHEDULE TAB (EXACT design from your screenshot)
// ======================================================================

class _ScheduleTab extends StatelessWidget {
  final bool weekdaysEnabled;
  final bool weekendsEnabled;
  final String weekdaysTime;
  final String weekendsTime;
  final String weekdaysMode;
  final String weekendsMode;
  final bool smartAutoSchedule;

  final ValueChanged<bool> onToggleWeekdays;
  final ValueChanged<bool> onToggleWeekends;
  final ValueChanged<bool> onToggleSmartAuto;

  final VoidCallback onAddNew;
  final VoidCallback onEditWeekdays;
  final VoidCallback onEditWeekends;

  final ValueChanged<String> onTemplateTap;

  const _ScheduleTab({
    super.key,
    required this.weekdaysEnabled,
    required this.weekendsEnabled,
    required this.weekdaysTime,
    required this.weekendsTime,
    required this.weekdaysMode,
    required this.weekendsMode,
    required this.smartAutoSchedule,
    required this.onToggleWeekdays,
    required this.onToggleWeekends,
    required this.onToggleSmartAuto,
    required this.onAddNew,
    required this.onEditWeekdays,
    required this.onEditWeekends,
    required this.onTemplateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Card(
          title: 'Active Schedules',
          iconBg: _SettingsScreenState._blue2,
          icon: Icons.calendar_month_rounded,
          trailing: InkWell(
            onTap: onAddNew,
            child: const Text(
              '+ Add New',
              style: TextStyle(
                color: _SettingsScreenState._blue2,
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
              ),
            ),
          ),
          child: Column(
            children: [
              _ScheduleRow(
                title: 'Weekdays',
                time: weekdaysTime,
                mode: weekdaysMode,
                enabled: weekdaysEnabled,
                onToggle: onToggleWeekdays,
                onEdit: onEditWeekdays,
              ),
              const SizedBox(height: 10),
              _ScheduleRow(
                title: 'Weekends',
                time: weekendsTime,
                mode: weekendsMode,
                enabled: weekendsEnabled,
                onToggle: onToggleWeekends,
                onEdit: onEditWeekends,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        _Card(
          title: 'Quick Schedule Templates',
          iconBg: _SettingsScreenState._purple,
          icon: Icons.grid_view_rounded,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TemplateCard(
                      title: 'Morning Boost',
                      subtitle: '6:00 - 9:00 AM',
                      gradient: const [Color(0xFFFF8A00), Color(0xFFF97316)],
                      icon: Icons.wb_sunny_rounded,
                      onTap: () => onTemplateTap('Morning Boost'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TemplateCard(
                      title: 'Work Hours',
                      subtitle: '9:00 AM - 6:00 PM',
                      gradient: const [Color(0xFF2563EB), Color(0xFF3B82F6)],
                      icon: Icons.bolt_rounded,
                      onTap: () => onTemplateTap('Work Hours'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _TemplateCard(
                      title: 'Evening Mode',
                      subtitle: '6:00 - 10:00 PM',
                      gradient: const [Color(0xFFEC4899), Color(0xFFA855F7)],
                      icon: Icons.nights_stay_rounded,
                      onTap: () => onTemplateTap('Evening Mode'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TemplateCard(
                      title: 'Night Sleep',
                      subtitle: '10:00 PM - 6:00 AM',
                      gradient: const [Color(0xFF1D4ED8), Color(0xFF2563EB)],
                      icon: Icons.nightlight_round,
                      onTap: () => onTemplateTap('Night Sleep'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Smart Auto Schedule strip
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.90),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _SettingsScreenState._pink.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: _SettingsScreenState._pink),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Smart Auto Schedule', style: TextStyle(fontWeight: FontWeight.w900, color: _SettingsScreenState._ink, fontSize: 13)),
                    SizedBox(height: 2),
                    Text('AI learns your routine & adjusts automatically', style: TextStyle(color: _SettingsScreenState._subInk, fontSize: 11.5)),
                  ],
                ),
              ),
              _ColoredSwitch(
                value: smartAutoSchedule,
                color: _SettingsScreenState._pink,
                onChanged: onToggleSmartAuto,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final String title;
  final String time;
  final String mode;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  const _ScheduleRow({
    required this.title,
    required this.time,
    required this.mode,
    required this.enabled,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _SettingsScreenState._blue2.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today_rounded, size: 16, color: _SettingsScreenState._blue2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: _SettingsScreenState._ink, fontSize: 13)),
                const SizedBox(height: 2),
                Text(time, style: const TextStyle(color: _SettingsScreenState._subInk, fontSize: 11.5)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Chip(text: 'Mode: $mode'),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: onEdit,
                      child: const Text('Edit', style: TextStyle(color: _SettingsScreenState._blue2, fontWeight: FontWeight.w900, fontSize: 11.5)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _ColoredSwitch(value: enabled, color: _SettingsScreenState._blue2, onChanged: onToggle),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _SettingsScreenState._blue2.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(color: _SettingsScreenState._blue2, fontWeight: FontWeight.w900, fontSize: 11)),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 84,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const Spacer(),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12.5)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.90), fontWeight: FontWeight.w700, fontSize: 10.8)),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// ADVANCED TAB (same look + now responsive)
// ======================================================================

class _AdvancedTab extends StatelessWidget {
  final bool wifiConnected;
  final String wifiName;
  final bool bluetoothConnected;

  final bool autoModeEnabled;
  final bool sleepModeEnabled;
  final bool turboBoostEnabled;
  final bool childLockEnabled;

  final String language;
  final String units;

  final VoidCallback onWifiTap;
  final VoidCallback onBluetoothTap;

  final VoidCallback onAutoModeTap;
  final VoidCallback onSleepModeTap;
  final VoidCallback onTurboBoostTap;
  final VoidCallback onChildLockTap;

  final VoidCallback onLanguageTap;
  final VoidCallback onUnitsTap;
  final VoidCallback onPrivacyTap;

  final VoidCallback onUserGuideTap;
  final VoidCallback onContactSupportTap;
  final VoidCallback onCheckUpdates;

  const _AdvancedTab({
    super.key,
    required this.wifiConnected,
    required this.wifiName,
    required this.bluetoothConnected,
    required this.autoModeEnabled,
    required this.sleepModeEnabled,
    required this.turboBoostEnabled,
    required this.childLockEnabled,
    required this.language,
    required this.units,
    required this.onWifiTap,
    required this.onBluetoothTap,
    required this.onAutoModeTap,
    required this.onSleepModeTap,
    required this.onTurboBoostTap,
    required this.onChildLockTap,
    required this.onLanguageTap,
    required this.onUnitsTap,
    required this.onPrivacyTap,
    required this.onUserGuideTap,
    required this.onContactSupportTap,
    required this.onCheckUpdates,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Card(
          title: 'Connectivity',
          iconBg: _SettingsScreenState._blue2,
          icon: Icons.wifi_rounded,
          child: Column(
            children: [
              _ActionTile(
                icon: Icons.wifi_rounded,
                iconTint: _SettingsScreenState._blue2,
                title: 'Wi-Fi Connection',
                subtitle: wifiConnected ? 'Connected to "$wifiName"' : 'Not connected',
                leadingDot: wifiConnected ? _SettingsScreenState._green : null,
                onTap: onWifiTap,
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.bluetooth_rounded,
                iconTint: _SettingsScreenState._purple,
                title: 'Bluetooth',
                subtitle: bluetoothConnected ? 'Connected' : 'Not connected',
                onTap: onBluetoothTap,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        _Card(
          title: 'Smart Features',
          iconBg: _SettingsScreenState._pink,
          icon: Icons.bolt_rounded,
          child: Column(
            children: [
              _ActionTile(
                icon: Icons.flash_on_rounded,
                iconTint: _SettingsScreenState._purple,
                title: 'Auto Mode',
                subtitle: 'Adjust speed based on AQI',
                badgeOn: autoModeEnabled,
                onTap: onAutoModeTap,
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.nights_stay_rounded,
                iconTint: const Color(0xFF60A5FA),
                title: 'Sleep Mode',
                subtitle: 'Quiet operation at night',
                badgeOn: sleepModeEnabled,
                onTap: onSleepModeTap,
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.trending_up_rounded,
                iconTint: _SettingsScreenState._orange,
                title: 'Turbo Boost',
                subtitle: 'Maximum purification power',
                badgeOn: turboBoostEnabled,
                onTap: onTurboBoostTap,
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.shield_rounded,
                iconTint: _SettingsScreenState._green,
                title: 'Child Lock',
                subtitle: 'Prevent accidental changes',
                badgeOn: childLockEnabled,
                onTap: onChildLockTap,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        _Card(
          title: 'Preferences',
          iconBg: const Color(0xFF10B981),
          icon: Icons.tune_rounded,
          child: Column(
            children: [
              _ActionTile(
                icon: Icons.language_rounded,
                iconTint: const Color(0xFF3B82F6),
                title: 'Language',
                subtitle: language,
                onTap: onLanguageTap,
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.settings_suggest_rounded,
                iconTint: _SettingsScreenState._orange,
                title: 'Units',
                subtitle: units,
                onTap: onUnitsTap,
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.lock_rounded,
                iconTint: const Color(0xFFA855F7),
                title: 'Privacy & Security',
                subtitle: 'Manage data & permissions',
                onTap: onPrivacyTap,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        _Card(
          title: 'Help & Support',
          iconBg: _SettingsScreenState._pink,
          icon: Icons.help_rounded,
          child: Column(
            children: [
              _ActionTile(
                icon: Icons.menu_book_rounded,
                iconTint: const Color(0xFF60A5FA),
                title: 'User Guide',
                subtitle: 'Learn how to use features',
                onTap: onUserGuideTap,
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.support_agent_rounded,
                iconTint: const Color(0xFF34D399),
                title: 'Contact Support',
                subtitle: 'Get help from our team',
                onTap: onContactSupportTap,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Device Information + update button
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Device Information',
                    style: TextStyle(fontWeight: FontWeight.w900, color: _SettingsScreenState._ink, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              const _InfoRow(k: 'App Version', v: '2.5.1'),
              const _InfoRow(k: 'Device Model', v: 'Air Purify + Pro'),
              const _InfoRow(k: 'Firmware', v: '3.1.4'),
              const _InfoRow(k: 'Serial Number', v: 'AP-2024-X7891'),
              const _InfoRow(k: 'Last Updated', v: 'Jan 28, 2026'),

              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: InkWell(
                  onTap: onCheckUpdates,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_SettingsScreenState._blue2, _SettingsScreenState._blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('Check for Updates', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconTint;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  final Color? leadingDot;
  final bool? badgeOn;

  const _ActionTile({
    required this.icon,
    required this.iconTint,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.leadingDot,
    this.badgeOn,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.90),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconTint.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconTint, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: _SettingsScreenState._ink, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: _SettingsScreenState._subInk, fontSize: 11.5)),
                ],
              ),
            ),
            if (leadingDot != null)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(color: leadingDot, borderRadius: BorderRadius.circular(8)),
              ),
            if (badgeOn != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: (badgeOn! ? _SettingsScreenState._green : Colors.black.withOpacity(0.12)),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeOn! ? 'ON' : 'OFF',
                  style: TextStyle(
                    color: badgeOn! ? Colors.white : Colors.black.withOpacity(0.55),
                    fontWeight: FontWeight.w900,
                    fontSize: 10.5,
                  ),
                ),
              ),
            Icon(Icons.chevron_right_rounded, color: Colors.black.withOpacity(0.35)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String k;
  final String v;
  const _InfoRow({required this.k, required this.v});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(child: Text(k, style: const TextStyle(color: _SettingsScreenState._subInk, fontSize: 12.5))),
          Text(v, style: const TextStyle(color: _SettingsScreenState._ink, fontWeight: FontWeight.w800, fontSize: 12.5)),
        ],
      ),
    );
  }
}

// ======================================================================
// CARD WRAPPER (same style)
// ======================================================================

class _Card extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Color? iconBg;
  final Widget child;
  final bool noTitleRow;
  final Widget? trailing;

  const _Card({
    this.title,
    this.icon,
    this.iconBg,
    required this.child,
    this.noTitleRow = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.80),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          if (!noTitleRow && title != null && icon != null && iconBg != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title!,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _SettingsScreenState._ink),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          child,
        ],
      ),
    );
  }
}

// ======================================================================
// Sheet small widgets
// ======================================================================

class _SheetText extends StatelessWidget {
  final String text;
  const _SheetText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: _SettingsScreenState._subInk, height: 1.45));
  }
}

class _SheetToggle extends StatelessWidget {
  final String label;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _SheetToggle({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, color: _SettingsScreenState._ink))),
          _ColoredSwitch(value: value, color: color, onChanged: onChanged),
        ],
      ),
    );
  }
}
