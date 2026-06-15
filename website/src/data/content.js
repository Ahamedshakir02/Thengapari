// ─────────────────────────────────────────────────────────────────────────────
// All landing-page copy lives here (English).
// Malayalam (ml) is the second language for Kerala. To localize later, add an
// `ml:` string beside each `en:` value and a language toggle (Noto Sans
// Malayalam is already loaded). `// ML:` notes mark where a translation slots in.
// ─────────────────────────────────────────────────────────────────────────────

export const brand = {
  name: 'ThengaPari',
  nameMl: 'തേങ്ങാപ്പറി', // ML: brand name in Malayalam (already bilingual in the mark)
  email: 'hello@thengapari.in',
  phone: '+91 484 000 0000',
  location: 'Kochi · Kerala · India',
};

// External links — swap the Play Store URL for the real listing when published.
export const links = {
  playStore: import.meta.env.VITE_PLAY_STORE_URL || 'https://play.google.com/store/apps/details?id=in.thengapari',
  appStore: import.meta.env.VITE_APP_STORE_URL || '', // App Store badge stays "coming soon" until set
};

export const nav = [
  { href: '#problem', label: 'The problem' }, // ML: "പ്രശ്നം"
  { href: '#how', label: 'How it works' },
  { href: '#who', label: "Who it's for" },
  { href: '#zerowaste', label: 'Zero-waste' },
  { href: '#traction', label: 'Traction' },
];

export const hero = {
  overline: 'Hyperlocal harvest marketplace · Kerala',
  // ML: "നിങ്ങളുടെ മുറ്റത്തെ മരങ്ങൾ വരുമാനമാക്കൂ."
  titleLead: 'Turn your backyard trees into ',
  titleHighlight: 'income.',
  sub: 'Harvested, processed, and sold — all coordinated for you. ThengaPari brings a site manager, trained climbers and a fair price to your gate, and pays you the same day.',
  trust: ['No upfront cost', 'Same-day payout', 'You keep the value'],
};

export const problem = {
  overline: 'The problem',
  title: 'When trees become a chore, value rots on the ground.',
  sub: 'A Kerala home can have a dozen coconut palms, a jackfruit and a couple of mango trees — and still treat the harvest as a headache. Here’s where the money leaks.',
  cards: [
    {
      icon: 'monkey',
      title: 'Trees become liabilities',
      body: 'Overgrown palms drop nuts on roofs, cars and neighbours. Climbers are scarce, and the panchayat still expects them cleared.',
      tag: 'Risk & nuisance',
    },
    {
      icon: 'calendar',
      title: 'Coordination chaos',
      body: 'Chasing climbers by phone, no-shows on harvest day, haggling over cash and waiting weeks for a free slot. Nobody owns the job.',
      tag: 'Wasted time',
    },
    {
      icon: 'scale',
      title: 'The "weight-loss" leak',
      body: 'Coconuts dry and lose weight between gate and trader. Middlemen re-weigh and re-grade — and the homeowner silently eats the loss.',
      tag: 'Revenue lost',
    },
    {
      icon: 'chart',
      title: 'Gig income that swings',
      body: 'Skilled climbers are paid per tree, seasonally, with no insurance and idle weeks. A dangerous job with the least stable pay.',
      tag: 'Unstable work',
    },
  ],
};

export const how = {
  overline: 'How it works',
  title: 'One booking. We run the whole harvest.',
  sub: 'From a single tap to money in your account — four steps, fully coordinated, usually wrapped up the same day.',
  steps: [
    { icon: 'book', title: 'Book it', body: 'Tap to request a harvest. Tell us your trees and pick a date — or let us suggest the next slot near you.' },
    { icon: 'manager', title: 'A site manager runs it', body: 'A trained, local Site Manager owns your job — confirming the team, equipment and a fair, transparent quote.' },
    { icon: 'tree', title: 'Harvested & processed', body: 'The crew climbs, harvests and de-husks on the spot — weighed in front of you, same day, nothing left behind.' },
    { icon: 'rupee', title: 'Paid + a clear report', body: 'Money lands in your account the same day, with an itemised report: weights, grades, price and what became of every byproduct.' },
  ],
};

export const who = {
  overline: "Who it's for",
  title: 'One marketplace, four ways to win.',
  sub: 'ThengaPari connects the people who own the trees, the people who climb them, the students who run the show, and the businesses who buy the produce.',
  tiles: [
    { variant: 't-home', art: 'house', role: 'Homeowners', title: 'Money, not maintenance', body: 'Idle trees become reliable income — no chasing climbers, no haggling, no falling-coconut worries.', cta: 'Get started', intent: 'homeowner' },
    { variant: 't-work', art: 'worker', role: 'Gig workers', title: 'Steady, safer work', body: 'Climbers and processors get scheduled jobs, fair per-day pay, gear and cover — not feast-or-famine seasons.', cta: 'Join as a worker', intent: 'general' },
    { variant: 't-mgr', art: 'manager', role: 'Student site managers', title: 'Run a real operation', body: 'Students earn and lead — managing crews, quality and customers, building a track record that actually pays.', cta: 'Manage harvests', intent: 'general' },
    { variant: 't-biz', art: 'business', role: 'Local businesses', title: 'Traceable supply, on tap', body: 'Mills, oil units and dairies get graded, weight-true produce with a digital trail — sourced from verified neighbourhoods.', cta: 'Source from us', intent: 'business' },
  ],
};

