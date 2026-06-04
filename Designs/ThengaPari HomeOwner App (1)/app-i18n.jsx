// app-i18n.jsx — bilingual strings (English + Malayalam) and crop data
// t(key, lang) returns a string. STR[key].ml is the Malayalam form used both
// for full-Malayalam mode and for the optional subtitle under English labels.

const STR = {
  // greeting / home
  greet_morning:   { en: 'Good morning',        ml: 'സുപ്രഭാതം' },
  greet_afternoon: { en: 'Good afternoon',      ml: 'നമസ്കാരം' },
  greet_evening:   { en: 'Good evening',        ml: 'ശുഭ സന്ധ്യ' },
  greet_sub:       { en: 'Your grove is calm and cared for today.', ml: 'നിങ്ങളുടെ തോട്ടം ഇന്ന് സുരക്ഷിതമാണ്.' },
  your_crops:      { en: 'Your crops',           ml: 'നിങ്ങളുടെ വിളകൾ' },
  ready_to_pick:   { en: 'ready to pick',        ml: 'പറിക്കാൻ തയ്യാർ' },
  yield_earned:    { en: 'Yield earned',         ml: 'വിളവ് വരുമാനം' },
  weight_saved:    { en: 'Weight saved',         ml: 'ഭാരം ലാഭിച്ചു' },
  this_season:     { en: 'this season',          ml: 'ഈ സീസണിൽ' },
  vs_market:       { en: 'vs. market scale',     ml: 'മാർക്കറ്റ് തൂക്കത്തേക്കാൾ' },
  weekly_earnings: { en: 'Weekly earnings',      ml: 'പ്രതിവാര വരുമാനം' },
  active_job:      { en: 'Active harvest',       ml: 'നടന്നുകൊണ്ടിരിക്കുന്ന വിളവെടുപ്പ്' },
  in_progress:     { en: 'In progress',          ml: 'നടന്നുകൊണ്ടിരിക്കുന്നു' },
  done_pct:        { en: 'done',                 ml: 'പൂർത്തിയായി' },
  away:            { en: 'away',                  ml: 'അകലെ' },
  track:           { en: 'Track',                ml: 'ട്രാക്ക്' },

  // nav
  nav_home:        { en: 'Home',                 ml: 'ഹോം' },
  nav_schedule:    { en: 'Schedule',             ml: 'ഷെഡ്യൂൾ' },
  nav_reports:     { en: 'Reports',              ml: 'റിപ്പോർട്ട്' },
  nav_profile:     { en: 'Profile',              ml: 'പ്രൊഫൈൽ' },

  // book
  book_harvest:    { en: 'Book a harvest',       ml: 'വിളവെടുപ്പ് ബുക്ക് ചെയ്യുക' },
  pick_crop:       { en: 'What should we pick?',  ml: 'എന്ത് പറിക്കണം?' },
  when:            { en: 'When works for you?',   ml: 'എപ്പോൾ സൗകര്യം?' },
  whats_ready:     { en: "What's ready",          ml: 'എന്ത് തയ്യാർ' },
  ripe_only:       { en: 'Ripe only',            ml: 'പാകമായവ മാത്രം' },
  all:             { en: 'All',                  ml: 'എല്ലാം' },
  est_yield:       { en: 'Estimated yield',      ml: 'പ്രതീക്ഷിത വിളവ്' },
  est_earning:     { en: 'Estimated earning',    ml: 'പ്രതീക്ഷിത വരുമാനം' },
  preview_note:    { en: 'A site manager confirms the final count on arrival.', ml: 'സൈറ്റ് മാനേജർ എത്തുമ്പോൾ അന്തിമ എണ്ണം ഉറപ്പാക്കും.' },
  confirm_booking: { en: 'Confirm booking',      ml: 'ബുക്കിംഗ് സ്ഥിരീകരിക്കുക' },
  nuts:            { en: 'nuts',                 ml: 'കായ്കൾ' },
  today:           { en: 'Today',                ml: 'ഇന്ന്' },
  tomorrow:        { en: 'Tomorrow',             ml: 'നാളെ' },

  // confirm
  booked_title:    { en: "You're all set",       ml: 'എല്ലാം തയ്യാറായി' },
  booked_sub:      { en: 'A trusted site manager will arrive and keep you updated at every step.', ml: 'വിശ്വസ്ത സൈറ്റ് മാനേജർ എത്തി ഓരോ ഘട്ടവും അറിയിക്കും.' },
  crop_label:      { en: 'Crop',                 ml: 'വിള' },
  date_label:      { en: 'Date',                 ml: 'തീയതി' },
  est_label:       { en: 'Est. earning',         ml: 'പ്രതീക്ഷിത വരുമാനം' },
  view_tracker:    { en: 'View live tracker',    ml: 'ലൈവ് ട്രാക്കർ കാണുക' },

  // tracker
  live_job:        { en: 'Live harvest',         ml: 'ലൈവ് വിളവെടുപ്പ്' },
  step_assigned:   { en: 'Assigned',             ml: 'നിയോഗിച്ചു' },
  step_arrived:    { en: 'Arrived',              ml: 'എത്തി' },
  step_harvest:    { en: 'Harvesting',           ml: 'വിളവെടുപ്പ്' },
  step_weighing:   { en: 'Weighing',             ml: 'തൂക്കുന്നു' },
  step_done:       { en: 'Settled',              ml: 'തീർന്നു' },
  worker_enroute:  { en: 'Site manager en route', ml: 'സൈറ്റ് മാനേജർ വരുന്നു' },
  live_weight:     { en: 'Live weight',          ml: 'തത്സമയ ഭാരം' },
  weighed_now:     { en: 'weighed so far',       ml: 'ഇതുവരെ തൂക്കിയത്' },
  site_photos:     { en: 'Site photos',          ml: 'സൈറ്റ് ഫോട്ടോകൾ' },
  live:            { en: 'LIVE',                 ml: 'ലൈവ്' },
  call:            { en: 'Call',                 ml: 'വിളിക്കുക' },
  message:         { en: 'Message',              ml: 'സന്ദേശം' },

  // report
  yield_report:    { en: 'Yield report',         ml: 'വിളവ് റിപ്പോർട്ട്' },
  grade_breakdown: { en: 'Grade breakdown',      ml: 'ഗ്രേഡ് വിഭജനം' },
  total_nuts:      { en: 'total nuts',           ml: 'ആകെ കായ്കൾ' },
  grade_a:         { en: 'Grade A',              ml: 'ഗ്രേഡ് എ' },
  grade_b:         { en: 'Grade B',              ml: 'ഗ്രേഡ് ബി' },
  tender:          { en: 'Tender',               ml: 'കരിക്ക്' },
  byproduct_title: { en: 'Husk & fronds routed to coir unit', ml: 'തൊണ്ടും ഓലയും കയർ യൂണിറ്റിലേക്ക്' },
  byproduct_sub:   { en: 'Nothing wasted — you earn a little extra on byproduct.', ml: 'ഒന്നും പാഴാകുന്നില്ല — ഉപോൽപ്പന്നത്തിൽ നിന്നും അധിക വരുമാനം.' },
  earnings_break:  { en: 'Earnings breakdown',   ml: 'വരുമാന വിശദാംശം' },
  harvest_value:   { en: 'Harvest value',        ml: 'വിളവ് മൂല്യം' },
  byproduct_credit:{ en: 'Byproduct credit',     ml: 'ഉപോൽപ്പന്ന ക്രെഡിറ്റ്' },
  service_fee:     { en: 'Service fee',          ml: 'സേവന ഫീസ്' },
  net_payout:      { en: 'Net payout',           ml: 'അറ്റ വരുമാനം' },
  share_whatsapp:  { en: 'Share on WhatsApp',    ml: 'വാട്ട്‌സ്ആപ്പിൽ പങ്കിടുക' },
  paid_to:         { en: 'Paid to your UPI · ',  ml: 'നിങ്ങളുടെ UPI-ലേക്ക് · ' },

  // schedule / profile (supporting)
  upcoming:        { en: 'Upcoming',             ml: 'വരാനിരിക്കുന്നവ' },
  past_harvests:   { en: 'Past harvests',        ml: 'കഴിഞ്ഞ വിളവെടുപ്പുകൾ' },
  scheduled:       { en: 'Scheduled',            ml: 'ഷെഡ്യൂൾ ചെയ്തു' },
  completed:       { en: 'Completed',            ml: 'പൂർത്തിയായി' },
  my_grove:        { en: 'My grove',             ml: 'എന്റെ തോട്ടം' },
  trees_registered:{ en: 'trees registered',     ml: 'മരങ്ങൾ രജിസ്റ്റർ ചെയ്തു' },
  payouts:         { en: 'Payouts & UPI',        ml: 'പേഔട്ടും UPI-യും' },
  help:            { en: 'Help & support',       ml: 'സഹായം' },
  language_set:    { en: 'Language',             ml: 'ഭാഷ' },
  back:            { en: 'Back',                 ml: 'തിരികെ' },
  see_all:         { en: 'See all',              ml: 'എല്ലാം കാണുക' },
};

