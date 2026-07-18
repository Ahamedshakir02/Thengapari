import { lazy, Suspense } from 'react';
import { SignupProvider } from './lib/signup';
import Nav from './components/Nav';
import Hero from './components/Hero';
import Problem from './components/Problem';
import HowItWorks from './components/HowItWorks';
import WhoItsFor from './components/WhoItsFor';
import SignupCTA from './components/SignupCTA';

// Below-the-fold sections are code-split so the initial bundle stays lean.
const ZeroWaste = lazy(() => import('./components/ZeroWaste'));
const Traction = lazy(() => import('./components/Traction'));
const Footer = lazy(() => import('./components/Footer'));

export default function App() {
  return (
    <SignupProvider>
      <Nav />
      <main id="top">
        <Hero />
        <Problem />
        <HowItWorks />
        <WhoItsFor />
        <Suspense fallback={null}>
          <ZeroWaste />
          <Traction />
        </Suspense>
        <SignupCTA />
      </main>
      <Suspense fallback={null}>
        <Footer />
      </Suspense>
    </SignupProvider>
  );
}
