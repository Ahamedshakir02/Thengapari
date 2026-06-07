import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/onboarding_service.dart';

/// Single shared [OnboardingService] instance.
final onboardingServiceProvider =
    Provider<OnboardingService>((ref) => OnboardingService());

/// Whether onboarding has been seen. Initialised synchronously from the Hive
/// flag so the router can read it during its first redirect; [complete] flips
/// it and persists, which re-runs router redirects (it is bridged into
/// GoRouter's `refreshListenable`).
class OnboardingSeenNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(onboardingServiceProvider).hasSeenOnboarding;

  /// Marks onboarding finished: persists the flag and updates state.
  Future<void> complete() async {
    await ref.read(onboardingServiceProvider).markOnboardingSeen();
    state = true;
  }
}

final onboardingSeenProvider =
    NotifierProvider<OnboardingSeenNotifier, bool>(OnboardingSeenNotifier.new);
