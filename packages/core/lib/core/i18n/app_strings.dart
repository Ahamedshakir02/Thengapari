import '../models/tree_inventory.dart';

/// Supported UI languages. [both] renders English as the primary string with a
/// Malayalam secondary line (the worker app's default, per the worker design's
/// "Both" language mode).
enum AppLang { en, ml, both }

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

  // ===== Auth flow (onboarding / welcome / phone / OTP) — from i18n.js =====
  'auth_brand': ['ThengaPari', 'ThengaPari'],
  'auth_skip': ['Skip', 'ഒഴിവാക്കുക'],
  'auth_next': ['Next', 'അടുത്തത്'],
  'auth_get_started': ['Get started', 'തുടങ്ങാം'],

  'onb1_h': ['Turn your backyard trees into income',
      'നിങ്ങളുടെ മുറ്റത്തെ മരങ്ങൾ വരുമാനമാക്കൂ'],
  'onb1_s': ['List your coconut palms and mango trees — we handle the rest.',
      'നിങ്ങളുടെ തെങ്ങും മാവും ചേർക്കൂ — ബാക്കിയെല്ലാം ഞങ്ങൾ നോക്കും.'],
  'onb2_h': ['Same-day harvest, zero coordination',
      'അന്നുതന്നെ വിളവെടുപ്പ്, ഏകോപനം വേണ്ട'],
  'onb2_s': ['Book in under a minute. A trained climber arrives and gets it done.',
      'ഒരു മിനിറ്റിൽ ബുക്ക് ചെയ്യൂ. പരിശീലനം ലഭിച്ച കയറ്റക്കാരൻ എത്തി ജോലി തീർക്കും.'],
  'onb3_h': ['Get paid, get a clear report',
      'പണം നേടൂ, വ്യക്തമായ റിപ്പോർട്ടും'],
  'onb3_s': ['Pay after weighing. Every job ends with a tidy, honest receipt.',
      'തൂക്കത്തിന് ശേഷം പണം നൽകൂ. ഓരോ ജോലിക്കും വൃത്തിയുള്ള, സത്യസന്ധമായ രസീത്.'],

  'welcome_tagline': ['Your trees, harvested with care — and paid fairly.',
      'നിങ്ങളുടെ മരങ്ങൾ കരുതലോടെ വിളവെടുക്കാം — ന്യായമായ വിലയും.'],
  'welcome_ml': ["Kerala's own harvest companion",
      'കേരളത്തിന്റെ സ്വന്തം വിളവെടുപ്പ് കൂട്ടാളി'],
  'auth_terms': ['By continuing you agree to our Terms & Privacy Policy.',
      'തുടരുന്നതിലൂടെ ഞങ്ങളുടെ നിബന്ധനകളും സ്വകാര്യതാ നയവും അംഗീകരിക്കുന്നു.'],

  'phone_head': ['Sign in with your mobile number',
      'നിങ്ങളുടെ മൊബൈൽ നമ്പർ ഉപയോഗിച്ച് സൈൻ ഇൻ ചെയ്യൂ'],
  'phone_lead': ["We'll send a one-time code to confirm it's really you.",
      'നിങ്ങളെ സ്ഥിരീകരിക്കാൻ ഒറ്റത്തവണ കോഡ് അയക്കും.'],
  'phone_label': ['Mobile number', 'മൊബൈൽ നമ്പർ'],
  'auth_reassure': ["We'll send a one-time code — standard SMS rates may apply.",
      'ഒറ്റത്തവണ കോഡ് അയക്കും — സാധാരണ SMS നിരക്ക് ബാധകമാകാം.'],
  'auth_send_otp': ['Send OTP', 'OTP അയക്കൂ'],

  'otp_head': ['Enter the 6-digit code', '6 അക്ക കോഡ് നൽകൂ'],
  'otp_sent_to': ['Sent to', 'അയച്ചത്'],
  'otp_edit': ['Change', 'മാറ്റുക'],
  'otp_verify': ['Verify', 'സ്ഥിരീകരിക്കൂ'],
  'otp_resend_in': ['Resend code in', 'വീണ്ടും അയക്കാൻ'],
  'otp_resend': ['Resend code', 'കോഡ് വീണ്ടും അയക്കൂ'],
  'otp_error': ["That code didn't match. Please try again.",
      'കോഡ് ശരിയായില്ല. വീണ്ടും ശ്രമിക്കൂ.'],
  'otp_resent': ['A fresh code is on its way.',
      'പുതിയ കോഡ് അയച്ചുകൊണ്ടിരിക്കുന്നു.'],

  // ===== Worker app (from the worker design's i18n.jsx) =====
  'online': ["You're online", 'നിങ്ങൾ ഓൺലൈനാണ്'],
  'online_sub': ['Receiving job pings', 'ജോലികൾ ലഭിക്കുന്നു'],
  'offline': ["You're offline", 'നിങ്ങൾ ഓഫ്‌ലൈനാണ്'],
  'offline_sub': ['Go online to earn', 'ഓൺലൈനായി പണം നേടൂ'],
  'today_jobs': ["Today's confirmed jobs", 'ഇന്ന് ഉറപ്പിച്ച ജോലികൾ'],
  'weekly': ['This week', 'ഈ ആഴ്ച'],
  'payouts': ['Recent payouts', 'സമീപകാല പണമിടപാടുകൾ'],
};

/// Returns the string for [key] in [lang]; falls back to English, then the key.
/// [AppLang.both] resolves to English — the Malayalam secondary line comes from
/// [trMl].
String tr(String key, AppLang lang) {
  final e = _strings[key];
  if (e == null) return key;
  return lang == AppLang.ml ? e[1] : e[0];
}

/// Returns the Malayalam string for [key] (secondary line in
/// [AppLang.both] mode); falls back to the key.
String trMl(String key) {
  final e = _strings[key];
  return e == null ? key : e[1];
}

/// Localised crop name.
String cropName(CropType type, AppLang lang) {
  if (lang != AppLang.ml) return type.label;
  return switch (type) {
    CropType.coconut => 'തേങ്ങ',
    CropType.mango => 'മാങ്ങ',
    CropType.jackfruit => 'ചക്ക',
    CropType.pepper => 'കുരുമുളക്',
    CropType.areca => 'അടയ്ക്ക',
    CropType.banana => 'നേന്ത്രപ്പഴം',
  };
}
