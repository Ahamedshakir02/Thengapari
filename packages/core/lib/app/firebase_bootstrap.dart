import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Boots Firebase for a live app and, when built with
/// `--dart-define=USE_FIREBASE_EMULATORS=true`, points Auth, Firestore and
/// Functions at the local Firebase Emulator Suite instead of production.
///
/// The emulator host defaults to `10.0.2.2` (how the Android emulator reaches
/// the host machine); override with `--dart-define=FIREBASE_EMULATOR_HOST=…`.
///
/// PHYSICAL-DEVICE CAVEAT: the FlutterFire plugins remap `localhost`/
/// `127.0.0.1` to `10.0.2.2` on EVERY Android target — including real phones,
/// where 10.0.2.2 doesn't exist — so `adb reverse` + 127.0.0.1 does NOT work
/// for Auth/Firestore/Functions on a physical device. For a phone, put the
/// emulators on the LAN instead: set `"host": "0.0.0.0"` on each emulator in
/// firebase.json, allow the ports through the Windows firewall, and pass the
/// PC's Wi-Fi IP via `FIREBASE_EMULATOR_HOST`. The Android emulator needs none
/// of that (the 10.0.2.2 mapping is exactly right there).
///
/// Run fully live-local (no Blaze plan, no SMS quota, no console switches):
///   cd functions && npm run emulators     # in one terminal
///   npm run seed:emulator                 # once, to load demo data
///   flutter run --dart-define=USE_FIREBASE_EMULATORS=true
Future<void> bootstrapFirebase() async {
  await Firebase.initializeApp();

  const useEmulators = bool.fromEnvironment('USE_FIREBASE_EMULATORS');
  if (!useEmulators) return;

  const host =
      String.fromEnvironment('FIREBASE_EMULATOR_HOST', defaultValue: '10.0.2.2');
  try {
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
    debugPrint('[ThengaPari] Using Firebase emulators at $host');
  } catch (e) {
    debugPrint('[ThengaPari] Emulator hookup failed: $e');
  }
}
