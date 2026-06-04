import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/flavor_config.dart';

/// Shared startup for every flavor entrypoint.
///
/// Initialises the binding, records the active [Flavor], boots Firebase
/// (reads the per-flavor `google-services.json` on Android), and runs the app
/// inside a Riverpod [ProviderScope].
Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig(flavor);

  // Uses the google-services.json bundled for the active Android flavor.
  // Replace the placeholder JSON files before running on a device.
  await Firebase.initializeApp();

  runApp(const ProviderScope(child: AgriApp()));
}