function t(key, lang) {
  const e = STR[key];
  if (!e) return key;
  return (lang === 'ml' ? e.ml : e.en) || e.en;
}
function tml(key) { return (STR[key] && STR[key].ml) || ''; }

// crops — glyph drawn by Icon(crop.icon). tint is the tile background.
const CROPS = [
  { id: 'coconut', icon: 'coconut', name: { en: 'Coconut', ml: 'തേങ്ങ' }, count: 24, unit: 'nuts',
    tint: '#E6EFD9', fg: '#1E4D2B', ready: 24, rate: 16, ripe: true, weightKg: 0.9 },
  { id: 'mango',   icon: 'mango',   name: { en: 'Mango',   ml: 'മാങ്ങ' }, count: 8,  unit: 'kg',
    tint: '#FCEBCB', fg: '#B86A06', ready: 6, rate: 95, ripe: true, weightKg: 1 },
  { id: 'pepper',  icon: 'pepper',  name: { en: 'Pepper',  ml: 'കുരുമുളക്' }, count: 2, unit: 'kg',
    tint: '#ECF3E0', fg: '#4C7A3C', ready: 0, rate: 480, ripe: false, weightKg: 1 },
  { id: 'banana',  icon: 'banana',  name: { en: 'Banana',  ml: 'ഏത്തക്കായ' }, count: 3, unit: 'bunch',
    tint: '#FCEBCB', fg: '#B86A06', ready: 2, rate: 240, ripe: true, weightKg: 12 },
  { id: 'areca',   icon: 'areca',   name: { en: 'Areca',   ml: 'അടയ്ക്ക' }, count: 12, unit: 'kg',
    tint: '#E6EFD9', fg: '#1E4D2B', ready: 9, rate: 310, ripe: false, weightKg: 1 },
  { id: 'jackfruit',icon: 'jackfruit',name:{ en: 'Jackfruit', ml: 'ചക്ക' }, count: 4, unit: 'fruit',
    tint: '#ECF3E0', fg: '#4C7A3C', ready: 3, rate: 70, ripe: true, weightKg: 8 },
];
const cropById = (id) => CROPS.find((c) => c.id === id) || CROPS[0];

// weekly earnings — value in ₹, last bar is the highlighted peak
const WEEK = [
  { d: { en: 'M', ml: 'തി' }, v: 520 },
  { d: { en: 'T', ml: 'ചൊ' }, v: 760 },
  { d: { en: 'W', ml: 'ബു' }, v: 610 },
  { d: { en: 'T', ml: 'വ്യ' }, v: 980 },
  { d: { en: 'F', ml: 'വെ' }, v: 700 },
  { d: { en: 'S', ml: 'ശ' }, v: 1280, peak: true },
];

Object.assign(window, { STR, t, tml, CROPS, cropById, WEEK });
