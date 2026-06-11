import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Metric summary card. Used in pairs on the Homeowner and Worker home screens.
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const StatCard({
    required this.value,
    required this.label,
    this.valueColor = const Color(0xFF3B6D11),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AgriColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: valueColor)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
        ],
      ),
    );
  }
}
