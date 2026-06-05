import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// A single row in the job-detail card on the Worker ping screen:
/// icon chip + label + right-aligned value, with a hairline divider unless
/// it is the last row.
class WorkerJobDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const WorkerJobDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFEAF3DE), width: 0.5)),
      ),
      child: Row(children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AgriColors.green50,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 14, color: AgriColors.green600),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF3B6D11))),
        const Spacer(),
        Text(value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF173404),
            )),
      ]),
    );
  }
}
