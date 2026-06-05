import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';

/// Visual variants for [AppButton].
enum AppButtonVariant { primary, secondary, ghost }

/// The shared button, matched to the design system's `.btn` (pill shape,
/// 52px tall, Noto Sans 600):
/// - [AppButtonVariant.primary]   — filled forest-green CTA
/// - [AppButtonVariant.secondary] — surface with brand text + strong border
/// - [AppButtonVariant.ghost]     — text-only brand
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool expand;
  final bool loading;

  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.expand = true,
    this.loading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == AppButtonVariant.primary;
    final fg = isPrimary ? AppColors.onBrand : AppColors.brand;

    final children = <Widget>[
      if (loading)
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: fg),
        )
      else ...[
        if (icon != null) ...[
          Icon(icon, size: 19, color: fg),
          const SizedBox(width: 9),
        ],
        Text(label, style: AppText.button().copyWith(color: fg)),
      ],
    ];

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );

    final radius = BorderRadius.circular(AppRadii.pill);
    final effectiveOnTap = loading ? null : onPressed;
    final disabled = effectiveOnTap == null;

    final BoxDecoration decoration = switch (variant) {
      AppButtonVariant.primary => BoxDecoration(
          color: AppColors.brand,
          borderRadius: radius,
          boxShadow: disabled ? null : AppShadows.md,
        ),
      AppButtonVariant.secondary => BoxDecoration(
          color: AppColors.surface,
          borderRadius: radius,
          border: Border.all(color: AppColors.borderStrong, width: 1.5),
        ),
      AppButtonVariant.ghost => BoxDecoration(
          color: Colors.transparent,
          borderRadius: radius,
        ),
    };

    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: effectiveOnTap,
          borderRadius: radius,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: decoration,
            child: content,
          ),
        ),
      ),
    );
  }
}
