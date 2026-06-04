// crops.jsx — flat SVG crop glyphs + marketplace data (deep-blue B2B theme)

// ── Flat crop glyphs, drawn to sit inside a tinted circle ──
function CropGlyph({ type, size = 30 }) {
  const s = { width: size, height: size, display: 'block' };
  switch (type) {
    case 'coconut':
      return (
        <svg viewBox="0 0 32 32" style={s} aria-hidden="true">
          <circle cx="16" cy="17" r="11" fill="#7B4A24" />
          <path d="M16 6a11 11 0 0 1 0 22a8 11 0 0 0 0-22Z" fill="#5E3618" opacity=".5" />
          <circle cx="12.5" cy="15" r="1.7" fill="#3A2210" />
          <circle cx="19.5" cy="15" r="1.7" fill="#3A2210" />
          <circle cx="16" cy="20.5" r="1.7" fill="#3A2210" />
        </svg>
      );
    case 'mango':
      return (
        <svg viewBox="0 0 32 32" style={s} aria-hidden="true">
          <path d="M9 13c2.5-5 9-7 13-4s3 11-2 15-12 4-14-1c-1.6-4 0-7 3-10Z" fill="#F4A52A" />
          <path d="M22 9c-5-1-10 1-13 6 4-2 9-3 13-2 1-1.4 1-3 0-4Z" fill="#E89318" opacity=".55" />
          <path d="M21 7c1.5-1.5 4-2 5-1-.6 1.6-2.4 2.6-4.2 2.6Z" fill="#2E6B3E" />
        </svg>
      );
    case 'pepper':
      return (
        <svg viewBox="0 0 32 32" style={s} aria-hidden="true">
          <path d="M16 5c0 4-1 7-1 12" stroke="#4C7A3C" strokeWidth="2" strokeLinecap="round" fill="none" />
          <circle cx="11" cy="14" r="3.1" fill="#2B2A24" />
          <circle cx="17" cy="12" r="3.1" fill="#3A2210" />
          <circle cx="14" cy="19" r="3.1" fill="#2B2A24" />
          <circle cx="20" cy="18" r="3.1" fill="#3A2210" />
          <circle cx="17" cy="24" r="3.1" fill="#2B2A24" />
        </svg>
      );
    case 'jackfruit':
      return (
        <svg viewBox="0 0 32 32" style={s} aria-hidden="true">
          <ellipse cx="16" cy="18" rx="10" ry="12" fill="#7FA63C" />
          <ellipse cx="16" cy="18" rx="10" ry="12" fill="url(#jf)" opacity=".0" />
          <path d="M16 30c5 0 9-5 9-12" stroke="#5E7E2A" strokeWidth="0" />
          {[...Array(5)].map((_, r) =>
            [...Array(4)].map((_, c) => (
              <circle key={r + '-' + c} cx={9 + c * 4.6} cy={9 + r * 4.5} r="1.5" fill="#5E7E2A" />
            ))
          )}
          <rect x="14.5" y="3" width="3" height="4" rx="1.5" fill="#5E3618" />
        </svg>
      );
    case 'banana':
      return (
        <svg viewBox="0 0 32 32" style={s} aria-hidden="true">
          <path d="M7 9c1 9 7 16 17 16 1.6 0 2.4-.4 3-1-9 0-15-6-16-15-.4-1-3-1-4 0Z" fill="#F4C430" />
          <path d="M8 9c1.4 8 7 13.5 15 14-7-1-12-6-13-14Z" fill="#E0A91E" opacity=".6" />
          <rect x="6" y="6.5" width="3.5" height="3.5" rx="1.4" fill="#5E3618" />
        </svg>
      );
    case 'ginger':
      return (
        <svg viewBox="0 0 32 32" style={s} aria-hidden="true">
          <path d="M8 18c-2-4 2-8 6-7 1-3 6-4 8-1 3 0 5 4 3 7 1 3-2 7-6 6-2 2-7 2-8-1-3 0-5-4-3-6Z" fill="#D8A559" />
          <path d="M12 12c2 1 3 4 2 7M19 11c1 2 1 5-1 7" stroke="#B07C34" strokeWidth="1.4" fill="none" strokeLinecap="round" />
        </svg>
      );
    default:
      return <svg viewBox="0 0 32 32" style={s} />;
  }
}

