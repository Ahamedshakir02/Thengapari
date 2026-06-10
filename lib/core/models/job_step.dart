import 'package:flutter/material.dart';

/// Visual state of a checklist step on the OnSiteScreen.
enum StepStatus { done, active, pending }

/// The eight canonical on-site checklist steps (docs/03_site_manager_app_plan.md
/// §4). [id] is the value written to `/jobs/{jobId}/statusUpdates.type` and is
/// the contract the Homeowner live tracker reads — do not rename.
///
/// They unlock strictly in order: the first not-yet-completed step is `active`,
/// everything after it is `pending`.
enum ManagerStepKind {
  arrived,
  harvestStarted,
  harvestComplete,
  yieldWeighed,
  pingSent,
  byproductsRouted,
  yardClean,
  reportSubmitted;

  /// Firestore `type` / `step` id.
  String get id => switch (this) {
        ManagerStepKind.arrived => 'arrived',
        ManagerStepKind.harvestStarted => 'harvest_started',
        ManagerStepKind.harvestComplete => 'harvest_complete',
        ManagerStepKind.yieldWeighed => 'yield_weighed',
        ManagerStepKind.pingSent => 'ping_sent',
        ManagerStepKind.byproductsRouted => 'byproducts_routed',
        ManagerStepKind.yardClean => 'yard_clean',
        ManagerStepKind.reportSubmitted => 'report_submitted',
      };

  String get label => switch (this) {
        ManagerStepKind.arrived => 'Arrived & verified workers',
        ManagerStepKind.harvestStarted => 'Harvest started',
        ManagerStepKind.harvestComplete => 'Yield harvested',
        ManagerStepKind.yieldWeighed => 'Weigh & grade yield',
        ManagerStepKind.pingSent => 'Broadcast to processors',
        ManagerStepKind.byproductsRouted => 'Route byproducts',
        ManagerStepKind.yardClean => 'Yard cleaned',
        ManagerStepKind.reportSubmitted => 'Submit site report',
      };

  String get sub => switch (this) {
        ManagerStepKind.arrived => 'Geo-checked at the gate',
        ManagerStepKind.harvestStarted => 'Crew briefed and climbing',
        ManagerStepKind.harvestComplete => 'All trees cleared',
        ManagerStepKind.yieldWeighed => 'Record weight per grade',
        ManagerStepKind.pingSent => 'Notify nearby buyers',
        ManagerStepKind.byproductsRouted => 'Husk · shell · fronds',
        ManagerStepKind.yardClean => 'Site cleared and tidy',
        ManagerStepKind.reportSubmitted => 'Photos, totals & sign-off',
      };

  /// Steps that open a dedicated screen instead of completing on tap.
  String? get cta => switch (this) {
        ManagerStepKind.yieldWeighed => 'Open weighing',
        ManagerStepKind.pingSent => 'Open broadcast',
        ManagerStepKind.byproductsRouted => 'Assign byproducts',
        ManagerStepKind.reportSubmitted => 'Open report',
        _ => null,
      };

  bool get opensScreen => cta != null;

  IconData get icon => switch (this) {
        ManagerStepKind.arrived => Icons.where_to_vote_outlined,
        ManagerStepKind.harvestStarted => Icons.park_outlined,
        ManagerStepKind.harvestComplete => Icons.spa_outlined,
        ManagerStepKind.yieldWeighed => Icons.monitor_weight_outlined,
        ManagerStepKind.pingSent => Icons.podcasts,
        ManagerStepKind.byproductsRouted => Icons.local_shipping_outlined,
        ManagerStepKind.yardClean => Icons.cleaning_services_outlined,
        ManagerStepKind.reportSubmitted => Icons.description_outlined,
      };

  static ManagerStepKind? fromId(String? id) {
    for (final k in ManagerStepKind.values) {
      if (k.id == id) return k;
    }
    return null;
  }
}

/// One resolved checklist row: a [kind] plus its derived [status] and the
/// [completedAt] time (when done).
class JobStep {
  final ManagerStepKind kind;
  final StepStatus status;
  final DateTime? completedAt;

  const JobStep({
    required this.kind,
    required this.status,
    this.completedAt,
  });

  String get id => kind.id;
  String get label => kind.label;
}

/// Build the ordered checklist from the set of completed step ids (and their
/// completion times). Implements sequential unlocking: the first step not in
/// [completedAt] is `active`; later steps are `pending`.
List<JobStep> buildJobSteps(Map<String, DateTime?> completedAt) {
  final steps = <JobStep>[];
  var foundActive = false;
  for (final kind in ManagerStepKind.values) {
    if (completedAt.containsKey(kind.id)) {
      steps.add(JobStep(
        kind: kind,
        status: StepStatus.done,
        completedAt: completedAt[kind.id],
      ));
    } else if (!foundActive) {
      foundActive = true;
      steps.add(JobStep(kind: kind, status: StepStatus.active));
    } else {
      steps.add(JobStep(kind: kind, status: StepStatus.pending));
    }
  }
  return steps;
}
