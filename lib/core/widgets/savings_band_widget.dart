import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// The blue savings banner shown at the top of the B2B inventory screen.
/// Displays cumulative savings vs. wholesale for the current month.
class SavingsBandWidget extends StatelessWidget {
  final double savingsAmount;
  const SavingsBandWidget({required this.savingsAmount, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: AgriColors.blue50,
      child: Row(
        children: [
          const Text('Your savings vs wholesale this month',
              style: TextStyle(fontSize: 10, color: Color(0xFF185FA5))),
          const Spacer(),
          Text(
            '₹${savingsAmount.toStringAsFixed(0)} saved',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0C447C),
            ),
          ),
        ],
      ),
    );
  }
}