export const zero = {
  overline: 'Zero-waste by design',
  title: 'Nothing leaves the ground as garbage.',
  sub: 'Every harvest produces "waste" that’s actually raw material. ThengaPari routes each byproduct to a buyer, so the leftovers become a second income — and a real SDG story.',
  flows: [
    { from: 'husk', fromLabel: 'Husks', to: 'coir', toLabel: 'Coir & fibre', cap: 'Husks go to coir units for rope, mats and growing media — instead of being burned at the gate.' },
    { from: 'jackfruit', fromLabel: 'Jackfruit rags', to: 'feed', toLabel: 'Dairy feed', cap: 'Pulp, rags and shells become nutritious cattle feed for local dairies — closing a neighbourhood loop.' },
    { from: 'shell', fromLabel: 'Shells', to: 'charcoal', toLabel: 'Charcoal', cap: 'Shells are converted to clean cooking charcoal and activated carbon — high value from what used to be litter.' },
  ],
  note: { pill: '~0 kg', text: 'to landfill per harvest — the target every Site Manager is measured against.' },
};

export const traction = {
  tag: 'Pilot numbers · placeholder',
  title: 'Built quietly. Growing fast.',
  sub: 'Early traction from our first panchayats. Swap in live figures any time — these are wired to update in one place.',
  stats: [
    { count: 1240, suffix: '+', label: 'Harvests completed', sub: 'across 9 panchayats' },
    { count: 380, suffix: '+', label: 'Workers onboarded', sub: 'climbers, processors, managers' },
    { count: 156, suffix: 'k', label: 'Kilograms processed', sub: 'coconut, jackfruit & more' },
    { count: 92, suffix: '%', label: 'Byproduct reused', sub: 'on the way to zero waste' },
  ],
  logosTitle: 'Backed & supported by — your partners here',
  logos: ['Incubator logo', 'Grant / fund', 'Agri partner', 'Panchayat / FPO'],
};

export const signup = {
  overline: 'Get started',
  title: 'Be first when ThengaPari reaches your panchayat.',
  sub: 'Homeowner, worker, student or business — leave your email and we’ll bring the harvest to your gate. The app is on its way.',
  cardTitle: 'Join the waitlist',
  cardSub: 'Free to join. We’ll only email about your area going live.',
  types: [
    { value: 'homeowner', label: 'Homeowner' }, // ML: "വീട്ടുടമ"
    { value: 'business', label: 'Business' }, // ML: "ബിസിനസ്"
    { value: 'general', label: 'Other' },
  ],
  placeholder: 'you@email.com',
  submit: 'Notify me',
  // ML: "നന്ദി!" = "Thank you!" — kept bilingual in the success message.
  success: "നന്ദി! You're on the list — we'll be in touch when ThengaPari reaches your area.",
  errEmpty: 'Please enter your email so we can reach you.',
  errInvalid: "That email doesn't look right — mind checking it?",
  errFail: 'Something went wrong — please try again in a moment.',
};

export const footer = {
  blurb: 'A hyperlocal harvest marketplace, rooted in Kerala. We turn backyard trees into income — and turn "waste" into a second harvest.',
  cols: [
    { h: 'Product', links: [
      { label: 'How it works', href: '#how' },
      { label: 'For homeowners', href: '#who' },
      { label: 'For workers', href: '#who' },
      { label: 'For businesses', href: '#signup' },
      { label: 'Download the app', href: '#signup' },
    ] },
    { h: 'Company', links: [
      { label: 'Zero-waste mission', href: '#zerowaste' },
      { label: 'Traction', href: '#traction' },
      { label: 'About / for investors', href: '#', ext: true },
      { label: 'Careers', href: '#' },
      { label: 'Contact', href: 'mailto:hello@thengapari.in' },
    ] },
    { h: 'Trust', links: [
      { label: 'Worker safety', href: '#' },
      { label: 'Fair pricing', href: '#' },
      { label: 'Privacy', href: '#' },
      { label: 'Terms', href: '#' },
    ] },
  ],
  copyright: '© 2026 ThengaPari Technologies Pvt. Ltd. All rights reserved.',
  made: 'Grown in Kerala', madeMl: 'നന്ദി', // ML: "നന്ദി" = thanks
};
