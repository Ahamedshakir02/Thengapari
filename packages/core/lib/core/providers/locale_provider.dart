import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/app_strings.dart';

/// App-wide UI language. Changing it updates [gAppLang] (so [AppText] picks the
/// Malayalam font) and notifies watchers so screens rebuild with translations.
class LocaleNotifier extends Notifier<AppLang> {
  @override
  AppLang build() {
    gAppLang = AppLang.en;
    return AppLang.en;
  }

  void set(AppLang lang) {
    gAppLang = lang;
    state = lang;
  }

  void toggle() => set(state == AppLang.en ? AppLang.ml : AppLang.en);
}

final localeProvider =
    NotifierProvider<LocaleNotifier, AppLang>(LocaleNotifier.new);
