import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Visual variants for [AppButton].
enum AppButtonVariant { primary, secondary, ghost }

/// The shared button used across all roles. Three variants:
/// - [AppButtonVariant.primary]   — filled green CTA
/// - [AppButtonVariant.secondary] — outlined green
/// - [AppButtonVariant.ghost]     — text-only green
///
/// Supports an optional leading [icon], a full-width [expand] mode, and a
/// [loading] spinner state.
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
    final fg = isPrimary ? Colors.white : AgriColors.green600;

    final children = <Widget>[
      if (loading)
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: fg),
        )
      else ...[
        if (icon != null) ...[
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
        ],
        Text(label,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: fg)),
      ],
    ];

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );

    final radius = BorderRadius.circular(12);
    final effectiveOnTap = loading ? null : onPressed;

    final BoxDecoration decoration = switch (variant) {
      AppButtonVariant.primary => BoxDecoration(
          color: effectiveOnTap == null
              ? AgriColors.green400.withValues(alpha: 0.5)
              : AgriColors.green400,
          borderRadius: radius,
        ),
      AppButtonVariant.secondary => BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          border: Border.all(color: AgriColors.green400, width: 1.2),
        ),
      AppButtonVariant.ghost => BoxDecoration(
          color: Colors.transparent,
          borderRadius: radius,
        ),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: effectiveOnTap,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          decoration: decoration,
          child: content,
        ),
      ),
    );
  }
}
