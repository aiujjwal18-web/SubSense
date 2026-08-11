-- 33_SubSense_Link_Existing_User_On_Member_Add_v1.0.sql
-- Fixes a real gap found live-testing Phase 8: useSharedSubscription.ts's addMember()
-- never sets shared_members.user_id, so a newly-added member is never linked to their own
-- SubSense account even when one already exists with a matching email. Doc 10's "linked
-- member: select only" RLS grant (shared_members_select_owner_or_self,
-- payment_requests_select_owner_or_member, the member branch of
-- payment_requests_validate_transition) depends entirely on user_id being set -- until
-- this patch, that grant could never actually fire for anyone, no matter how the member
-- was added.
--
-- No schema change, no new enum value -- single transaction, no two-step split needed.
-- Idempotent to re-run (CREATE OR REPLACE FUNCTION, DROP TRIGGER IF EXISTS).

-- Email-comparison convention: matches the one precedent already in this schema for
-- exactly this kind of comparison -- shared_members_active_email_unique
-- (17_SubSense_Migration_v2.sql:348) is a partial unique index on lower(email), not a
-- plain-text comparison. public.users.email itself carries only a plain `unique`
-- constraint (no case-normalization at the column level), so this uses lower(...) on both
-- sides rather than assuming stored emails are already consistently cased.
create or replace function public.handle_shared_member_link_existing_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  matched_user_id uuid;
begin
  if new.user_id is null and new.email is not null then
    select id into matched_user_id
    from public.users
    where lower(email) = lower(new.email)
    limit 1;

    if matched_user_id is not null then
      new.user_id := matched_user_id;
    end if;
  end if;

  return new;
end;
$$;

-- BEFORE INSERT (not AFTER): the row must already carry the linked user_id by the time
-- the existing AFTER INSERT trigger, shared_members_generate_initial_request
-- (31_SubSense_Shared_Payment_Requests_v1.0.sql), re-selects this member and generates
-- their first payment_requests/reminders row -- otherwise that first request would target
-- an unlinked member even though a real account existed the whole time. No firing-order
-- dependency on the other existing BEFORE INSERT trigger on this table
-- (shared_members_validate_currency) -- that one only reads/writes new.currency, this one
-- only reads/writes new.user_id, so trigger-name alphabetical order doesn't matter here
-- the way it does for the reminder-cancellation trigger elsewhere in this project.
drop trigger if exists shared_members_link_existing_user on public.shared_members;
create trigger shared_members_link_existing_user
before insert
on public.shared_members
for each row execute function public.handle_shared_member_link_existing_user();

-- Why SECURITY DEFINER is not optional here, not just consistency with every other
-- trigger function in this project: public.users' only SELECT policy is
-- users_select_own (auth_user_id = auth.uid()) -- a normal authenticated owner adding a
-- member can never see any users row but their own via RLS. Without SECURITY DEFINER,
-- this trigger's lookup would run as the inserting owner's own 'authenticated' role and
-- silently find nothing for every match except the impossible case of the owner sharing
-- with themselves -- the whole feature would appear to "work" (no error) while never
-- actually linking anyone. Confirmed by reading users_select_own directly before writing
-- this, not assumed.

-- Notes for whoever runs this file:
--
-- - Scope, explicit: this only runs at add-time (BEFORE INSERT on shared_members). It
--   does NOT retroactively link a member who was added first and creates a SubSense
--   account later -- that remains a known, accepted gap, not part of this fix.
-- - No backfill: rows already in shared_members with user_id still null are NOT touched
--   by this migration -- same forward-only convention as every prior migration in this
--   project. If a specific already-existing row should be linked now (e.g. a member who
--   already has an account but was added before this patch ran), that's a separate,
--   optional, one-off manual UPDATE -- see the snippet below. This migration alone will
--   not fix any row that already exists in the table.
-- - Does not touch: shared_members_validate_currency, shared_members_touch_updated_at,
--   shared_members_generate_initial_request, shared_members_rebalance_on_remove,
--   rebalance_equal_split_members(), any RLS policy, or any other table.

-- =========================================================
-- OPTIONAL, one-off backfill for an already-existing unlinked row (not run automatically
-- by this migration -- your call whether to run it). Replace the email below with the
-- specific member's email; only touches shared_members rows still missing a link, so it's
-- safe to run even if some other row already got linked another way.
-- =========================================================
--
-- update public.shared_members
-- set user_id = (select id from public.users where lower(email) = lower('anasuya@example.com') limit 1)
-- where lower(email) = lower('anasuya@example.com')
--   and user_id is null;
