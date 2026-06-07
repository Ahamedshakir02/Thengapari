import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/worker_profile.dart';
import '../services/worker_service.dart';

/// Single shared [WorkerService] instance.
final workerServiceProvider = Provider<WorkerService>((ref) => WorkerService());

/// Live `/workers/{uid}` profile (skills, online state, reliability, etc.).
final workerProfileProvider =
    StreamProvider.family<WorkerProfile?, String>((ref, uid) {
  return ref.watch(workerServiceProvider).watchWorker(uid);
});
