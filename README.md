# MOVEON Shop

Online shop for **MOVEON**, a streetwear brand from King William's Town, Eastern Cape. *Live Free, Express Boldly.*

## What's inside
- `index.html` – the whole site (storefront, About, Contact and the manager area)
- `img/` – product photos

## Features
- Product grid with photos, prices in Rand, sizes, and a photo slider per item
- Filters (All, New in, T-Shirts, Hoodies, Accessories) and search
- "Order on WhatsApp" button on every item
- Manager area (tap **Manage shop**) to add, edit and delete items and update shop details

## Run it
Open `index.html` in a browser, or turn on GitHub Pages (Settings → Pages → Deploy from branch → `main`).

## Database (Supabase, free)
With a database connected, every change in Manage shop shows for all customers straight away, and the manager signs in with email + password.

1. Create a free account at supabase.com and a new project (region: Cape Town if offered).
2. Open **SQL Editor → New query**, paste everything from `supabase-setup.sql`, check the manager email on the last line, and click **Run**.
3. Open **Authentication → Users → Add user → Create new user**: enter the manager email (same as in step 2) and a password, tick **Auto Confirm User**.
4. Open **Authentication → Sign In / Providers** and turn **off** "Allow new users to sign up".
5. Open **Project Settings → API**, copy the **Project URL** and the **anon public** key, and paste them into `SUPABASE_URL` and `SUPABASE_ANON_KEY` near the top of the script in `index.html`.

Without these two values the shop still works, but changes are saved only on the device they're made on (with a PIN, default `1234`).
