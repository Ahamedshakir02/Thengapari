import 'package:hive/hive.dart';

/// Local persistence for the one-time onboarding flag.
///
/// Backed by the shared `app_prefs` Hive box (opened in `bootstrap.dart`).
/// Reads are synchronous so the router redirect can decide first-launch vs
/// returning user without awaiting. If the box has not been opened (e.g. in a
/// dev harness that bypasses [bootstrap]), it degrades to "not seen".
class OnboardingService {
  static const boxName = 'app_prefs';
  static const _seenKey = 'onboarding_done';

  /// True once the user has finished (or skipped) onboarding.
  bool get hasSeenOnboarding {
    if (!Hive.isBoxOpen(boxName)) return false;
    return Hive.box(boxName).get(_seenKey, defaultValue: false) as bool;
  }

  /// Records that onboarding is complete so it never shows again.
  Future<void> markOnboardingSeen() async {
    if (!Hive.isBoxOpen(boxName)) return;
    await Hive.box(boxName).put(_seenKey, true);
  }
}
