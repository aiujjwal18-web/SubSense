-- 21_SubSense_Catalog_Logo_Patch_v1.2.sql
-- Incremental patch on top of 17_SubSense_Migration_v2.sql (independent of 20_SubSense_Retention_Patch_v1.0.sql;
-- order relative to that file does not matter).
-- Adds stored per-service logos to subscription_catalog, per 05_Design_System's Card visual standard
-- (DEC-043: real per-service brand icon/color is the sanctioned source of card-to-card visual variety).
-- Status: APPROVED, NOT YET RUN — DEC-046 (08_Decision_Log_v1.12) and the version bump to
-- 10_Database_Architecture_v1.5 are now recorded, so the documentation prerequisite is satisfied.
-- This file itself has not been executed against the live Supabase project yet — do not treat the
-- schema as actually changed until it has been run.
--
-- v1.2 change: swapped the Amazon Prime Video logo source for the exact Wikimedia file the user
-- referenced in their own sourcing research ("Amazon_Prime_Video_logo_(2024).svg") after confirming
-- it via the Commons API — a cleaner, more current source than the generic fallback used in v1.1.
-- Everything else unchanged. Superseded v1.1.

-- =========================================================
-- STEP 1 — schema change (non-breaking, additive)
-- =========================================================

alter table public.subscription_catalog add column if not exists logo_url text;

-- =========================================================
-- STEP 2 — backfill the ten seeded catalog rows from 17_SubSense_Migration_v2
-- =========================================================
--
-- Source: Simple Icons (https://simpleicons.org), MIT-licensed, served via jsDelivr, except where
-- noted. Pin to a specific released version rather than @latest before running in production —
-- check the current version at https://www.npmjs.com/package/simple-icons and replace
-- "simple-icons@latest" below with e.g. "simple-icons@13.x.x" so an upstream icon change
-- can't silently alter what's already live.

update public.subscription_catalog set logo_url = 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/netflix.svg'
  where slug = 'netflix'; -- confirmed (rendered)

update public.subscription_catalog set logo_url = 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/notion.svg'
  where slug = 'notion'; -- confirmed (rendered)

update public.subscription_catalog set logo_url = 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/icloud.svg'
  where slug = 'icloud-plus'; -- confirmed (rendered; brand slug is "icloud", not "icloudplus")

-- amazonprimevideo.svg DOES NOT EXIST on Simple Icons (confirmed 404 — no such slug in the set).
-- Using the exact Wikimedia Commons file the user's own research referenced (Amazon Prime Video
-- logo (2024).svg), confirmed via the Commons API imageinfo lookup.
update public.subscription_catalog set logo_url = 'https://upload.wikimedia.org/wikipedia/commons/c/ca/Amazon_Prime_Video_logo_%282024%29.svg'
  where slug = 'amazon-prime-video'; -- confirmed (Wikimedia, matches user-supplied source)

-- Disney+ Hotstar row: renamed to JioHotstar in 22_SubSense_Catalog_Expansion. Logo handled there.

update public.subscription_catalog set logo_url = 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/youtube.svg'
  where slug = 'youtube-premium'; -- confirmed (rendered; generic YouTube mark, no separate "Premium" variant)

update public.subscription_catalog set logo_url = 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/spotify.svg'
  where slug = 'spotify'; -- confirmed (rendered); row renamed to "Spotify Premium" in 22_SubSense_Catalog_Expansion

update public.subscription_catalog set logo_url = 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/openai.svg'
  where slug = 'chatgpt-plus'; -- confirmed (rendered; simple-icons has no separate "chatgpt" slug as of this check)

update public.subscription_catalog set logo_url = 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/google.svg'
  where slug = 'google-one'; -- confirmed (rendered; generic Google mark, "Google One" has no distinct icon)

update public.subscription_catalog set logo_url = 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/microsoftoffice.svg'
  where slug = 'microsoft-365'; -- confirmed (rendered)

-- =========================================================
-- Notes for expanding the catalog beyond the ten seeded services
-- =========================================================
--
-- When adding more catalog entries (the "preset database" build-out), follow the same pattern:
-- 1. Insert the row into subscription_catalog (name, slug, website_url, category_id, approved_at)
--    as 17_SubSense_Migration_v2 already does.
-- 2. Look up the brand's slug at simpleicons.org and set logo_url in the same insert or a
--    follow-up update. Load the actual CDN URL and confirm a real image renders — a slug existing
--    in the docs/reference list is not sufficient, as amazonprimevideo and midjourney both showed
--    real 404s despite looking like plausible slugs.
-- 3. If a service has no Simple Icons entry, check Wikimedia Commons via its API
--    (action=query&list=search&srnamespace=6) rather than guessing a hash-based upload path, and
--    confirm via imageinfo before using the URL. If neither source has a real result, leave
--    logo_url null rather than guessing — the frontend fallback (generic icon/initial) handles
--    that case per 05_Design_System's Icon System, and a wrong or broken logo is worse than a
--    clean fallback on a trust-sensitive surface.
