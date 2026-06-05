import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/crop_listing.dart';
import '../../core/models/crop_summary.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/countdown_timer_widget.dart';
import '../../core/widgets/crop_inventory_row.dart';
import '../../core/widgets/hero_landscape_widget.dart';
import '../../core/widgets/job_status_badge.dart';
import '../../core/widgets/job_status_card.dart';
import '../../core/widgets/live_inventory_tile.dart';
import '../../core/widgets/painters/radar_map_painter.dart';
import '../../core/widgets/painters/savings_bar_chart_painter.dart';
import '../../core/widgets/painters/weekly_earnings_chart_painter.dart';
import '../../core/widgets/painters/yield_donut_painter.dart';
import '../../core/widgets/role_nav_bars.dart';
import '../../core/widgets/savings_band_widget.dart';
import '../../core/widgets/shimmer_job_card.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/user_avatar_widget.dart';
import '../../core/widgets/worker_availability_toggle.dart';
import '../../core/widgets/worker_job_detail_row.dart';

/// Standalone debug app that renders the entire shared widget library and every
/// custom painter on one scrollable page. Wired into `main_dev.dart` so you can
/// hot-reload and visually verify the foundation before building real screens.
///
/// This intentionally does NOT boot Firebase or the role router — it is a pure
/// UI harness.
class WidgetGalleryApp extends StatelessWidget {
  const WidgetGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget Gallery',
      debugShowCheckedModeBanner: false,
      theme: buildAgriTheme(),
      home: const WidgetGalleryScreen(),
    );
  }
}

class WidgetGalleryScreen extends StatefulWidget {
  const WidgetGalleryScreen({super.key});

  @override
  State<WidgetGalleryScreen> createState() => _WidgetGalleryScreenState();
}