// tint backgrounds for each crop glyph circle
const CROP_TINT = {
  coconut: '#EFE3D6',
  mango: '#FCEBCB',
  pepper: '#E6EFD9',
  jackfruit: '#ECF3E0',
  banana: '#FCEBCB',
  ginger: '#F3E8D6',
};

// ── Savings-by-crop (for the bar chart on screen 1) ──
const SAVINGS_BY_CROP = [
  { type: 'coconut', name: 'Coconut', pct: 14 },
  { type: 'jackfruit', name: 'Jackfruit', pct: 20 },
  { type: 'mango', name: 'Mango', pct: 10 },
  { type: 'pepper', name: 'Pepper', pct: 8 },
];

// ── Inventory listings ──
// price = platform price; market = wholesale ref; save = % below market
const LISTINGS = [
  {
    id: 'coconut-a', type: 'coconut', name: 'Coconut', grade: 'Grade A',
    unit: 'pc', price: 18, market: 20.5, save: 12, qty: '200+ units',
    ward: 'Manjaly ward', dist: 3.2, harvest: 'Harvested today', hours: 5,
    variety: 'West Coast Tall', moisture: 'Husked · sun-dried',
    farm: { name: 'Anil Varghese', plot: 'Plot 14 · Manjaly', since: '2019', rating: 4.8, harvests: 142 },
  },
  {
    id: 'jackfruit-a', type: 'jackfruit', name: 'Jackfruit', grade: 'Grade A',
    unit: 'pc', price: 40, market: 50, save: 20, qty: '60+ units',
    ward: 'Kuruppam ward', dist: 5.1, harvest: 'Harvested today', hours: 2,
    variety: 'Koozha (firm)', moisture: 'Whole · uncut',
    farm: { name: 'Leela Menon', plot: 'Plot 7 · Kuruppam', since: '2020', rating: 4.9, harvests: 96 },
  },
  {
    id: 'mango-a', type: 'mango', name: 'Mango', grade: 'Grade A',
    unit: 'kg', price: 95, market: 105.5, save: 10, qty: '120 kg',
    ward: 'Manjaly ward', dist: 3.6, harvest: 'Harvested today', hours: 4,
    variety: 'Alphonso', moisture: 'Tree-ripened',
    farm: { name: 'Suresh Pillai', plot: 'Plot 22 · Manjaly', since: '2018', rating: 4.7, harvests: 210 },
  },
  {
    id: 'pepper-b', type: 'pepper', name: 'Black Pepper', grade: 'Grade B',
    unit: 'kg', price: 480, market: 522, save: 8, qty: '40 kg',
    ward: 'Idukki line', dist: 12.4, harvest: 'Harvested yesterday', hours: 22,
    variety: 'Karimunda', moisture: 'Dried · 11% moisture',
    farm: { name: 'Thomas Kurian', plot: 'Estate 3 · Idukki', since: '2016', rating: 4.9, harvests: 318 },
  },
  {
    id: 'banana-nendran', type: 'banana', name: 'Nendran Banana', grade: 'Grade A',
    unit: 'kg', price: 55, market: 60.5, save: 9, qty: '90 kg',
    ward: 'Manjaly ward', dist: 2.9, harvest: 'Harvested today', hours: 6,
    variety: 'Nendran', moisture: 'Mature · unripe',
    farm: { name: 'Anil Varghese', plot: 'Plot 14 · Manjaly', since: '2019', rating: 4.8, harvests: 142 },
  },
  {
    id: 'ginger-fresh', type: 'ginger', name: 'Ginger', grade: 'Grade A',
    unit: 'kg', price: 70, market: 75.5, save: 7, qty: '30 kg',
    ward: 'Wayanad line', dist: 18.0, harvest: 'Harvested yesterday', hours: 26,
    variety: 'Rio-de-Janeiro', moisture: 'Fresh · washed',
    farm: { name: 'Rema Suresh', plot: 'Plot 9 · Wayanad', since: '2021', rating: 4.6, harvests: 73 },
  },
];

Object.assign(window, { CropGlyph, CROP_TINT, SAVINGS_BY_CROP, LISTINGS });
