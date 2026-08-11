-- 27_SubSense_Catalog_Logo_Removal_v1.0.sql
-- Incremental patch on top of 17_SubSense_Migration_v2.sql (which added subscription_catalog),
-- 21_SubSense_Catalog_Logo_Patch_v1.2.sql (which added the logo_url column and backfilled the
-- original 10 rows), and 22_SubSense_Catalog_Expansion_v2.0.sql (which populated logo_url for the
-- 21 additional rows, bringing the catalog to 31 rows).
-- Implements DEC-059 (08_Decision_Log_v1.30): subscription cards no longer render a real
-- per-service brand logo anywhere in the frontend — every card now shows a fixed, generic
-- category icon (Lucide, per 05_Design_System's Icon System) instead. This closes a
-- trademark/IP exposure that displaying another company's actual logo artwork carried, even for
-- a non-commercial capstone build.
-- Status: RUN — executed against the live Supabase project. Verified via the count query below:
-- still_populated = 0, total = 31. All 31 catalog rows now have logo_url = null. Corrected once
-- before this run to drop a nonexistent updated_at column reference (see correction note below).
--
-- What this does and why: nulls out every populated logo_url value across all 31 catalog rows.
-- This scrubs the actual brand-logo references (Simple Icons CDN links, Wikimedia Commons file
-- URLs) out of the stored data itself, not just out of what the frontend happens to render —
-- a more complete fix than a rendering-layer change alone, per the user's explicit request to
-- close this out properly rather than just stop displaying it.
--
-- What this does NOT do: it does not drop the logo_url column. The column is retained, unused,
-- in the schema — a column drop is a separate, higher-effort schema change not required to close
-- the actual concern, and keeping the column costs nothing while leaving the door open at low
-- cost if a future decision ever wants a per-service image again. It also does not touch category,
-- name, website_url, or any other subscription_catalog column — this is a single-column data
-- scrub, not a broader catalog edit.

-- Correction (pre-run, same pass): subscription_catalog has no updated_at column — confirmed
-- both by the live schema (error 42703 on first run attempt) and by 10_Database_Architecture's
-- own column list for this table, which never included one. Dropped from the statement below.
update public.subscription_catalog
set logo_url = null
where logo_url is not null;

-- Expected result: all 31 rows have logo_url = null after this runs (30 previously had a real
-- value; the ALTBalaji/ALTT row was already null, so this UPDATE is a no-op for that one row).
-- Verify with: select count(*) filter (where logo_url is not null) as still_populated,
-- count(*) as total from public.subscription_catalog; -- expect still_populated = 0.
