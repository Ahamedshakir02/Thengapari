import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// Static marketing site. No backend — the only dynamic piece is the waitlist
// form, which writes directly to Firestore from the client.
export default defineConfig({
  plugins: [react()],
  build: {
    target: 'es2018',
    cssMinify: true,
  },
});
