import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/design_tokens.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/worker_providers.dart';
import '../theme/worker_theme.dart';

/// Worker "You" tab — identity, lifetime earnings, skills, KYC documents, and
/// settings. Matches `Designs/ThengaPari Worker App/screen-profile.jsx`.
/// Identity name + reliability come from auth/profile; the rest is demo data.
class WorkerProfileTab extends ConsumerWidget {
  const WorkerProfileTab({super.key});

  static const _skills = <_Skill>[
    _Skill('Coconut climbing', Icons.route, 'Expert', 182, 1.0, true),
    _Skill('Tender coconut', Icons.eco, 'Expert', 96, 0.92, true),
    _Skill('Coconut husking', Icons.spa, 'Skilled', 64, 0.70, false),
    _Skill('Palm trimming', Icons.grass, 'Learning', 18, 0.34, false),
  ];

  static const _docs = <_Doc>[
    _Doc('Aadhaar identity', Icons.badge, 'XXXX XXXX 4471', 'Verified'),
    _Doc('Bank account', Icons.account_balance, 'Federal Bank ••8820', 'Verified'),
    _Doc('Police verification', Icons.shield_outlined, 'Thrissur Rural · 2025', 'Verified'),
    _Doc('Accident cover', Icons.health_and_safety_outlined, 'ThengaSuraksha · active', 'Active'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final uid = user?.uid ?? '';
    final profile = ref.watch(workerProfileProvider(uid)).value;
    final reliability = (profile?.reliabilityScore ?? 94).round();
    final name = [user?.firstName, user?.lastName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');
    final displayName = name.isEmpty ? 'Ravi Krishnan' : name;
    final lang = ref.watch(localeProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const WScreenHeader(
            title: 'Profile',
            trailing: WHeaderIconBtn(icon: Icons.edit_outlined),
          ),
          _identity(displayName, reliability),
          const SizedBox(height: 14),
          _lifetimeCard(),
          _skillsCard(),
          _docsCard(),
          _settingsCard(context, ref, lang),
          const SizedBox(height: 18),
          Center(
            child: Text('ThengaPari Worker · v2.4.0',
                style: AppText.caption().copyWith(color: WColors.fg3)),
          ),
        ],
      ),
    );
  }

