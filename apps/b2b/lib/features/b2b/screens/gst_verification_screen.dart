import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:core/app/design_tokens.dart';
import 'package:b2b/router.dart';
import 'package:core/core/models/b2b_buyer_profile.dart';
import 'package:core/core/providers/auth_provider.dart';
import 'package:core/core/providers/b2b_providers.dart';
import '../widgets/b2b_widgets.dart';

/// Admin-approval gate. After GST submission, buyers can browse inventory
/// read-only but cannot place orders until `/b2b_buyers/{uid}.verified == true`.
class GSTVerificationScreen extends ConsumerWidget {
  const GSTVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final profile = ref.watch(b2bProfileProvider(uid)).value;
    final verified = profile?.verified ?? false;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          B2bAppBar(
            eyebrow: 'Account verification',
            title: verified ? 'Verified' : 'GST under review',
            action: B2bIconBtn(
                icon: Icons.logout,
                onTap: () => ref.read(authServiceProvider).signOut()),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 8),
                _hero(verified),
                const SizedBox(height: 18),
                if (profile != null) _details(profile),
                const SizedBox(height: 18),
                if (verified)
                  B2bButton(
                    label: "Start buying",
                    trailingIcon: Icons.arrow_forward,
                    onTap: () => context.go(AppRoutes.b2bHome),
                  )
                else ...[
                  B2bButton(
                    label: 'Browse inventory (read-only)',
                    icon: Icons.visibility_outlined,
                    ghost: true,
                    onTap: () => context.go(AppRoutes.b2bHome),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                        'You can browse live prices now. Ordering unlocks once your GST is approved.',
                        textAlign: TextAlign.center,
                        style:
                            AppText.bodySm().copyWith(color: AppColors.fg3)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(bool verified) {
    final color = verified ? AppColors.green600 : AppColors.blue500;
    final bg = verified ? AppColors.statusCompleteBg : AppColors.blue100;
    return B2bCard(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(verified ? Icons.verified : Icons.fact_check_outlined,
                size: 40, color: color),
          ),
          const SizedBox(height: 16),
          Text(verified ? "You're verified" : 'Verification pending',
              style: AppText.h2().copyWith(color: AppColors.fg1)),
          const SizedBox(height: 8),
          Text(
            verified
                ? 'Your GST was approved. You can place orders and set up standing orders.'
                : 'We\'re checking your GSTIN against the government database. This usually takes a few hours.',
            textAlign: TextAlign.center,
            style: AppText.body().copyWith(color: AppColors.fg2),
          ),
        ],
      ),
    );
  }

  Widget _details(B2BBuyerProfile p) {
    return B2bCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SUBMITTED DETAILS',
              style: AppText.overline().copyWith(color: AppColors.fg3)),
          const SizedBox(height: 12),
          _row(Icons.store_outlined, 'Business', p.businessName),
          if (p.businessType != null)
            _row(Icons.category_outlined, 'Type', p.businessType!.label),
          _row(Icons.verified_outlined, 'GSTIN', p.gstNumber),
          _row(Icons.place_outlined, 'District', p.district),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.blue500),
          const SizedBox(width: 10),
          Text(label, style: AppText.bodySm().copyWith(color: AppColors.fg3)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: AppText.bodySm().copyWith(
                    color: AppColors.fg1, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
