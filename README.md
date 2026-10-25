# Mondol Football Federation (MFF) Website

Responsive bilingual (English/Bangla) React + Vite website for Mondol Football Federation, redesigned with emerald, royal blue, white, and gold branding.

## Run locally

Requires Node.js 18+ (Node.js LTS recommended). Open PowerShell in this project folder (the folder containing `package.json`) and run:

```powershell
npm.cmd install
npm.cmd run dev
```

Open the local URL printed in the terminal, usually `http://localhost:5173/`.

For a production build:

```powershell
npm.cmd run build
npm.cmd run preview
```

## Included in this revision

- Responsive sticky header, mobile navigation, footer, and language switcher.
- English and Bangla interface text; selected language persists using `localStorage` and the active page stays open when switching languages.
- Redesigned, animated homepage with a 4-image automatic slider, manual slide controls, modern sports branding, introduction, mission/vision, fixtures, news, leadership, gallery, and contact CTA.
- About page: overview, proposed mission/vision/objectives, proposed core values, and history placeholder.
- Leadership directory with distinct President, General Secretary, and Executive Committee sections; each role has its own page and admin profile type.
- Expanded Admin panel at `/admin` for leadership, teams, players, home slider slides, gallery photos, matches/results, bilingual news, homepage/about text, mission/vision, contact details, and social links.
- Clearly labelled demo leadership, fixture, and news entries to demonstrate how the website looks with content.
- Admin-managed records update public leadership, teams, players, gallery, matches, news, homepage slider, intro/mission/vision and footer/contact areas.
- Competition, fixtures/results, standings, teams, a dedicated `/players` route, news, gallery, videos, documents, and contact sections. Unknown URLs now show a bilingual 404 page instead of incorrectly displaying the Players page.
- Search controls, news-category filters, match-status selector, standings selectors, gallery category filters, and keyboard-operable photo lightbox (Escape/arrow keys).
- Contact form validation without falsely claiming that a message was sent.
- SEO title, description, and `lang="en"` / `lang="bn"` attribute updates.
- Placeholder messaging to distinguish draft content and illustrative stock photography from verified MFF information.

## Important: official information still needs to be supplied

The site intentionally does **not** invent real people, committee members, team names, match scores, fixtures, competition dates, standings, statistics, official contact details, social URLs, or historical achievements. Those parts cannot be completed accurately without MFF's verified information. Replace the marked placeholders before official publication.

### Main places to edit

- `src/locales/translations.js` — shared English and Bangla UI text.
- `src/main.jsx` — page structure, proposed draft statements, gallery image list, category labels, and placeholder content.
- `src/styles.css` — colors, layout, spacing, and responsive styling.
- `public/mff-logo.svg` — custom MFF crest used in the header, footer and browser tab. `public/favicon.svg` mirrors the crest.

### Images

Current football images are illustrative remote Unsplash images. They are not actual MFF event photos. Replace the `defaultSlides` and `photos` values in `src/main.jsx`, or upload approved images from Admin. Recommended local folders:

```text
public/assets/images/
  branding/
  hero/
  leadership/
  committee/
  teams/
  players/
  competitions/
  news/
  gallery/
public/assets/documents/
```

Never use stock photos as portraits of real people. Confirm usage permissions for photos and videos.

## Admin panel and production limitations

Open `/admin` to manage leadership profiles, teams, players, home slider, gallery photos, matches/results, bilingual news, homepage/about text, mission/vision, contact details and social links. Image uploads accept JPG, PNG and WebP files up to 12 MB before automatic resizing/compression; the optimized upload is kept under the Supabase Storage limit. Without Supabase credentials, changes use browser `localStorage`; with Supabase configured, authenticated admin changes are saved online and can sync across devices.

This project has no live-score API, email delivery, or contact-form backend. The contact form validates fields in the browser but does not send anything. Do not display a success message as if an email was sent. To publish real data, connect a secure backend or CMS (for example, Supabase with row-level security and role-based access) and keep privileged keys server-side.

Social icons become clickable when verified official profile URLs are entered under Admin → Website content. Leave them blank until official links are confirmed.

## Deployment

This is a single-page React app using the History API. Configure the hosting provider to serve `index.html` for nested routes (SPA fallback), or direct refreshes on routes such as `/about` may return 404.

## Current verification note

The source has been updated, but this environment could not complete `npm install` during packaging because the npm registry was unreachable, so a production `vite build` could not be confirmed here. Install dependencies locally and run `npm.cmd run build`; if any error appears, share the full terminal output so it can be corrected.


## Complete page and source map

All page components and shared layout components are currently implemented in `src/main.jsx` and are wired through the client-side route table at the top of that file. Available public routes are `/`, `/about`, `/leadership`, `/leadership/president`, `/leadership/general-secretary`, `/leadership/committee`, `/competitions`, `/matches`, `/standings`, `/teams`, `/players`, `/news`, `/gallery`, `/videos`, `/documents`, and `/contact`; `/admin` is the content editor. The project is packaged with its Vite entry files, translation dictionary, full stylesheet, favicon, and public asset-folder structure. Empty image folders contain instructions rather than invented MFF portraits or event photos.

## Supabase online database (optional, free tier)

This version can sync leadership, teams, players, matches/results, news, home slides, gallery photos, website text/settings and uploaded images through Supabase. If Supabase credentials are not configured, it keeps browser-only demo mode.

### 1. Create a Supabase project

