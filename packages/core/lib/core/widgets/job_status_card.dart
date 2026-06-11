import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'job_status_badge.dart';

/// Active/scheduled job card for the Homeowner home screen. Shows title +
/// [JobStatusBadge], a detail row, and an optional in-progress progress bar.
class JobStatusCard extends StatelessWidget {
  final String title;
  final JobStatus status;
  final String detail;
  final String rightDetail;
  final double? progress; // 0.0–1.0, null if not in-progress

  const JobStatusCard({
    required this.title,
    required this.status,
    required this.detail,
    required this.rightDetail,
    this.progress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AgriColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
              ),
              JobStatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(detail,
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF888888))),
              const Spacer(),
              Text(rightDetail,
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF888888))),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                backgroundColor: AgriColors.green50,
                color: AgriColors.green400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
