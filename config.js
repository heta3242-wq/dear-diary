/*
  Dear Diary — optional email login (Supabase)
  ---------------------------------------------
  Leave these empty and the diary works as before: everything is saved in the browser.
  Fill them in (see README.md, "Turn on email login") and a "log in with email" box appears.
  Guests can still use the diary without logging in.
*/
window.DIARY_CONFIG = {
  supabaseUrl: '',        // e.g. 'https://abcdefghijklm.supabase.co'
  supabaseAnonKey: '',    // Project Settings → API → "anon public" key (safe to put in the browser)
  photoBucket: 'diary-photos'
};
