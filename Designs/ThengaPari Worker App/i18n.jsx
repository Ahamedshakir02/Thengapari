// i18n.jsx — bilingual labels (English / Malayalam) for the worker app.
// Language tweak: 'en' | 'both' | 'ml'.  tx() returns { primary, secondary }.

const STR = {
  greeting:      { en: "Good morning, Ravi", ml: "സുപ്രഭാതം, രവി" },
  location:      { en: "Ollur, Thrissur",    ml: "ഒല്ലൂർ, തൃശൂർ" },
  online:        { en: "You're online",       ml: "നിങ്ങൾ ഓൺലൈനാണ്" },
  online_sub:    { en: "Receiving job pings", ml: "ജോലികൾ ലഭിക്കുന്നു" },
  offline:       { en: "You're offline",      ml: "നിങ്ങൾ ഓഫ്‌ലൈനാണ്" },
  offline_sub:   { en: "Go online to earn",   ml: "ഓൺലൈനായി പണം നേടൂ" },
  goOnline:      { en: "Go online",           ml: "ഓൺലൈൻ ആകൂ" },
  earnings_today:{ en: "Today's earnings",    ml: "ഇന്നത്തെ വരുമാനം" },
  jobs_done:     { en: "Jobs completed",      ml: "പൂർത്തിയാക്കിയ ജോലികൾ" },
  reliability:   { en: "Reliability score",   ml: "വിശ്വാസ്യത സ്കോർ" },
  reliability_sub:{ en: "Top 8% of climbers in Thrissur", ml: "തൃശൂരിലെ മികച്ച 8% കയറ്റക്കാർ" },
  today_jobs:    { en: "Today's confirmed jobs", ml: "ഇന്ന് ഉറപ്പിച്ച ജോലികൾ" },
  weekly:        { en: "This week",           ml: "ഈ ആഴ്ച" },
  weekly_sub:    { en: "Earnings, Mon–Sun",   ml: "വരുമാനം, തിങ്കൾ–ഞായർ" },
  newping:       { en: "New job ping",        ml: "പുതിയ ജോലി" },
  husking:       { en: "Coconut husking needed", ml: "തേങ്ങ പൊതിക്കൽ വേണം" },
  payout:        { en: "Payout",              ml: "പ്രതിഫലം" },
  duration:      { en: "Duration",            ml: "സമയം" },
  distance:      { en: "Distance",            ml: "ദൂരം" },
  crop:          { en: "Crop",                ml: "വിള" },
  coconuts:      { en: "24 coconuts",         ml: "24 തേങ്ങ" },
  manager:       { en: "Site manager",        ml: "സൈറ്റ് മാനേജർ" },
  respond_in:    { en: "Respond within",      ml: "ഇതിനുള്ളിൽ മറുപടി" },
  decline:       { en: "Decline",             ml: "വേണ്ട" },
  accept:        { en: "Accept job",          ml: "സ്വീകരിക്കൂ" },
  waiting:       { en: "Listening for jobs nearby", ml: "അടുത്തുള്ള ജോലികൾ കണ്ടെത്തുന്നു" },
  navigate:      { en: "On the way",          ml: "വഴിയിലാണ്" },
  arrive_by:     { en: "Arrive by",           ml: "എത്തേണ്ട സമയം" },
  head_to:       { en: "Head to the grove",   ml: "തോട്ടത്തിലേക്ക് പോകൂ" },
  arrived:       { en: "I've arrived",        ml: "ഞാൻ എത്തി" },
  call:          { en: "Call",                ml: "വിളിക്കൂ" },
  complete:      { en: "Job complete",        ml: "ജോലി പൂർത്തിയായി" },
  paid_to:       { en: "sent to",             ml: "അയച്ചു" },
  paid_via:      { en: "Paid instantly via UPI", ml: "UPI വഴി ഉടൻ പണം" },
  summary:       { en: "Job summary",         ml: "ജോലി വിവരം" },
  rate_mgr:      { en: "Rate the site manager", ml: "മാനേജറെ വിലയിരുത്തൂ" },
  rate_sub:      { en: "How was working with Arjun?", ml: "അർജുനൊപ്പം ജോലി എങ്ങനെയായിരുന്നു?" },
  submit_home:   { en: "Submit & go home",    ml: "സമർപ്പിച്ച് വീട്ടിലേക്ക്" },
  skip:          { en: "Skip for now",        ml: "ഇപ്പോൾ വേണ്ട" },
  nav_home:      { en: "Home",  ml: "ഹോം" },
  nav_jobs:      { en: "Jobs",  ml: "ജോലികൾ" },
  nav_earn:      { en: "Wallet",ml: "വാലറ്റ്" },
  nav_you:       { en: "You",   ml: "നിങ്ങൾ" },

  /* ---------- Jobs screen ---------- */
  jobs_title:    { en: "Your jobs",           ml: "നിങ്ങളുടെ ജോലികൾ" },
  jobs_sub:      { en: "Upcoming & completed work", ml: "വരാനുള്ളതും കഴിഞ്ഞതും" },
  tab_upcoming:  { en: "Upcoming",            ml: "വരാനുള്ളവ" },
  tab_history:   { en: "History",             ml: "പൂർത്തിയായവ" },
  jobs_today:    { en: "Today",               ml: "ഇന്ന്" },
  jobs_tomorrow: { en: "Tomorrow",            ml: "നാളെ" },
  open_route:    { en: "Open route",          ml: "വഴി തുറക്കൂ" },
  earned_week:   { en: "Earned this week",    ml: "ഈ ആഴ്ച നേടിയത്" },
  done_week:     { en: "Jobs this week",      ml: "ഈ ആഴ്ചത്തെ ജോലികൾ" },
  rated:         { en: "You rated",           ml: "നിങ്ങൾ നൽകി" },

  /* ---------- Wallet screen ---------- */
  wallet_title:  { en: "Wallet",              ml: "വാലറ്റ്" },
  balance:       { en: "Available balance",   ml: "ലഭ്യമായ ബാലൻസ്" },
  withdraw:      { en: "Withdraw to UPI",     ml: "UPI-ലേക്ക് പിൻവലിക്കൂ" },
  pending_pay:   { en: "Pending payout",      ml: "തീർപ്പാക്കാത്ത തുക" },
  in_week:       { en: "This week",           ml: "ഈ ആഴ്ച" },
  payouts:       { en: "Recent payouts",      ml: "സമീപകാല പണമിടപാടുകൾ" },
  linked_upi:    { en: "Linked UPI",          ml: "ലിങ്ക് ചെയ്ത UPI" },
  withdraw_amt:  { en: "Amount to withdraw",  ml: "പിൻവലിക്കേണ്ട തുക" },
  send_to:       { en: "Sent instantly to",   ml: "ഉടൻ അയക്കുന്നു" },
  no_fee:        { en: "Instant · no fee",    ml: "ഉടൻ · ഫീസ് ഇല്ല" },
  confirm_wd:    { en: "Withdraw",            ml: "പിൻവലിക്കൂ" },
  wd_done:       { en: "Money on the way",    ml: "പണം അയച്ചു" },
  wd_done_sub:   { en: "Reaching your bank in seconds", ml: "നിമിഷങ്ങൾക്കകം ബാങ്കിൽ" },
  done_btn:      { en: "Done",                ml: "ശരി" },
  add_money_note:{ en: "Auto-paid after each job", ml: "ഓരോ ജോലിക്കും ശേഷം" },

  /* ---------- Profile screen ---------- */
  profile_title: { en: "Profile",             ml: "പ്രൊഫൈൽ" },
  verified_climber:{ en: "Verified climber",  ml: "പരിശോധിച്ച കയറ്റക്കാരൻ" },
  member_since:  { en: "With ThengaPari since", ml: "ThengaPari-യിൽ" },
  lifetime:      { en: "Lifetime earnings",   ml: "ആകെ വരുമാനം" },
  total_jobs:    { en: "Jobs done",           ml: "ജോലികൾ" },
  avg_rating:    { en: "Avg. rating",         ml: "ശരാശരി റേറ്റിംഗ്" },
  skills:        { en: "Skills",              ml: "വൈദഗ്ധ്യം" },
  skills_sub:    { en: "What you're trained for", ml: "നിങ്ങളുടെ പരിശീലനം" },
  documents:     { en: "Documents & KYC",     ml: "രേഖകൾ & KYC" },
  docs_sub:      { en: "Verification status", ml: "പരിശോധനാ നില" },
  aadhaar:       { en: "Aadhaar identity",    ml: "ആധാർ തിരിച്ചറിയൽ" },
  bank_acc:      { en: "Bank account",        ml: "ബാങ്ക് അക്കൗണ്ട്" },
  police_v:      { en: "Police verification", ml: "പോലീസ് പരിശോധന" },
  insurance:     { en: "Accident cover",      ml: "അപകട പരിരക്ഷ" },
  verified_s:    { en: "Verified",            ml: "പരിശോധിച്ചു" },
  active_s:      { en: "Active",              ml: "സജീവം" },
  settings:      { en: "Settings",            ml: "ക്രമീകരണങ്ങൾ" },
  set_language:  { en: "App language",        ml: "ആപ്പ് ഭാഷ" },
  set_notif:     { en: "Notifications",       ml: "അറിയിപ്പുകൾ" },
  set_help:      { en: "Help & support",      ml: "സഹായം" },
  set_logout:    { en: "Log out",             ml: "ലോഗ് ഔട്ട്" },
  skill_climb:   { en: "Coconut climbing",    ml: "തെങ്ങുകയറ്റം" },
  skill_husk:    { en: "Coconut husking",     ml: "തേങ്ങ പൊതിക്കൽ" },
  skill_trim:    { en: "Palm trimming",       ml: "പന വെട്ടൽ" },
  skill_tender:  { en: "Tender coconut",      ml: "കരിക്ക് വിളവെടുപ്പ്" },
  lvl_expert:    { en: "Expert",              ml: "വിദഗ്ധൻ" },
  lvl_skilled:   { en: "Skilled",             ml: "നൈപുണ്യം" },
  lvl_learning:  { en: "Learning",            ml: "പഠിക്കുന്നു" },
};

function tx(lang, key) {
  const e = STR[key];
  if (!e) return { primary: key, secondary: null };
  if (lang === 'en') return { primary: e.en, secondary: null };
  if (lang === 'ml') return { primary: e.ml, secondary: e.en };
  return { primary: e.en, secondary: e.ml }; // both
}

// <Bi> — primary line + optional secondary caption, themed.
function Bi({ lang, k, primaryStyle, subStyle, primaryClass, gap = 2 }) {
  const { primary, secondary } = tx(lang, k);
  const primIsMl = lang === 'ml';
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap, minWidth: 0 }}>
      <span className={(primaryClass || '') + (primIsMl ? ' ml' : '')} style={primaryStyle}>{primary}</span>
      {secondary && (
        <span className={lang === 'ml' ? '' : 'ml'} style={{ font: 'var(--t-caption)', color: 'var(--w-fg3)', ...subStyle }}>{secondary}</span>
      )}
    </div>
  );
}

Object.assign(window, { STR, tx, Bi });
