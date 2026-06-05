import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Shared text input. Renders an optional [label] above a themed field
/// (filled surface, rounded, green focus border — see [buildAgriTheme]'s
/// `inputDecorationTheme`). Supports leading/trailing icons, hint, error text,
/// obscured input, and keyboard type.
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final int? maxLength;

  const AppTextField({
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.maxLength,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3B6D11))),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          maxLength: maxLength,
          style: const TextStyle(fontSize: 14, color: Color(0xFF173404)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(fontSize: 14, color: Color(0xFF908C7E)),
            errorText: errorText,
            counterText: '',
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: AgriColors.green600)
                : null,
            suffixIcon: suffix,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}
