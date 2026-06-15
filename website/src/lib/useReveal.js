import { useEffect, useRef, useState } from 'react';

const prefersReduced =
  typeof window !== 'undefined' &&
  window.matchMedia('(prefers-reduced-motion: reduce)').matches;

/**
 * Reveal-on-scroll. Returns a ref + boolean; flips `true` once the element
 * crosses into view. Honors prefers-reduced-motion (starts visible).
 */
export function useReveal({ threshold = 0.18, rootMargin = '0px 0px -10% 0px' } = {}) {
  const ref = useRef(null);
  const [shown, setShown] = useState(prefersReduced);

  useEffect(() => {
    if (prefersReduced || shown) return;
    const el = ref.current;
    if (!el) return;
    const io = new IntersectionObserver(
      (entries) => {
        if (entries.some((e) => e.isIntersecting)) {
          setShown(true);
          io.disconnect();
        }
      },
      { threshold, rootMargin },
    );
    io.observe(el);
    return () => io.disconnect();
  }, [shown, threshold, rootMargin]);

  return [ref, shown];
}

/**
 * Count-up number animation, triggered when `active` becomes true.
 * Formats with en-IN grouping. Returns the current display string.
 */
export function useCountUp(target, { active, duration = 1500, suffix = '' } = {}) {
  const [value, setValue] = useState(prefersReduced ? target : 0);
  const started = useRef(false);

  useEffect(() => {
    if (!active || started.current) return;
    started.current = true;
    if (prefersReduced) {
      setValue(target);
      return;
    }
    const start = performance.now();
    let raf;
    const tick = (now) => {
      const p = Math.min((now - start) / duration, 1);
      const eased = 1 - Math.pow(1 - p, 3);
      setValue(Math.round(target * eased));
      if (p < 1) raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, [active, target, duration]);

  return `${value.toLocaleString('en-IN')}${suffix}`;
}
