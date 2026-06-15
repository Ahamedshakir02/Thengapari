import { createContext, useCallback, useContext, useState } from 'react';

// Shares the "which audience clicked a CTA" intent between the scattered
// call-to-action buttons (nav, hero, role tiles) and the signup form, so
// clicking "For businesses" pre-selects Business and scrolls to the form.
const SignupContext = createContext(null);

export function SignupProvider({ children }) {
  const [type, setType] = useState('homeowner');

  const selectType = useCallback((next) => {
    if (next) setType(next);
    const el = document.getElementById('signup');
    if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }, []);

  return (
    <SignupContext.Provider value={{ type, setType, selectType }}>
      {children}
    </SignupContext.Provider>
  );
}

export function useSignup() {
  const ctx = useContext(SignupContext);
  if (!ctx) throw new Error('useSignup must be used within <SignupProvider>');
  return ctx;
}