1. Open https://supabase.com/dashboard and create a project.
2. Open **SQL Editor → New query**, paste all of `supabase-setup.sql`, and run it.
3. Open **Project Settings / Connect** and copy the Project URL and publishable key (older projects may call this the `anon` key).
4. In the website root, copy `.env.example` to `.env.local`, then fill in `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY`.
5. Run `npm.cmd install` and `npm.cmd run dev`. Restart the dev server whenever `.env.local` changes.

Never use a `service_role` or secret key in `.env.local` or any browser/frontend code.

### 2. Create and authorize the administrator

1. In Supabase, open **Authentication → Users** and create/invite an admin user with an email and password. Keep public sign-ups disabled.
2. In **SQL Editor**, run this query with the admin's exact email to find the user's UUID:

   ```sql
   select id, email from auth.users where email = 'admin@example.com';
   ```

3. Copy the returned `id` UUID, then run:

   ```sql
   insert into public.mff_admins (user_id)
   values ('PASTE-ADMIN-UUID-HERE');
   ```

Only users listed in `public.mff_admins` can create, edit, or delete records or upload images. Public visitors can read published records. Do not share admin credentials.

### 3. Image upload troubleshooting

- Choose a JPG, PNG or WebP image. The Admin panel automatically resizes/compresses it and shows a preview; then press **Add to website** or **Save changes** to publish it.
- If an existing project reports `Could not find public.mff_standings` or missing `image_url` on `mff_matches`, run the full `supabase-setup.sql` or the updated `supabase-fix-existing-project.sql` in Supabase SQL Editor, then wait briefly and refresh the website. The repair SQL creates the missing standings table and match image column without deleting existing records. Confirm your current admin UUID is listed in `public.mff_admins`, and sign out/in again if image uploads are denied.
- Portraits in Leadership use `object-fit: contain` so the full photo is visible rather than aggressively cropped.

### 4. Verify it works

- Open `/admin`, sign in with the admin email/password, and add a test news item.
- Open `/news` in another browser/device. It should appear after that device has the same configured site URL and publishable key.
- Check Supabase **Table Editor** for `mff_leaders`, `mff_teams`, `mff_players`, `mff_competitions`, `mff_standings`, `mff_matches`, `mff_news`, `mff_slides`, `mff_gallery`, `mff_videos`, `mff_documents`, and `mff_site_settings`; uploaded pictures are in Storage bucket `mff-uploads`.
- Delete test data before launch. Replace demo entries with verified official MFF information.

### Notes and limitations

- The SQL file sets row-level security. Only user UUIDs explicitly added to `mff_admins` can write. Do not disable RLS or make write policies public.
- The public website reads data from Supabase; its publishable key is intended to be visible in frontend code. Security is enforced by RLS, authentication, and the admin allowlist.
- Existing `localStorage` data is not automatically imported into Supabase. Re-enter verified records in the online Admin panel after setup. If an older local demo is still showing, use **Reset demo data** from Admin to clear the old local examples before adding your real information.
- Supabase Free plan limits and pause/inactivity rules can change; check the current plan details in your Supabase dashboard.
- This setup syncs leadership, teams, players, competitions, standings, matches/results, news, homepage slides, gallery photos, videos, documents, website/about content, mission/vision/objectives, contact details, social links, and uploaded images. The contact form validates locally but does not send email; configure a trusted form backend if email delivery is needed.


## Fixing an existing Supabase project (important)

If this project was already set up before the latest ZIP, open `supabase-fix-existing-project.sql` and run the whole file in Supabase Dashboard → SQL Editor. This adds the missing `image_url` column to `mff_matches` and reloads the API schema cache. After running it, wait a few seconds, then refresh the website.

To avoid accidentally running an older copy of the website, stop the old Vite server with `Ctrl+C`, extract this ZIP into a new folder, copy your `.env.local` into that new folder, and run `npm.cmd install` followed by `npm.cmd run dev` from the new folder.

## MFF visual refresh (October 2026)
- Competition and Match & Results components now safely handle missing/empty data arrays and incomplete match fields instead of assuming every field exists.
- Player, team, competition and leadership images use `object-fit: contain` with a neutral background so portraits, logos and full images are not cropped/zoomed.
- Refreshed profile card spacing, borders, shadows, text readability and responsive behavior.
- Homepage slider retains admin-editable uploaded images and adds subtle transitions. Use Admin → Home slider to upload your own image, enter slide text, then save.
- Uploaded images are compressed in the browser; the Admin panel shows a preview before saving. Supabase mode requires the `mff-uploads` bucket and correct admin permissions from the included SQL setup.


## Match photos and visual refresh
- Match & Results cards now display the photo uploaded in Admin → Matches & Results.
- If your existing Supabase database reports that `image_url` does not exist, run `supabase-fix-match-images.sql` in the Supabase SQL Editor, then refresh the schema cache or wait briefly before retrying.
- The website stylesheet includes a full visual refresh with a cleaner forest-green federation style, more restrained cards, stronger typography, and responsive match-photo cards.
- Match photo uploads in online mode require the `mff-uploads` Storage bucket and an authenticated account with MFF admin permissions. Local demo mode saves to the current browser only.


## Glassmorphism refresh v2
- Added a restrained glassmorphism treatment to the header, hero controls, content cards, and admin panels.
- Restored leadership/player/team/competition image fitting to `object-fit: contain` to prevent faces and portraits from appearing zoomed or cropped.
- Kept match photos in a fixed-height cover crop so match thumbnails remain visually consistent.