class _WidgetGalleryScreenState extends State<WidgetGalleryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Timer _countdown;
  int _seconds = 45;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds = _seconds > 0 ? _seconds - 1 : 45);
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    _countdown.cancel();
    super.dispose();
  }

  // ---- Sample data -------------------------------------------------------

  static const _crops = [
    CropSummary(name: 'Coconut', icon: '🥥', quantity: '×24'),
    CropSummary(name: 'Mango', icon: '🥭', quantity: '×8'),
    CropSummary(name: 'Pepper', icon: '🌶️', quantity: '~2 kg'),
    CropSummary(name: 'Jackfruit', icon: '🟢', quantity: '×3'),
  ];

  static const _listings = [
    CropListing(
      id: '1',
      name: 'Tender Coconut',
      grade: 'Grade A',
      icon: '🥥',
      bgColor: Color(0xFFEAF3DE),
      harvestedLabel: 'Harvested today',
      location: 'Thrissur',
      quantity: '×150',
      priceLabel: '₹18/pc',
      savingLabel: '↓14% vs market',
      savingPercent: 14,
    ),
    CropListing(
      id: '2',
      name: 'Alphonso Mango',
      grade: 'Alphonso',
      icon: '🥭',
      bgColor: Color(0xFFFAEEDA),
      harvestedLabel: 'Harvested 1d ago',
      location: 'Ernakulam',
      quantity: '40 kg',
      priceLabel: '₹120/kg',
      savingLabel: '↓10% vs market',
      savingPercent: 10,
    ),
    CropListing(
      id: '3',
      name: 'Black Pepper (dry)',
      grade: 'dry',
      icon: '🌶️',
      bgColor: Color(0xFFE6F1FB),
      harvestedLabel: 'Cured',
      location: 'Wayanad',
      quantity: '12 kg',
      priceLabel: '₹620/kg',
      savingLabel: '↓20% vs market',
      savingPercent: 20,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriColors.surface,
      appBar: AppBar(
        title: const Text('ThengaPari · Widget Gallery'),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // ===================== PAINTERS =====================
          _SectionHeader('Painters'),

          _Tile(
            'KeralaLandscapePainter (via HeroLandscapeWidget)',
            const HeroLandscapeWidget(
              greeting: 'Good morning, Meera',
              subtitle: 'Your harvest is ready to schedule',
            ),
            padded: false,
          ),

          _Tile(
            'WeeklyEarningsChartPainter',
            const SizedBox(
              height: 95,
              child: CustomPaint(
                painter: WeeklyEarningsChartPainter(
                  weeklyEarnings: [2100, 2800, 1900, 3200, 4100, 4280],
                ),
                child: SizedBox(width: double.infinity),
              ),
            ),
          ),

          _Tile(
            'RadarMapPainter (animated)',
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFF0F6E56),
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => CustomPaint(
                  painter: RadarMapPainter(pingAnimValue: _pulse.value),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),

          _Tile(
            'YieldDonutPainter',
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AgriColors.green600,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const SizedBox(
                height: 120,
                child: CustomPaint(
                  painter: YieldDonutPainter(gradeA: 142, gradeB: 68, tender: 34),
                  child: SizedBox(width: double.infinity),
                ),
              ),
            ),
          ),

          _Tile(
            'SavingsBarChartPainter',
            const SizedBox(
              height: 95,
              child: CustomPaint(
                painter: SavingsBarChartPainter(
                  savingsPercent: {
                    'Coconut': 14,
                    'Mango': 10,
                    'Pepper': 8,
                    'Jackfruit': 20,
                  },
                ),
                child: SizedBox(width: double.infinity),
              ),
            ),
          ),

          // ===================== PRIMITIVES =====================
          _SectionHeader('Primitives'),

          _Tile(
            'StatCard',
            Row(children: const [
              Expanded(child: StatCard(value: '₹4,280', label: 'Yield earned')),
              SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  value: '0.8 kg',
                  label: 'Weight saved vs before',
                  valueColor: AgriColors.amber600,
                ),
              ),
            ]),
          ),

          _Tile(
            'JobStatusBadge (all states)',
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                JobStatusBadge(status: JobStatus.assigned),
                JobStatusBadge(status: JobStatus.enRoute),
                JobStatusBadge(status: JobStatus.inProgress),
                JobStatusBadge(status: JobStatus.processing),
                JobStatusBadge(status: JobStatus.complete),
                JobStatusBadge(status: JobStatus.scheduled),
              ],
            ),
          ),

          _Tile(
            'WorkerJobDetailRow',
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: const [
                WorkerJobDetailRow(
                    icon: Icons.payments_outlined,
                    label: 'Payout',
                    value: '₹420'),
                WorkerJobDetailRow(
                    icon: Icons.access_time_outlined,
                    label: 'Est. duration',
                    value: '~2h'),
                WorkerJobDetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Distance',
                    value: '2.4 km'),
                WorkerJobDetailRow(
                    icon: Icons.star_outline,
                    label: 'Site Manager',
                    value: 'Arjun K. ⭐4.8',
                    isLast: true),
              ]),
            ),
          ),

          _Tile(
            'CountdownTimerWidget (live)',
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F6E56),
                borderRadius: BorderRadius.circular(14),
              ),
              child: CountdownTimerWidget(seconds: _seconds),
            ),
            padded: false,
          ),

          _Tile(
            'SavingsBandWidget',
            const SavingsBandWidget(savingsAmount: 3240),
            padded: false,
          ),

          _Tile(
            'WorkerAvailabilityToggle (tap me)',
            const Align(
              alignment: Alignment.centerLeft,
              child: WorkerAvailabilityToggle(initialValue: true),
            ),
          ),

          // ===================== COMPOSITES =====================
          _SectionHeader('Composites'),

          _Tile(
            'CropInventoryRow',
            const CropInventoryRow(crops: _crops),
            padded: false,
          ),

          _Tile(
            'JobStatusCard (in-progress, with progress)',
            const JobStatusCard(
              title: 'Coconut + Mango harvest',
              status: JobStatus.inProgress,
              detail: 'Site Manager: Arjun K.',
              rightDetail: '2.1 km away',
              progress: 0.60,
            ),
            padded: false,
          ),

          _Tile(
            'JobStatusCard (scheduled, no progress)',
            const JobStatusCard(
              title: 'Pepper harvest',
              status: JobStatus.scheduled,
              detail: 'Tomorrow, 9:00 AM',
              rightDetail: 'Vadakke Padam',
            ),
            padded: false,
          ),

          _Tile(
            'LiveInventoryTile',
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  for (final l in _listings)
                    LiveInventoryTile(listing: l, onPreBook: () {}),
                ],
              ),
            ),
            padded: false,
          ),

          // ===================== SHARED UI =====================
          _SectionHeader('Shared UI'),

          _Tile(
            'AppButton (variants + states)',
            Column(children: [
              AppButton(label: 'Primary action', onPressed: () {}),
              const SizedBox(height: 10),
              AppButton(
                label: 'Secondary',
                variant: AppButtonVariant.secondary,
                icon: Icons.add,
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Ghost',
                variant: AppButtonVariant.ghost,
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              const AppButton(label: 'Disabled', onPressed: null),
              const SizedBox(height: 10),
              AppButton(label: 'Loading', loading: true, onPressed: () {}),
            ]),
          ),

          _Tile(
            'AppTextField',
            Column(children: const [
              AppTextField(
                label: 'Phone number',
                hint: '98765 43210',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12),
              AppTextField(
                label: 'District',
                hint: 'Select your district',
                errorText: 'This field is required',
              ),
            ]),
          ),

          _Tile(
            'UserAvatarWidget',
            Row(children: const [
              UserAvatarWidget(name: 'Meera Nair', size: 52, online: true),
              SizedBox(width: 16),
              UserAvatarWidget(name: 'Arjun K', size: 52, online: false),
              SizedBox(width: 16),
              UserAvatarWidget(name: 'Ravi', size: 40),
            ]),
          ),

          _Tile(
            'ShimmerJobCard + ShimmerText',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerText(width: 160, height: 14),
                SizedBox(height: 10),
                ShimmerJobCard(),
              ],
            ),
            padded: false,
          ),

          // ===================== NAV BARS =====================
          _SectionHeader('Role bottom nav bars'),

          _Tile('HomeownerBottomNav',
              const HomeownerBottomNav(currentIndex: 0), padded: false),
          _Tile('WorkerBottomNav', const WorkerBottomNav(currentIndex: 1),
              padded: false),
          _Tile('SiteManagerBottomNav',
              const SiteManagerBottomNav(currentIndex: 1), padded: false),
          _Tile('B2BBottomNav', const B2BBottomNav(currentIndex: 0),
              padded: false),
        ],
      ),
    );
  }
}

/// A labelled group divider in the gallery.
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AgriColors.green800,
        ),
      ),
    );
  }
}

/// A single labelled widget specimen — caption above, the widget framed in a
/// white card below.
class _Tile extends StatelessWidget {
  final String label;
  final Widget child;
  final bool padded;

  const _Tile(this.label, this.child, {this.padded = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6E6B60),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AgriColors.border, width: 0.5),
              ),
              padding: padded ? const EdgeInsets.all(14) : EdgeInsets.zero,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
