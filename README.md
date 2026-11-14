# Dear Diary — scrapbook journal

A cute, pastel scrapbook-style journal: one page per day with stickers, stamps, washi tape,
photo strips & polaroids, doodles, cut-out letters, widgets and "make a page" auto-layouts.

**Login is optional.**
- **Guests** use the diary straight away. Pages and photos are saved in their browser.
- **Logged-in users** (email + a one-time code, no password) get their diary saved to their
  account, so it's safe and opens on any device. When someone logs in for the first time,
  the diary offers to copy the pages already in that browser into their account.

## Files
| file | what it is |
|---|---|
| `index.html` | the whole app (HTML + CSS + JS) |
| `config.js` | **your settings** — fill in 2 values to turn on email login |
| `supabase-setup.sql` | creates the database table, security rules and photo storage |
| `fonts/` | handwriting fonts |
| `lib/html-to-image.js` | "save page as picture" |
| `lib/supabase.js` | login + cloud saving (Supabase client v2) |

## Run it (guest mode — works with no setup)
Serve the folder with any static web server, then open it in a browser:

    npx serve .            # or
    python -m http.server 8080

Any static host works too (IIS, Netlify, Vercel, GitHub Pages, cPanel…).

## Turn on email login (about 10 minutes, free)
1. Create a free project at https://supabase.com.
2. **SQL Editor → New query** → paste all of `supabase-setup.sql` → **Run**.
   This creates the `entries` table, makes every user able to see *only their own* pages,
   and creates a **private** `diary-photos` bucket (photos are shown through 1-hour signed links).
3. **Authentication → URL Configuration**
   - *Site URL*: the address where you host the diary, e.g. `https://diary.yoursite.com`
   - *Redirect URLs*: add the same address (and `http://localhost:8080` for testing).
4. **Authentication → Email Templates → Magic Link**: add the code to the email so people
   can type it in, e.g.
   `<p>Your Dear Diary code is: <b>{{ .Token }}</b></p>` (keep the link too — tapping it also logs in).
5. **Before real users:** Supabase's built-in email sender only allows a few emails per hour.
   Add your own SMTP under **Authentication → SMTP Settings** (Gmail/Zoho/Brevo/SendGrid etc.).
6. **Project Settings → API**: copy the *Project URL* and the *anon public* key into `config.js`:

   ```js
   window.DIARY_CONFIG = {
     supabaseUrl: 'https://abcdefghijklm.supabase.co',
     supabaseAnonKey: 'eyJhbGciOi...',
     photoBucket: 'diary-photos'
   };
   ```
   (The anon key is meant to be public — the security rules from step 2 protect the data.
   Never put the `service_role` key in this file.)
7. Upload the folder. A **☁️ my account** box appears in the sidebar with "log in with email".

Leave `config.js` empty and the login box simply doesn't appear.

## How saving works
| | guest | logged in |
|---|---|---|
| pages | browser `localStorage` | Supabase table `entries` (one row per day, JSON) |
| photos | compressed, inside the page data | private Supabase Storage bucket, `<user id>/…jpg` |
| devices | this browser only | any device, after logging in |
| limit | about 5 MB per browser | your Supabase plan (free tier: 500 MB database, 1 GB files) |

Logging out shows that browser's guest pages again; the account's pages stay in the account.
Other devices pick up changes when the tab is focused again.

## Inside Claude
The same `index.html` also runs as a Claude artifact. There it saves to the viewer's Claude
account automatically (plus voice dictation and file downloads), and the email login is hidden.
