-- 28_SubSense_Scheduled_Reminders_Patch_v1.0.sql
-- Incremental patch on top of the already-applied 17_SubSense_Migration_v2.sql and
-- 20_SubSense_Retention_Patch_v1.0.sql. Implements DEC-068's remaining DB-side piece:
-- the generate_scheduled_reminders() function backing the `generate-scheduled-reminders`
-- Edge Function (11_API_Integration_Architecture_v1.12 §5.7), plus the two CHECK
-- constraint loosenings that function's inserts require for `monthly_digest` and
-- `lapsed_reengagement` (both user-level reminder types with no natural subscription_id
-- or payment_request_id to anchor to).
--
-- IMPORTANT: run this in two steps, not as one pasted block, same reason as
-- 20_SubSense_Retention_Patch_v1.0.sql -- Postgres will not let a new enum value be used
-- by a statement in the same transaction/statement batch that added it. Run Step 1,
-- confirm it completes, then run Step 2 separately.
--
-- Step 2 is safe to re-run on its own if it fails partway (constraint drops use
-- IF EXISTS, the function uses CREATE OR REPLACE) -- just don't re-run Step 1 after
-- Step 2 has already succeeded once; `add value if not exists` makes that safe too,
-- but there is no reason to.

-- =========================================================
-- STEP 1 — run this first, on its own
-- =========================================================

