import 'package:flutter/material.dart';

/// Lifecycle of a harvest/processing job. Drives [JobStatusBadge] colors and
/// is reused by [JobStatusCard].
enum JobStatus { assigned, enRoute, inProgress, processing, complete, scheduled }

extension JobStatusStyle on JobStatus {
  String get label => switch (this) {
        JobStatus.assigned => 'Assigned',
        JobStatus.enRoute => 'En route',
        JobStatus.inProgress => 'In progress',
        JobStatus.processing => 'Processing',
        JobStatus.complete => 'Complete',
        JobStatus.scheduled => 'Scheduled',
      };

  Color get bg => switch (this) {
        JobStatus.inProgress => const Color(0xFFFAEEDA),
        JobStatus.enRoute => const Color(0xFFE6F1FB),
        JobStatus.complete => const Color(0xFFEAF3DE),
        JobStatus.scheduled => const Color(0xFFEAF3DE),
        JobStatus.assigned => const Color(0xFFEEEDFE),
        JobStatus.processing => const Color(0xFFFAEEDA),
      };

  Color get text => switch (this) {
        JobStatus.inProgress => const Color(0xFF633806),
        JobStatus.enRoute => const Color(0xFF0C447C),
        JobStatus.complete => const Color(0xFF27500A),
        JobStatus.scheduled => const Color(0xFF27500A),
        JobStatus.assigned => const Color(0xFF3C3489),
        JobStatus.processing => const Color(0xFF633806),
      };
}

/// Colored pill label used on every job card. Status drives color automatically.
class JobStatusBadge extends StatelessWidget {
  final JobStatus status;
  const JobStatusBadge({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: status.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(status.label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w500, color: status.text)),
    );
  }
}
