import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/app_strings.dart';

/// App-wide UI language. Changing it updates [gAppLang] (so [AppText] picks the
/// Malayalam font) and notifies watchers so screens rebuild with translations.
class LocaleNotifier extends Notifier<AppLang> {
  @override
  AppLang build() {
    // Respect the app's seed (e.g. the worker app defaults gAppLang to
    // AppLang.both in main()); apps that don't seed it start in English.
    return gAppLang;
  }

  void set(AppLang lang) {
    gAppLang = lang;
    state = lang;
  }

  /// Cycles English → മലയാളം → Both → English.
  void toggle() => set(switch (state) {
        AppLang.en => AppLang.ml,
        AppLang.ml => AppLang.both,
        AppLang.both => AppLang.en,
      });
}

final localeProvider =
    NotifierProvider<LocaleNotifier, AppLang>(LocaleNotifier.new);
