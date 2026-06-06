import '../models/tree_inventory.dart';

/// Supported UI languages.
enum AppLang { en, ml }

/// Global mirror of the active language, kept in sync by the locale notifier.
/// [AppText] reads this to pick a Malayalam-capable font without needing a
/// BuildContext. UI strings should still come from [tr] (which takes the lang
/// explicitly so widgets rebuild via the provider).
AppLang gAppLang = AppLang.en;

/// English + Malayalam strings, ported from the design's `app-i18n.jsx`.
/// `[en, ml]`.
const Map<String, List<String>> _strings = {
  'greet_morning': ['Good morning', 'സുപ്രഭാതം'],
  'greet_afternoon': ['Good afternoon', 'നമസ്കാരം'],
  'greet_evening': ['Good evening', 'ശുഭ സന്ധ്യ'],
  'greet_sub': ['Your grove is looking healthy', 'നിങ്ങളുടെ തോട്ടം ഇന്ന് സുരക്ഷിതമാണ്.'],
  'your_crops': ['Your crops', 'നിങ്ങളുടെ വിളകൾ'],
  'yield_earned': ['Yield earned', 'വിളവ് വരുമാനം'],
  'weight_saved': ['Weight saved', 'ഭാരം ലാഭിച്ചു'],
  'this_season': ['+12% this season', '+12% ഈ സീസണിൽ'],
  'vs_market': ['vs market', 'മാർക്കറ്റിനെക്കാൾ'],
  'weekly_earnings': ['Weekly earnings', 'പ്രതിവാര വരുമാനം'],
  'active_job': ['Active job', 'നടന്നുകൊണ്ടിരിക്കുന്ന ജോലി'],
  'book_harvest': ['Book a harvest', 'വിളവെടുപ്പ് ബുക്ക് ചെയ്യുക'],
  'site_manager_assigned': ['Site Manager assigned', 'സൈറ്റ് മാനേജരെ നിയോഗിച്ചു'],
  'finding_manager': ['Finding a site manager…', 'സൈറ്റ് മാനേജരെ കണ്ടെത്തുന്നു…'],
  'no_active_harvest': ['No active harvest. Book one to get started.',
      'സജീവ വിളവെടുപ്പില്ല. തുടങ്ങാൻ ഒന്ന് ബുക്ക് ചെയ്യൂ.'],
  'no_trees': ['No trees yet — add them from your profile.',
      'മരങ്ങളൊന്നുമില്ല — പ്രൊഫൈലിൽ നിന്ന് ചേർക്കൂ.'],

  // nav
  'nav_home': ['Home', 'ഹോം'],
  'nav_schedule': ['Schedule', 'ഷെഡ്യൂൾ'],
  'nav_reports': ['Reports', 'റിപ്പോർട്ട്'],
  'nav_profile': ['Profile', 'പ്രൊഫൈൽ'],
};

/// Returns the string for [key] in [lang]; falls back to English, then the key.
String tr(String key, AppLang lang) {
  final e = _strings[key];
  if (e == null) return key;
  return lang == AppLang.ml ? e[1] : e[0];
}

/// Localised crop name.
String cropName(CropType type, AppLang lang) {
  if (lang == AppLang.en) return type.label;
  return switch (type) {
    CropType.coconut => 'തേങ്ങ',
    CropType.mango => 'മാങ്ങ',
    CropType.jackfruit => 'ചക്ക',
    CropType.pepper => 'കുരുമുളക്',
    CropType.areca => 'അടയ്ക്ക',
  };
}