  Widget _identity(String name, int reliability) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [WColors.glowTop, WColors.surface],
        ),
        border: Border.all(color: WColors.lineStrong),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.26),
              blurRadius: 30,
              offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [WColors.teal500, WColors.bg2],
                      ),
                      border: Border.all(color: WColors.lineStrong, width: 1.5),
                    ),
                    child: Text(name[0].toUpperCase(),
                        style: AppText.displayNum(27, color: Colors.white)),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: WColors.good,
                        border: Border.all(color: WColors.surface, width: 3),
                      ),
                      child: const Icon(Icons.check, size: 11, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.displayNum(22, color: Colors.white)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.verified, size: 15, color: WColors.accent2),
                        const SizedBox(width: 6),
                        Text('Verified climber',
                            style: AppText.bodySm().copyWith(
                                color: WColors.teal100,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Divider(color: WColors.line, height: 1),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                _stat('4.9', 'Avg. rating', Icons.star_rounded, true),
                _divider(),
                _stat('360', 'Jobs done', Icons.check_circle_outline, false),
                _divider(),
                _stat('$reliability%', 'Reliability', Icons.shield_outlined, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, IconData icon, bool accent) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: accent ? WColors.accent : WColors.teal300),
              const SizedBox(width: 5),
              Text(value,
                  style: AppText.displayNum(22,
                      color: WColors.fg1, weight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: AppText.caption().copyWith(color: WColors.fg3)),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 30, color: WColors.line);

  Widget _lifetimeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0x29F4A52A), Color(0x0AF4A52A)],
        ),
        border: Border.all(color: const Color(0x47F4A52A)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color(0x2EF4A52A),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.account_balance_wallet_outlined,
                size: 22, color: WColors.accent2),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lifetime earnings',
                    style: AppText.caption().copyWith(
                        color: WColors.fg2, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                const WRupee('1,42,800', size: 26, weight: FontWeight.w800),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('With ThengaPari since',
                  style: AppText.caption().copyWith(color: WColors.fg3)),
              const SizedBox(height: 2),
              Text('Mar 2023',
                  style: AppText.caption().copyWith(
                      color: WColors.teal100, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _skillsCard() {
    return _sectionCard(
      icon: Icons.route,
      title: 'Skills',
      child: Column(
        children: [
          for (int i = 0; i < _skills.length; i++) ...[
            if (i > 0) const Divider(color: WColors.line, height: 1),
            _skillRow(_skills[i]),
          ],
        ],
      ),
    );
  }

  Widget _skillRow(_Skill s) {
    final (fg, bg) = switch (s.level) {
      'Expert' => (WColors.accent2, const Color(0x29F4A52A)),
      'Skilled' => (WColors.teal300, const Color(0x296FB6AB)),
      _ => (WColors.fg2, WColors.surface2),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: WColors.surface2,
                    borderRadius: BorderRadius.circular(11)),
                child: Icon(s.icon, size: 19, color: WColors.teal300),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name,
                        style: AppText.body().copyWith(
                            color: WColors.fg1, fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('${s.jobs} jobs',
                        style: AppText.caption().copyWith(color: WColors.fg3)),
                  ],
                ),
              ),
              WTag(text: s.level.toUpperCase(), fg: fg, bg: bg),
            ],
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: s.pct,
              minHeight: 6,
              backgroundColor: WColors.surface2,
              valueColor: AlwaysStoppedAnimation(
                  s.level == 'Expert' ? WColors.accent : WColors.teal500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _docsCard() {
    return _sectionCard(
      icon: Icons.description_outlined,
      title: 'Documents & KYC',
      child: Column(
        children: [
          for (int i = 0; i < _docs.length; i++) ...[
            if (i > 0) const Divider(color: WColors.line, height: 1),
            _docRow(_docs[i]),
          ],
        ],
      ),
    );
  }

  Widget _docRow(_Doc d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: WColors.surface2,
                borderRadius: BorderRadius.circular(11)),
            child: Icon(d.icon, size: 19, color: WColors.teal300),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.title,
                    style: AppText.body().copyWith(
                        color: WColors.fg1, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 2),
                Text(d.meta,
                    style: AppText.caption()
                        .copyWith(color: WColors.fg3, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_outline, size: 16, color: WColors.good),
          const SizedBox(width: 5),
          Text(d.status,
              style: AppText.caption().copyWith(
                  color: WColors.good, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _settingsCard(BuildContext context, WidgetRef ref, AppLang lang) {
    return _sectionCard(
      icon: Icons.settings_outlined,
      title: 'Settings',
      child: Column(
        children: [
          _settingRow(Icons.language, 'App language',
              value: lang == AppLang.ml ? 'മലയാളം' : 'English',
              onTap: () => ref.read(localeProvider.notifier).toggle()),
          const Divider(color: WColors.line, height: 1),
          _settingRow(Icons.notifications_none, 'Notifications', value: 'On'),
          const Divider(color: WColors.line, height: 1),
          _settingRow(Icons.help_outline, 'Help & support',
              onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: WColors.surface,
                      title: const Text('Help & support',
                          style: TextStyle(color: WColors.fg1)),
                      content: const Text(
                          'Call ThengaPari worker support at 1800-123-4567 '
                          '(8am–8pm), or email help@thengapari.in.',
                          style: TextStyle(color: WColors.fg2)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  )),
          const Divider(color: WColors.line, height: 1),
          _settingRow(Icons.logout, 'Log out', danger: true, onTap: () {
            ref.read(devAuthOverrideProvider.notifier).set(null);
            ref.read(authServiceProvider).signOut();
          }),
        ],
      ),
    );
  }

  Widget _settingRow(IconData icon, String label,
      {String? value, bool danger = false, VoidCallback? onTap}) {
    final color = danger ? WColors.bad : WColors.fg1;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 20, color: danger ? WColors.bad : WColors.teal300),
            const SizedBox(width: 13),
            Expanded(
              child: Text(label,
                  style: AppText.body()
                      .copyWith(color: color, fontWeight: FontWeight.w500, fontSize: 15)),
            ),
            if (value != null)
              Text(value, style: AppText.bodySm().copyWith(color: WColors.fg3)),
            if (!danger) ...[
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 18, color: WColors.fg3),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(
      {required IconData icon, required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: WColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: WColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: WColors.accent2),
              const SizedBox(width: 8),
              Text(title, style: AppText.title().copyWith(fontSize: 16, color: WColors.fg1)),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class _Skill {
  final String name;
  final IconData icon;
  final String level;
  final int jobs;
  final double pct;
  final bool expert;
  const _Skill(this.name, this.icon, this.level, this.jobs, this.pct, this.expert);
}

class _Doc {
  final String title;
  final IconData icon;
  final String meta;
  final String status;
  const _Doc(this.title, this.icon, this.meta, this.status);
}