-- New audit_action value for a per-row generation failure inside
-- generate_scheduled_reminders() (doc 11 §5.7's GEN_001 error code), distinct from
-- 'reminder_executed' (which means a reminder was actually sent, per send-reminder-email).
alter type public.audit_action add value if not exists 'reminder_generation_failed';

-- =========================================================
-- STEP 2 — run this after Step 1 has committed
-- =========================================================

-- ---------------------------------------------------------
-- 1. Loosen both CHECK constraints on `reminders` so `monthly_digest` and
--    `lapsed_reengagement` rows can be inserted with subscription_id AND
--    payment_request_id both null (they are user-level, not subscription- or
--    payment-request-level). Every other reminder_type keeps its existing,
--    unchanged requirement. Confirmed both constraints are the same ones defined in
--    17_SubSense_Migration_v2.sql and untouched by 20_SubSense_Retention_Patch_v1.0.sql.
-- ---------------------------------------------------------

alter table public.reminders drop constraint if exists reminders_target_present;
alter table public.reminders add constraint reminders_target_present check (
  subscription_id is not null
  or payment_request_id is not null
  or reminder_type in ('monthly_digest', 'lapsed_reengagement')
);

alter table public.reminders drop constraint if exists reminders_shared_payment_target;
alter table public.reminders add constraint reminders_shared_payment_target check (
  (reminder_type = 'shared_payment' and payment_request_id is not null)
  or (reminder_type in ('monthly_digest', 'lapsed_reengagement'))
  or (
    reminder_type not in ('shared_payment', 'monthly_digest', 'lapsed_reengagement')
    and subscription_id is not null
  )
);

-- ---------------------------------------------------------
-- 2. generate_scheduled_reminders() — called via RPC from the
--    generate-scheduled-reminders Edge Function, once daily (Supabase Cron).
--    Implements the three generation rules from 11_API_Integration_Architecture_v1.12
--    §5.7 in one run:
--      (a) post_renewal_checkin — subscriptions whose next_renewal_date was exactly
--          3 days ago (DEC-039/DEC-047), one per subscription, 9am in the owner's
--          user_profiles.timezone. Duplicate prevention: the existing partial unique
--          index reminders_pending_subscription_type_unique (10_Database_Architecture
--          _v1.12) already covers this — ON CONFLICT DO NOTHING is enough, no separate
--          existence check needed.
--      (b) monthly_digest — every active user with at least one non-archived
--          subscription who has no pending/sent monthly_digest row already scheduled
--          in the current calendar month (evaluated in the user's own local timezone,
--          consistent with how every other reminder's timing is anchored to
--          user_profiles.timezone per DEC-039). No partial unique index covers this
--          (doc 10 §"CHECK"/"Partial unique index" note) — duplicate prevention is the
--          NOT EXISTS check below, matching 10_Database_Architecture_v1.13's documented
--          approach.
--      (c) lapsed_reengagement — every active user whose last_login_at is more than
--          45 days old (or null, with created_at more than 45 days old — a user who
--          never logged in again after signup), with no pending/sent
--          lapsed_reengagement row already scheduled within the current rolling
--          45-day window. Same NOT EXISTS-based duplicate prevention as (b), per
--          DEC-041.
--    Both (b) and (c) insert with subscription_id and payment_request_id both null,
--    which is exactly what the loosened constraints above now allow.
--
--    Per-row failures (e.g. an unexpected constraint violation) are caught, logged to
--    audit_logs (action='reminder_generation_failed', doc 11 §5.7's GEN_001), and do
--    not abort the run for the remaining rows — the next day's run re-evaluates
--    everything from scratch since generation checks current state, not a queue.
--
--    account_status = 'active' filters below are a defensive addition beyond what
--    docs 10/11 spell out explicitly (they only say "non-archived subscription" /
--    "active user" without naming the exact column) — added so a suspended or
--    already-archived user account never receives a digest or re-engagement email
--    even if their underlying subscription/login data would otherwise qualify.
-- ---------------------------------------------------------

create or replace function public.generate_scheduled_reminders()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  rec record;
  rows_written integer;
  post_renewal_inserted integer := 0;
  post_renewal_failed integer := 0;
  monthly_digest_inserted integer := 0;
  monthly_digest_failed integer := 0;
  lapsed_inserted integer := 0;
  lapsed_failed integer := 0;
begin
  -- (a) post_renewal_checkin: subscriptions that renewed exactly 3 days ago.
  for rec in
    select
      s.id as subscription_id,
      s.user_id,
      coalesce(p.timezone, 'Asia/Kolkata') as tz
    from public.subscriptions s
    join public.users u on u.id = s.user_id
    left join public.user_profiles p on p.user_id = s.user_id
    where s.archived_at is null
      and u.account_status = 'active'
      and s.next_renewal_date = current_date - 3
  loop
    begin
      insert into public.reminders (user_id, subscription_id, reminder_type, scheduled_for, timezone_snapshot)
      values (
        rec.user_id,
        rec.subscription_id,
        'post_renewal_checkin',
        public.local_date_at_9am_tz(current_date, rec.tz),
        rec.tz
      )
      on conflict do nothing;
      -- ON CONFLICT DO NOTHING succeeds even when it silently no-ops (duplicate
      -- already exists) -- GET DIAGNOSTICS is needed so the returned count reflects
      -- rows actually written, not rows attempted, since this jsonb summary is the
      -- only observability signal this run produces (DEC-068 has no dedicated
      -- monitoring layer).
      get diagnostics rows_written = row_count;
      post_renewal_inserted := post_renewal_inserted + rows_written;
    exception when others then
      post_renewal_failed := post_renewal_failed + 1;
      -- Best-effort audit log: nested so a failure logging the failure (e.g. an
      -- unexpected constraint on audit_logs itself) can never cascade into aborting
      -- the whole function's transaction and rolling back every reminder already
      -- inserted earlier in this run.
      begin
        insert into public.audit_logs (actor_type, action, entity_table, entity_id, metadata)
        values (
          'service',
          'reminder_generation_failed',
          'subscriptions',
          rec.subscription_id,
          jsonb_build_object(
            'reminder_type', 'post_renewal_checkin',
            'error_code', 'GEN_001',
            'error_message', sqlerrm
          )
        );
      exception when others then
        null;
      end;
    end;
  end loop;

  -- (b) monthly_digest: active users with >=1 non-archived subscription, no
  -- pending/sent monthly_digest row already scheduled this calendar month (in the
  -- user's own local timezone).
  for rec in
    select
      u.id as user_id,
      coalesce(p.timezone, 'Asia/Kolkata') as tz
    from public.users u
    left join public.user_profiles p on p.user_id = u.id
    where u.account_status = 'active'
      and exists (
        select 1 from public.subscriptions s
        where s.user_id = u.id and s.archived_at is null
      )
      and not exists (
        select 1 from public.reminders r
        where r.user_id = u.id
          and r.reminder_type = 'monthly_digest'
          and r.status in ('pending', 'sent')
          and date_trunc('month', r.scheduled_for at time zone coalesce(p.timezone, 'Asia/Kolkata'))
            = date_trunc('month', now() at time zone coalesce(p.timezone, 'Asia/Kolkata'))
      )
  loop
    begin
      insert into public.reminders (user_id, subscription_id, payment_request_id, reminder_type, scheduled_for, timezone_snapshot)
      values (
        rec.user_id,
        null,
        null,
        'monthly_digest',
        public.local_date_at_9am_tz(current_date, rec.tz),
        rec.tz
      );
      monthly_digest_inserted := monthly_digest_inserted + 1;
    exception when others then
      monthly_digest_failed := monthly_digest_failed + 1;
      -- Nested for the same reason as the post_renewal_checkin block above.
      begin
        insert into public.audit_logs (actor_type, action, entity_table, entity_id, metadata)
        values (
          'service',
          'reminder_generation_failed',
          'users',
          rec.user_id,
          jsonb_build_object(
            'reminder_type', 'monthly_digest',
            'error_code', 'GEN_001',
            'error_message', sqlerrm
          )
        );
      exception when others then
        null;
      end;
    end;
  end loop;

  -- (c) lapsed_reengagement: active users inactive 45+ days, no pending/sent
  -- lapsed_reengagement row already scheduled within the current rolling 45-day window.
  for rec in
    select
      u.id as user_id,
      coalesce(p.timezone, 'Asia/Kolkata') as tz
    from public.users u
    left join public.user_profiles p on p.user_id = u.id
    where u.account_status = 'active'
      and (
        (u.last_login_at is not null and u.last_login_at < now() - interval '45 days')
        or (u.last_login_at is null and u.created_at < now() - interval '45 days')
      )
      and not exists (
        select 1 from public.reminders r
        where r.user_id = u.id
          and r.reminder_type = 'lapsed_reengagement'
          and r.status in ('pending', 'sent')
          and r.scheduled_for > now() - interval '45 days'
      )
  loop
    begin
      insert into public.reminders (user_id, subscription_id, payment_request_id, reminder_type, scheduled_for, timezone_snapshot)
      values (
        rec.user_id,
        null,
        null,
        'lapsed_reengagement',
        public.local_date_at_9am_tz(current_date, rec.tz),
        rec.tz
      );
      lapsed_inserted := lapsed_inserted + 1;
    exception when others then
      lapsed_failed := lapsed_failed + 1;
      -- Nested for the same reason as the post_renewal_checkin block above.
      begin
        insert into public.audit_logs (actor_type, action, entity_table, entity_id, metadata)
        values (
          'service',
          'reminder_generation_failed',
          'users',
          rec.user_id,
          jsonb_build_object(
            'reminder_type', 'lapsed_reengagement',
            'error_code', 'GEN_001',
            'error_message', sqlerrm
          )
        );
      exception when others then
        null;
      end;
    end;
  end loop;

  return jsonb_build_object(
    'post_renewal_checkin', jsonb_build_object('inserted', post_renewal_inserted, 'failed', post_renewal_failed),
    'monthly_digest', jsonb_build_object('inserted', monthly_digest_inserted, 'failed', monthly_digest_failed),
    'lapsed_reengagement', jsonb_build_object('inserted', lapsed_inserted, 'failed', lapsed_failed)
  );
end;
$$;

-- Notes for whoever runs this file:
--
-- - This function is SECURITY DEFINER, matching the existing pattern for every other
--   function that writes to `reminders` or `audit_logs` (generate_default_reminders(),
--   skip_reminders_for_archived_subscription()) -- both tables are system-only-write,
--   no client INSERT/UPDATE policy exists for either. In practice it will only ever be
--   invoked via the generate-scheduled-reminders Edge Function's service-role client
--   (which already bypasses RLS entirely), so SECURITY DEFINER is not strictly load-
--   bearing here -- it's kept for consistency with the rest of this file's functions,
--   not because it changes behavior for this specific caller.
-- - Idempotent to re-run: (a) is protected by the existing partial unique index,
--   (b) and (c) are protected by their NOT EXISTS checks, so running this function
--   twice in the same day does not double-insert. Re-running the whole migration file
--   itself is also safe (CREATE OR REPLACE FUNCTION, DROP CONSTRAINT IF EXISTS).
-- - Not yet wired up: the two Supabase Cron job definitions (hourly send-reminder-email,
--   daily generate-scheduled-reminders) are a separate, Dashboard-side step -- not part
--   of this SQL file, per the existing convention that Cron schedules are created via
--   the Supabase Dashboard (Database → Cron), not migration SQL.
