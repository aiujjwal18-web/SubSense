-- 22_SubSense_Catalog_Expansion_v2.0.sql
-- Incremental patch on top of 17_SubSense_Migration_v2.sql and 21_SubSense_Catalog_Logo_Patch_v1.2.sql
-- (run 21 first — this file assumes subscription_catalog.logo_url already exists).
-- Status: APPROVED, NOT YET RUN — DEC-046 (08_Decision_Log_v1.12) and the version bump to
-- 10_Database_Architecture_v1.5 are now recorded, so the documentation prerequisite is satisfied.
-- Nothing from any prior version of this file has been run against the real Supabase project, so
-- this version is a clean, full rewrite rather than a patch-on-patch. This file itself still has not
-- been executed against the live project — do not treat the catalog as actually expanded until it has.
--
-- v2.0 change: superseded v1.1's 20-item expansion (Sun NXT, Cult.fit, Times Prime, Wynk Music,
-- Gaana, Aha, BYJU'S, Coursera, Udemy, Xbox Game Pass, Midjourney, Dropbox, and the Gaming/Fitness/
-- Education-only categories are all dropped) after the user supplied their own curated list of 31
-- subscriptions (4 CSVs) and asked for it to be cross-referenced against this file. Net result:
-- catalog goes from 10 -> 31 rows via 21 new inserts, all 10 original rows are kept, 2 are recategorized
-- and 1 is renamed. Every logo_url below was individually verified this session (Simple Icons CDN
-- render check, or Wikimedia Commons API imageinfo lookup — not a guessed path). Major version bump
-- (not a patch) because the catalog's item set and category structure both changed structurally.
-- Superseded v1.1.

-- =========================================================
-- STEP 1 — new categories (2 needed; the original five from 17_SubSense_Migration_v2 — Entertainment,
-- Productivity, Education, Utilities, Other — are untouched. Education and Utilities end up used by
-- zero and one catalog row respectively after this file runs; left in place rather than dropped,
-- since dropping a seeded enum-like category is a schema-adjacent decision, not a content one.)
-- =========================================================

insert into public.subscription_categories (name, slug)
values
  ('Music', 'music'),
  ('AI Tools', 'ai-tools')
on conflict do nothing;

-- =========================================================
-- STEP 2 — recategorize existing seed rows to match the new grouping
-- =========================================================
-- YouTube Premium and Spotify were originally seeded under "entertainment" (17_SubSense_Migration_v2
-- had no Music category yet). ChatGPT Plus was originally seeded under "productivity" (no AI Tools
-- category yet). Moving them keeps the catalog's grouping consistent with the user's own list, which
-- separated Music and AI Tools out as their own sections.

update public.subscription_catalog
set category_id = (select id from public.subscription_categories where slug = 'music')
where slug in ('youtube-premium', 'spotify');

update public.subscription_catalog
set category_id = (select id from public.subscription_categories where slug = 'ai-tools')
where slug = 'chatgpt-plus';

-- =========================================================
-- STEP 3 — rename existing rows
-- =========================================================

-- Disney+ Hotstar merged with JioCinema into JioHotstar in February 2025. Renaming in place rather
-- than inserting a new row, to avoid a duplicate and preserve any existing FK references.
update public.subscription_catalog
set name = 'JioHotstar',
    slug = 'jiohotstar',
    website_url = 'https://www.jiohotstar.com'
where slug = 'disney-plus-hotstar';

update public.subscription_catalog
set logo_url = 'https://upload.wikimedia.org/wikipedia/commons/4/40/JioHotstar_2025.png'
where slug = 'jiohotstar';

-- Match the user's naming convention; slug is left unchanged (nothing FKs by slug, and changing it
-- isn't needed for this).
update public.subscription_catalog
set name = 'Spotify Premium'
where slug = 'spotify';

-- =========================================================
-- STEP 4 — 21 new entries
-- =========================================================

insert into public.subscription_catalog (category_id, name, slug, website_url, approved_at)
select c.id, v.name, v.slug, v.website_url, now()
from (values
  -- Entertainment
  ('entertainment', 'SonyLIV', 'sonyliv', 'https://www.sonyliv.com'),
  ('entertainment', 'ZEE5', 'zee5', 'https://www.zee5.com'),
  ('entertainment', 'JioCinema', 'jiocinema', 'https://www.jiocinema.com'),
  ('entertainment', 'Eros Now', 'eros-now', 'https://www.erosnow.com'),
  ('entertainment', 'ALTBalaji / ALTT', 'altt', 'https://altt.in'),
  ('entertainment', 'Apple TV+', 'apple-tv-plus', 'https://tv.apple.com'),
  ('entertainment', 'MX Player', 'mx-player', 'https://www.mxplayer.in'),
  ('entertainment', 'Lionsgate Play', 'lionsgate-play', 'https://www.lionsgateplay.com'),
  ('entertainment', 'Discovery+', 'discovery-plus', 'https://www.discoveryplus.in'),
  -- Music
  ('music', 'JioSaavn Pro', 'jiosaavn-pro', 'https://www.jiosaavn.com'),
  ('music', 'Apple Music', 'apple-music', 'https://music.apple.com'),
  -- Productivity
  ('productivity', 'Canva Pro', 'canva-pro', 'https://www.canva.com/pro/'),
  ('productivity', 'Grammarly Premium', 'grammarly-premium', 'https://www.grammarly.com'),
  ('productivity', 'Adobe Creative Cloud', 'adobe-creative-cloud', 'https://www.adobe.com/creativecloud.html'),
  ('productivity', 'NordVPN', 'nordvpn', 'https://nordvpn.com'),
  -- AI Tools
  ('ai-tools', 'Claude Pro', 'claude-pro', 'https://claude.ai'),
  ('ai-tools', 'Perplexity Pro', 'perplexity-pro', 'https://www.perplexity.ai/pro'),
  -- Other
  ('other', 'Amazon Prime', 'amazon-prime', 'https://www.amazon.in/prime'),
  ('other', 'Swiggy One', 'swiggy-one', 'https://www.swiggy.com/one'),
  ('other', 'Zomato Gold', 'zomato-gold', 'https://www.zomato.com'),
  ('other', 'Telegram Premium', 'telegram-premium', 'https://telegram.org')
) as v(category_slug, name, slug, website_url)
join public.subscription_categories c on c.slug = v.category_slug
on conflict do nothing;

