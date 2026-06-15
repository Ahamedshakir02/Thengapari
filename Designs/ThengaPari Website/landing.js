/* ============================================================
   ThengaPari landing — interactions
   ============================================================ */
(function () {
  'use strict';
  var prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* ---------- Sticky nav shadow ---------- */
  var nav = document.getElementById('nav');
  function onScroll() {
    if (window.scrollY > 8) nav.classList.add('scrolled');
    else nav.classList.remove('scrolled');
  }
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  /* ---------- Mobile menu ---------- */
  var toggle = document.getElementById('navToggle');
  var menu = document.getElementById('mobileMenu');
  function closeMenu() {
    menu.classList.remove('open');
    toggle.setAttribute('aria-expanded', 'false');
  }
  toggle.addEventListener('click', function () {
    var open = menu.classList.toggle('open');
    toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
  });
  menu.querySelectorAll('a').forEach(function (a) {
    a.addEventListener('click', closeMenu);
  });
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') closeMenu();
  });

  /* ---------- Scroll-driven visibility engine ----------
     IntersectionObserver can be unreliable inside embedded/iframed
     previews, so we drive reveals from a plain scroll/resize check.
     An element "enters" when its top crosses 88% of the viewport. */
  var watchers = [];   // { el, margin, fn, done }
  function inView(el, marginFrac) {
    var r = el.getBoundingClientRect();
    var vh = window.innerHeight || document.documentElement.clientHeight;
    return r.top < vh * (marginFrac == null ? 0.88 : marginFrac) && r.bottom > 0;
  }
  function pump() {
    for (var i = watchers.length - 1; i >= 0; i--) {
      var w = watchers[i];
      if (!w.done && inView(w.el, w.margin)) { w.done = true; w.fn(w.el); watchers.splice(i, 1); }
    }
  }
  function watch(el, fn, margin) {
    var w = { el: el, fn: fn, margin: margin, done: false };
    watchers.push(w);
    if (inView(el, margin)) { w.done = true; fn(el); watchers.pop(); }
  }
  var pumpQueued = false;
  function schedulePump() {
    if (pumpQueued) return; pumpQueued = true;
    var run = function () { pumpQueued = false; pump(); };
    if (window.requestAnimationFrame) requestAnimationFrame(run);
    setTimeout(run, 120);   // failsafe — runs even if rAF is throttled
  }
  window.addEventListener('scroll', schedulePump, { passive: true });
  window.addEventListener('resize', schedulePump);
  window.addEventListener('wheel', schedulePump, { passive: true });
  window.addEventListener('touchmove', schedulePump, { passive: true });
  // Position-driven poller: reveals fire from scroll POSITION even where
  // scroll events don't dispatch (some embedded/preview contexts). Stops
  // once every watcher has resolved.
  var poller = setInterval(function () {
    pump();
    if (!watchers.length) clearInterval(poller);
  }, 220);

  /* ---------- rAF tween with guaranteed finalize ----------
     CSS transitions can freeze mid-flight in throttled/embedded
     contexts, leaving content invisible. We tween inline styles and
     ALWAYS snap to the final state via a setTimeout failsafe, so the
     content is guaranteed visible even if rAF never advances. */
  var easeOut = function (p) { return 1 - Math.pow(1 - p, 3); };
  function finalizeReveal(el) {
    el.style.opacity = '1';
    el.style.transform = 'none';
    el.style.willChange = '';
    el.classList.add('in');
  }
  function tweenIn(el, dur, fromY, delay) {
    delay = delay || 0;
    setTimeout(function () {
      var start = null, done = false;
      function snap() { if (!done) { done = true; finalizeReveal(el); } }
      function step(ts) {
        if (start === null) start = ts;
        var p = Math.min((ts - start) / dur, 1);
        var e = easeOut(p);
        el.style.opacity = String(e);
        el.style.transform = 'translateY(' + ((1 - e) * fromY) + 'px)';
        if (p < 1 && !done) requestAnimationFrame(step);
        else snap();
      }
      requestAnimationFrame(step);
      setTimeout(snap, dur + 140);   // failsafe — fires even if rAF is throttled
    }, delay);
  }

  /* ---------- Scroll reveal ---------- */
  var reveals = document.querySelectorAll('.reveal');
  if (prefersReduced) {
    reveals.forEach(function (el) { el.classList.add('in'); });
  } else {
    reveals.forEach(function (el) {
      var d = parseInt(el.getAttribute('data-d') || '0', 10) * 90;
      watch(el, function (n) { tweenIn(n, 640, 22, d); });
    });
  }

  /* ---------- How-it-works animated flow ---------- */
  var steps = document.getElementById('steps');
  if (steps) {
    var stepEls = steps.querySelectorAll('.step');
    var progress = document.getElementById('stepProgress');
    function tweenWidth(el, target, dur) {
      var start = null, done = false;
      function snap() { if (!done) { done = true; el.style.width = target + '%'; } }
      function step(ts) {
        if (start === null) start = ts;
        var p = Math.min((ts - start) / dur, 1);
        el.style.width = (easeOut(p) * target) + '%';
        if (p < 1 && !done) requestAnimationFrame(step); else snap();
      }
      requestAnimationFrame(step);
      setTimeout(snap, dur + 140);
    }
    function runSteps() {
      stepEls.forEach(function (s, i) {
        if (prefersReduced) { finalizeReveal(s); }
        else { tweenIn(s, 560, 18, i * 240); }
      });
      if (progress && !prefersReduced) tweenWidth(progress, 84, 1100);
      else if (progress) progress.style.width = '84%';
    }
    watch(steps, runSteps, 0.7);
  }

  /* ---------- Count-up stats ---------- */
  function animateCount(el) {
    var target = parseFloat(el.getAttribute('data-count')) || 0;
    var suffix = el.getAttribute('data-suffix') || '';
    var finalHTML = target.toLocaleString('en-IN') + suffix;
    if (prefersReduced) { el.innerHTML = finalHTML; return; }
    var dur = 1500, start = performance.now(), done = false;
    function frame(now) {
      if (done) return;
      var p = Math.min((now - start) / dur, 1);
      var eased = 1 - Math.pow(1 - p, 3);
      el.innerHTML = Math.round(target * eased).toLocaleString('en-IN') + suffix;
      if (p < 1) requestAnimationFrame(frame); else done = true;
    }
    requestAnimationFrame(frame);
    setTimeout(function () { if (!done) { done = true; el.innerHTML = finalHTML; } }, dur + 160);
  }
  var counts = document.querySelectorAll('[data-count]');
  counts.forEach(function (el) { watch(el, animateCount, 0.82); });

  /* initial pass once layout settles */
  window.addEventListener('load', schedulePump);
  setTimeout(pump, 60);
  pump();

  /* ---------- Ultimate safety net ----------
     Whatever happens with scroll detection / throttling, never leave
     content permanently hidden. After a grace period, force-finalize
     anything still un-revealed. For an engaged user this is a no-op
     (scroll already revealed it); it only catches edge cases. */
  setTimeout(function () {
    reveals.forEach(finalizeReveal);
    document.querySelectorAll('.step').forEach(finalizeReveal);
    var pr = document.getElementById('stepProgress');
    if (pr && !pr.style.width) pr.style.width = '84%';
    document.querySelectorAll('[data-count]').forEach(function (el) {
      if (el.innerHTML === '0' || el.innerHTML === '') {
        el.innerHTML = (parseFloat(el.getAttribute('data-count')) || 0).toLocaleString('en-IN') + (el.getAttribute('data-suffix') || '');
      }
    });
  }, 5000);

  /* ---------- Signup form ---------- */
  var form = document.getElementById('signupForm');
  if (form) {
    var input = document.getElementById('email');
    var msg = document.getElementById('formMsg');
    var re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var val = (input.value || '').trim();
      msg.className = 'field-msg';
      if (!val) { msg.classList.add('err'); msg.textContent = 'Please enter your email so we can reach you.'; input.focus(); return; }
      if (!re.test(val)) { msg.classList.add('err'); msg.textContent = "That email doesn't look right — mind checking it?"; input.focus(); return; }
      msg.classList.add('ok');
      msg.textContent = "നന്ദി! You're on the list — we'll be in touch when ThengaPari reaches your area.";
      form.reset();
      try { localStorage.setItem('tp_waitlist', val); } catch (_) {}
    });
  }
})();
