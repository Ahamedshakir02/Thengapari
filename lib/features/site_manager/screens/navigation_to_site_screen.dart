import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/design_tokens.dart';
import '../../../core/models/harvest_job.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/site_manager_providers.dart';
import '../widgets/sm_widgets.dart';

/// Pre-arrival navigation. The "I've arrived" check-in only unlocks once the
/// Site Manager is within 100 m of the job site (Geolocator distance check),
/// then writes the `arrived` status update + flips the job to `in_progress`.
class NavigationToSiteScreen extends ConsumerStatefulWidget {
  final HarvestJob job;
  const NavigationToSiteScreen({super.key, required this.job});

  @override
  ConsumerState<NavigationToSiteScreen> createState() =>
      _NavigationToSiteScreenState();
}

class _NavigationToSiteScreenState
    extends ConsumerState<NavigationToSiteScreen> {
  static const _radiusMeters = 100.0;

  double? _distanceMeters;
  Position? _position;
  bool _locating = false;
  bool _checkingIn = false;
  String? _locError;

  @override
  void initState() {
    super.initState();
    _refreshLocation();
  }

  bool get _withinRange =>
      _distanceMeters != null && _distanceMeters! <= _radiusMeters;

  Future<void> _refreshLocation() async {
    setState(() {
      _locating = true;
      _locError = null;
    });
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) throw 'Location services are off';
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        throw 'Location permission denied';
      }
      final pos = await Geolocator.getCurrentPosition();
      double? dist;
      final dest = widget.job.location;
      if (dest != null) {
        dist = Geolocator.distanceBetween(
            pos.latitude, pos.longitude, dest.latitude, dest.longitude);
      }
      if (!mounted) return;
      setState(() {
        _position = pos;
        _distanceMeters = dist;
        _locating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locating = false;
        _locError = e.toString();
      });
    }
  }

  /// Dev/review affordance: pretend we're standing at the gate so the check-in
  /// gate can be exercised without real GPS at the property.
  void _simulateAtGate() => setState(() {
        _distanceMeters = 0;
        _locError = null;
      });

  Future<void> _checkIn() async {
    final uid = ref.read(authStateProvider).value?.uid ?? '';
    final loc = _position != null
        ? GeoPoint(_position!.latitude, _position!.longitude)
        : widget.job.location ?? const GeoPoint(10.0, 76.3);
    setState(() => _checkingIn = true);
    try {
      await ref
          .read(siteManagerServiceProvider)
          .checkIn(jobId: widget.job.id, uid: uid, location: loc);
      if (!mounted) return;
      ref.read(managerTabProvider.notifier).state = 1; // On-site tab
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _checkingIn = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Check-in failed: $e')));
    }
  }

  Future<void> _callHomeowner() async {
    final uri = Uri.parse('tel:+910000000000');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          SmPaperHeader(
            title: 'Navigate to site',
            subtitle: '${job.district ?? "Site"} · ${job.title}',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpace.s4),
              children: [
                _mapCard(),
                const SizedBox(height: AppSpace.s4),
                _etaBanner(),
                const SizedBox(height: AppSpace.s4),
                _jobBrief(job),
                const SizedBox(height: AppSpace.s4),
                _proximityCard(),
              ],
            ),
          ),
          _checkInBar(),
        ],
      ),
    );
  }

  Widget _mapCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: SizedBox(
        height: 210,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _RoutePainter())),
            Positioned(
              right: 12,
              top: 12,
              child: GestureDetector(
                onTap: _locating ? null : _refreshLocation,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.sm),
                  child: _locating
                      ? const Padding(
                          padding: EdgeInsets.all(11),
                          child:
                              CircularProgressIndicator(strokeWidth: 2.2))
                      : const Icon(Icons.my_location,
                          size: 20, color: AppColors.brand),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _etaBanner() {
    return SmCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.amber100,
                borderRadius: BorderRadius.circular(AppRadii.md)),
            child: const Icon(Icons.navigation,
                size: 22, color: AppColors.statusInprogressFg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: '~12',
                      style: AppText.displayNum(22, color: AppColors.fg1)),
                  TextSpan(
                      text: ' min',
                      style:
                          AppText.bodySm().copyWith(color: AppColors.fg2)),
                  TextSpan(
                      text: '  · 1.8 km',
                      style:
                          AppText.caption().copyWith(color: AppColors.fg3)),
                ])),
                const SizedBox(height: 2),
                Text('Fastest route via NH-66',
                    style: AppText.caption().copyWith(color: AppColors.fg3)),
              ],
            ),
          ),
          GestureDetector(
            onTap: _callHomeowner,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                  color: AppColors.brand, shape: BoxShape.circle),
              child: const Icon(Icons.call, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _jobBrief(HarvestJob job) {
    return SmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SmOverline('Job brief'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final c in job.cropTypes)
                SmChip('${c[0].toUpperCase()}${c.substring(1)}',
                    icon: Icons.eco),
            ],
          ),
          const SizedBox(height: 12),
          if (job.estimatedYieldKg != null)
            _briefRow(Icons.scale_outlined, 'Estimated yield',
                '${job.estimatedYieldKg!.toStringAsFixed(0)} kg'),
          if ((job.notes).isNotEmpty)
            _briefRow(Icons.sticky_note_2_outlined, 'Note from homeowner',
                job.notes),
          _briefRow(Icons.place_outlined, 'Address',
              job.address ?? job.district ?? 'Shared on arrival'),
        ],
      ),
    );
  }

  Widget _briefRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.greenSage500),
          const SizedBox(width: 10),
          Text(label, style: AppText.bodySm().copyWith(color: AppColors.fg3)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: AppText.bodySm().copyWith(
                    color: AppColors.fg1, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _proximityCard() {
    final (icon, color, title, sub) = _withinRange
        ? (
            Icons.check_circle,
            AppColors.green600,
            'You\'re at the site',
            'Within ${_radiusMeters.toStringAsFixed(0)} m — check-in unlocked'
          )
        : _distanceMeters != null
            ? (
                Icons.directions_walk,
                AppColors.accent,
                '${_fmtDistance(_distanceMeters!)} away',
                'Get within ${_radiusMeters.toStringAsFixed(0)} m to check in'
              )
            : (
                Icons.location_searching,
                AppColors.fg3,
                _locError ?? 'Locating you…',
                'Check-in unlocks within ${_radiusMeters.toStringAsFixed(0)} m of the site'
              );
    return SmCard(
      color: _withinRange ? AppColors.statusCompleteBg : null,
      border: _withinRange
          ? Border.all(color: AppColors.green600.withValues(alpha: 0.4))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppText.title()
                            .copyWith(fontSize: 16, color: AppColors.fg1)),
                    Text(sub,
                        style: AppText.bodySm().copyWith(color: AppColors.fg2)),
                  ],
                ),
              ),
            ],
          ),
          if (!_withinRange) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _simulateAtGate,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt, size: 15, color: AppColors.fg3),
                  const SizedBox(width: 6),
                  Text('Dev · simulate arrival at gate',
                      style:
                          AppText.caption().copyWith(color: AppColors.fg3)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _checkInBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpace.s4, AppSpace.s3, AppSpace.s4, AppSpace.s3),
          child: SmButton(
            label: _withinRange ? "I've arrived — check in" : 'Move closer to check in',
            icon: Icons.where_to_vote_outlined,
            kind: SmButtonKind.accent,
            large: true,
            loading: _checkingIn,
            onTap: _withinRange ? _checkIn : null,
          ),
        ),
      ),
    );
  }

  static String _fmtDistance(double m) =>
      m >= 1000 ? '${(m / 1000).toStringAsFixed(1)} km' : '${m.toStringAsFixed(0)} m';
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.greenLeaf100, AppColors.greenLeaf300],
        ).createShader(rect),
    );
    final road = Paint()
      ..color = AppColors.paper50
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, 0.7 * h), Offset(w, 0.55 * h), road);
    canvas.drawLine(Offset(0.3 * w, h), Offset(0.45 * w, 0), road);

    final route = Path()
      ..moveTo(0.3 * w, 0.85 * h)
      ..cubicTo(0.4 * w, 0.7 * h, 0.3 * w, 0.5 * h, 0.55 * w, 0.4 * h)
      ..cubicTo(0.75 * w, 0.3 * h, 0.7 * w, 0.22 * h, 0.78 * w, 0.18 * h);
    canvas.drawPath(
        route,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..color = AppColors.brand);

    // start dot
    canvas.drawCircle(Offset(0.3 * w, 0.85 * h), 9, Paint()..color = Colors.white);
    canvas.drawCircle(
        Offset(0.3 * w, 0.85 * h),
        9,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = AppColors.brand);
    // destination pin
    final pin = Offset(0.78 * w, 0.18 * h);
    canvas.drawCircle(pin.translate(0, -4), 13, Paint()..color = AppColors.accent);
    final tail = Path()
      ..moveTo(pin.dx - 8, pin.dy - 2)
      ..lineTo(pin.dx + 8, pin.dy - 2)
      ..lineTo(pin.dx, pin.dy + 10)
      ..close();
    canvas.drawPath(tail, Paint()..color = AppColors.accent);
    canvas.drawCircle(
        pin.translate(0, -5), 5, Paint()..color = AppColors.greenForest900);
  }

  @override
  bool shouldRepaint(_RoutePainter oldDelegate) => false;
}