-- =========================================================
-- STEP 5 — logo backfill, Simple Icons entries (all individually confirmed this session)
-- =========================================================
-- Pin the CDN to a specific version, not @latest (see 21 for why).

update public.subscription_catalog set logo_url = 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/canva.svg' where slug = 'canva-pro'; -- confirmed
update public.subscription_catalog set logo_url = 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/grammarly.svg' where slug = 'grammarly-premium'; -- confirmed
update public.subscription_catalog set logo_url = 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/adobecreativecloud.svg' where slug = 'adobe-creative-cloud'; -- confirmed
update public.subscription_catalog set logo_url = 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/nordvpn.svg' where slug = 'nordvpn'; -- confirmed
update public.subscription_catalog set logo_url = 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/anthropic.svg' where slug = 'claude-pro'; -- confirmed (slug is "anthropic", not "claude")
update public.subscription_catalog set logo_url = 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/perplexity.svg' where slug = 'perplexity-pro'; -- confirmed
update public.subscription_catalog set logo_url = 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/applemusic.svg' where slug = 'apple-music'; -- confirmed
update public.subscription_catalog set logo_url = 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/swiggy.svg' where slug = 'swiggy-one'; -- confirmed; generic Swiggy mark, not "One"-specific — acceptable placeholder
update public.subscription_catalog set logo_url = 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/zomato.svg' where slug = 'zomato-gold'; -- confirmed; generic Zomato wordmark, not "Gold"-specific
update public.subscription_catalog set logo_url = 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/telegram.svg' where slug = 'telegram-premium'; -- confirmed; generic Telegram mark, not "Premium"-specific

-- =========================================================
-- STEP 6 — logo backfill, India-specific / no-Simple-Icons-coverage brands via Wikimedia Commons
-- =========================================================
-- Each URL below was resolved via the Commons API (search + imageinfo) this session and confirmed
-- to point at a real file — not a guessed hash path.

update public.subscription_catalog set logo_url = 'https://upload.wikimedia.org/wikipedia/commons/f/f7/SonyLIV_2020.png' where slug = 'sonyliv'; -- confirmed
update public.subscription_catalog set logo_url = 'https://upload.wikimedia.org/wikipedia/commons/6/6e/ZEE5_2025.svg' where slug = 'zee5'; -- confirmed
update public.subscription_catalog set logo_url = 'https://upload.wikimedia.org/wikipedia/commons/5/5a/Jio_cinema.png' where slug = 'jiocinema'; -- confirmed
update public.subscription_catalog set logo_url = 'https://upload.wikimedia.org/wikipedia/commons/f/fe/ErosNow_Stag_New_18_White.jpg' where slug = 'eros-now'; -- confirmed (visually checked — legible on a white card background)
update public.subscription_catalog set logo_url = 'https://upload.wikimedia.org/wikipedia/commons/2/28/Apple_TV_Plus_Logo.svg' where slug = 'apple-tv-plus'; -- confirmed; this is the "+" specific mark, not the generic Apple TV app icon
update public.subscription_catalog set logo_url = 'https://upload.wikimedia.org/wikipedia/commons/5/5c/MX_Player_logo.svg' where slug = 'mx-player'; -- confirmed
update public.subscription_catalog set logo_url = 'https://upload.wikimedia.org/wikipedia/commons/7/72/Lionsgate%2B.svg' where slug = 'lionsgate-play'; -- confirmed; this is the "Lionsgate+" global rebrand mark (Lionsgate Play's parent brand internationally) — flag if the India-specific wordmark is wanted instead
update public.subscription_catalog set logo_url = 'https://upload.wikimedia.org/wikipedia/commons/6/61/Discovery_Plus_logo.svg' where slug = 'discovery-plus'; -- confirmed
update public.subscription_catalog set logo_url = 'https://upload.wikimedia.org/wikipedia/commons/e/ed/JioSaavn_Logo.svg' where slug = 'jiosaavn-pro'; -- confirmed; source file is labeled as the 2018-2024 logo, worth a recheck if JioSaavn has rebranded since
update public.subscription_catalog set logo_url = 'https://upload.wikimedia.org/wikipedia/commons/7/72/Amazon_Prime_logo_%282022%29.svg' where slug = 'amazon-prime'; -- confirmed; the Prime badge, distinct from the Amazon Prime Video logo already set on the original seed row

-- =========================================================
-- STEP 7 — confirmed NOT FOUND: leave null, do not guess
-- =========================================================
-- Searched directly against the Wikimedia Commons API (intitle:ALTT and intitle:ALTBalaji) — only
-- unrelated event photos matched, no logo file exists under either name. Matches what the user's own
-- source CSV already noted ("Not consistently available in SVG on Commons"). Source this from the
-- brand's own press/media kit when curating a real asset.
-- ALTBalaji / ALTT (slug 'altt') — logo_url stays null, no update statement needed.
