/* ============================================================
   ThengaPari landing — Tweaks panel (React island)
   Renders ONLY the floating panel; applies tweak values to the
   vanilla page via data-attributes + CSS variables on <body>/<html>.
   ============================================================ */
const TP_TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "theme": "light",
  "accent": "#F4A52A",
  "density": "regular",
  "dividers": true,
  "headingScale": 1
}/*EDITMODE-END*/;

function TweaksApp() {
  const [t, setTweak] = useTweaks(TP_TWEAK_DEFAULTS);

  React.useEffect(() => {
    const body = document.body;
    const root = document.documentElement;
    body.setAttribute('data-theme', t.theme);
    body.setAttribute('data-density', t.density);
    body.setAttribute('data-dividers', t.dividers ? 'on' : 'off');
    // accent + its pressed shade
    root.style.setProperty('--accent', t.accent);
    // derive a slightly deeper pressed tone for the chosen accent
    root.style.setProperty('--amber-saffron-600', shade(t.accent, -16));
    root.style.setProperty('--shadow-accent', `0 6px 18px ${hexA(t.accent, 0.30)}`);
    root.style.setProperty('--t-h1-scale', String(t.headingScale));
    document.querySelectorAll('.hero h1, .section-title, .cta h2').forEach((el) => {
      el.style.setProperty('font-size', '');
    });
  }, [t]);

  return (
    <TweaksPanel title="Tweaks">
      <TweakSection label="Theme" />
      <TweakRadio label="Mode" value={t.theme} options={['light', 'dark']}
        onChange={(v) => setTweak('theme', v)} />
      <TweakColor label="Accent" value={t.accent}
        options={['#F4A52A', '#DD8413', '#E0613C', '#6E9E5E']}
        onChange={(v) => setTweak('accent', v)} />

      <TweakSection label="Layout" />
      <TweakRadio label="Density" value={t.density}
        options={['compact', 'regular', 'comfy']}
        onChange={(v) => setTweak('density', v)} />
      <TweakToggle label="Hill dividers & connectors" value={t.dividers}
        onChange={(v) => setTweak('dividers', v)} />
    </TweaksPanel>
  );
}

/* --- small color helpers --- */
function clamp(n) { return Math.max(0, Math.min(255, n)); }
function shade(hex, amt) {
  const c = hex.replace('#', '');
  const n = parseInt(c.length === 3 ? c.split('').map((x) => x + x).join('') : c, 16);
  let r = (n >> 16) + amt, g = ((n >> 8) & 255) + amt, b = (n & 255) + amt;
  return '#' + [clamp(r), clamp(g), clamp(b)].map((x) => x.toString(16).padStart(2, '0')).join('');
}
function hexA(hex, a) {
  const c = hex.replace('#', '');
  const n = parseInt(c.length === 3 ? c.split('').map((x) => x + x).join('') : c, 16);
  return `rgba(${(n >> 16) & 255}, ${(n >> 8) & 255}, ${n & 255}, ${a})`;
}

ReactDOM.createRoot(document.getElementById('tweaks-root')).render(<TweaksApp />);
