import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

/// Worker app entrypoint — LIVE.
///
/// Boots real Firebase (production config from `google-services.json`, or the
/// local emulator suite when built with
/// `--dart-define=USE_FIREBASE_EMULATORS=true`), real phone-OTP auth, and no
/// provider overrides — every screen reads/writes Firestore through the core
/// services. The seeded offline demo harness lives in `main_demo.dart`
/// (`flutter run -t lib/main_demo.dart`).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig(Flavor.dev);
  // Worker design default: bilingual English + Malayalam ('Both').
  gAppLang = AppLang.both;
  await bootstrapFirebase();
  await Hive.initFlutter();
  await Hive.openBox(OnboardingService.boxName);
  runApp(const ProviderScope(child: WorkerApp()));
}
