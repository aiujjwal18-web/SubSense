-- 31_SubSense_Shared_Payment_Requests_v1.0.sql
-- Implements DEC-080 (Phase 8, Shared Subscriptions): a new payment-request generation
-- trigger and an equal-split rebalance trigger, plus two schema fixes surfaced while
-- planning this migration (see 08_Decision_Log_v1.53's DEC-080 entry and the Phase 8
-- planning-pass notes for the full writeup).
--
-- shared_subscriptions / shared_members / payment_requests themselves, their RLS, their
-- archive-cascade trigger, and their currency-validation triggers already exist and are
-- already live (17_SubSense_Migration_v2.sql) -- this file adds only what DEC-080 actually
-- names as new: payment-request generation and equal-split rebalance.
--
-- Single transaction, no two-step split needed -- unlike files 20/28/29, nothing here adds
-- a new enum value (ALTER TYPE ... ADD VALUE is the only thing that convention exists for).
-- Safe to paste and run as one block. Idempotent to re-run in full (see notes at the end).

-- =========================================================
-- 1. Schema fix: reminders.user_id and notifications.user_id become nullable, scoped to
--    the shared_payment / unlinked-member case. shared_members.user_id is already
--    nullable -- a member may be tracked by name/email only, no SubSense account -- but
--    reminders/notifications previously required a real users.id, which an unlinked
--    member's reminder/notification row can never have.
-- =========================================================

alter table public.reminders drop constraint if exists reminders_user_id_present;
alter table public.reminders alter column user_id drop not null;
-- Known, deliberate gap left open by this change: reminders_select_own (Path A RLS) is
-- keyed on user_id = current_app_user_id() -- a row with user_id null (an unlinked
-- member's shared_payment reminder) becomes permanently unselectable by anyone via Path A,
-- including the owner. No functional impact today: generation (below) and sending
-- (send-reminder-email / send-shared-payment-reminder) both go through the service-role
-- client, and no UI in this pass surfaces reminder/notification history. A future
-- "last reminded" indicator would need a new owner-scoped SELECT policy (e.g. via
-- payment_request_id -> shared_subscriptions.owner_user_id) to read these rows at all.
alter table public.reminders add constraint reminders_user_id_present check (
  user_id is not null or (reminder_type = 'shared_payment' and payment_request_id is not null)
);

alter table public.notifications drop constraint if exists notifications_user_id_present;
alter table public.notifications alter column user_id drop not null;
-- Same deliberate gap as reminders.user_id above, same reasoning: notifications_select_own
-- becomes unselectable for an unlinked member's row. No functional impact this pass.
alter table public.notifications add constraint notifications_user_id_present check (
  user_id is not null or payment_request_id is not null
);

-- =========================================================
-- 2. generate_payment_request_for_member(target_shared_member_id, target_billing_cycle_date)
--    Shared helper (mirrors generate_default_reminders_for_subscription's role in
--    29_SubSense_Reminder_Lifecycle_Patch_v1.0.sql): creates one payment_requests row for
--    one currently-active member, snapshotting amount/currency from shared_members at the
--    moment of the call (doc 10: already-generated rows are immutable per-cycle
--    snapshots). Idempotent via the existing UNIQUE (shared_member_id, billing_cycle_date)
--    constraint. Also creates the matching shared_payment reminders row -- doc 10's own
--    stated generation mechanism ("created on demand when a payment_requests row is
--    created") -- but only when a new payment_requests row was actually inserted, not on
--    a no-op conflict.
-- =========================================================

create or replace function public.generate_payment_request_for_member(
  target_shared_member_id uuid,
  target_billing_cycle_date date
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  member record;
  new_request_id uuid;
  member_tz text;
begin
  select sm.id, sm.shared_subscription_id, sm.amount_owed, sm.currency, sm.status, sm.user_id
  into member
  from public.shared_members sm
  where sm.id = target_shared_member_id;

  if not found or member.status <> 'active' then
    return;
  end if;

  insert into public.payment_requests (shared_subscription_id, shared_member_id, billing_cycle_date, amount, currency)
  values (member.shared_subscription_id, member.id, target_billing_cycle_date, member.amount_owed, member.currency)
  on conflict (shared_member_id, billing_cycle_date) do nothing
  returning id into new_request_id;

  if new_request_id is null then
    return;
  end if;

  select p.timezone into member_tz
  from public.user_profiles p
  where p.user_id = member.user_id;

  -- scheduled_for is "now", not a future date: a payment_requests row generated here means
  -- a billing cycle has already rolled over, so the request is due immediately -- unlike
  -- seven_day/two_day/renewal_day, there is no "days before" window to compute.
  insert into public.reminders (user_id, payment_request_id, reminder_type, scheduled_for, timezone_snapshot)
  values (
    member.user_id,
    new_request_id,
    'shared_payment',
    now(),
    coalesce(member_tz, 'Asia/Kolkata')
  );
end;
$$;

-- =========================================================
-- 3. generate_payment_requests_for_shared_subscription(target_subscription_id, target_billing_cycle_date)
--    Resolves the (possibly nonexistent, possibly archived) shared_subscriptions row for a
--    subscription and fans the call above out to every currently-active member.
-- =========================================================

create or replace function public.generate_payment_requests_for_shared_subscription(
  target_subscription_id uuid,
  target_billing_cycle_date date
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  target_shared_subscription_id uuid;
  m record;
begin
  select ss.id into target_shared_subscription_id
  from public.shared_subscriptions ss
  where ss.subscription_id = target_subscription_id
    and ss.archived_at is null;

  if target_shared_subscription_id is null then
    return;
  end if;

  for m in
    select id from public.shared_members
    where shared_subscription_id = target_shared_subscription_id and status = 'active'
  loop
    perform public.generate_payment_request_for_member(m.id, target_billing_cycle_date);
  end loop;
end;
$$;

-- =========================================================
-- 4. subscriptions_generate_payment_requests trigger: fires on the same event DEC-070's
--    reminder triggers already react to (next_renewal_date change), extending that
--    precedent to payment requests. Writes to a disjoint table (payment_requests via
--    shared_subscriptions), so no alphabetical-firing-order interaction with
--    subscriptions_generate_default_reminders / subscriptions_cancel_stale_reminders.
-- =========================================================

create or replace function public.handle_subscription_renewal_payment_requests()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.archived_at is not null then
    return new;
  end if;

  if old.next_renewal_date is distinct from new.next_renewal_date then
    perform public.generate_payment_requests_for_shared_subscription(new.id, new.next_renewal_date);
  end if;

  return new;
end;
$$;

drop trigger if exists subscriptions_generate_payment_requests on public.subscriptions;
create trigger subscriptions_generate_payment_requests
after update of next_renewal_date
on public.subscriptions
for each row execute function public.handle_subscription_renewal_payment_requests();

-- =========================================================
-- 5. rebalance_equal_split_members(target_shared_subscription_id): for split_method =
--    'equal' only, recomputes amount_owed for every active member as
--    subscriptions.cost / active_member_count. Never touches payment_requests -- already-
--    generated rows are immutable per-cycle snapshots (doc 10).
--
--    Rounding note: round(cost / active_count, 2) will not always sum exactly back to
--    cost (e.g. Rs.1000/3 -> Rs.333.33 x 3 = Rs.999.99 total). This is an accepted MVP
--    simplification -- the same tradeoff every simple bill-splitting feature makes -- not
--    a bug being deferred.
-- =========================================================

create or replace function public.rebalance_equal_split_members(target_shared_subscription_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  parent_split public.split_method;
  parent_cost numeric(12,2);
  active_count integer;
  per_member numeric(12,2);
begin
  select ss.split_method, s.cost
  into parent_split, parent_cost
  from public.shared_subscriptions ss
  join public.subscriptions s on s.id = ss.subscription_id
  where ss.id = target_shared_subscription_id;

  if not found or parent_split <> 'equal' then
    return;
  end if;

  select count(*) into active_count
  from public.shared_members
  where shared_subscription_id = target_shared_subscription_id and status = 'active';

  if active_count = 0 then
    return;
  end if;

  -- See rounding note above: intentionally not distributing the leftover remainder cent(s).
  per_member := round(parent_cost / active_count, 2);

  update public.shared_members
  set amount_owed = per_member, updated_at = now()
  where shared_subscription_id = target_shared_subscription_id and status = 'active';
end;
$$;

-- =========================================================
-- 6. shared_members_generate_initial_request trigger: closes the gap where sharing setup
--    or a new member joining an already-shared subscription would otherwise generate no
--    payment_requests row until the next next_renewal_date change (DEC-080 planning-pass
--    resolution). Rebalances first (so a brand-new equal-split member's own amount_owed is
--    correct before it's read), then generates that one member's first request against the
--    parent subscription's CURRENT next_renewal_date.
-- =========================================================

create or replace function public.handle_shared_member_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  target_renewal_date date;
begin
  perform public.rebalance_equal_split_members(new.shared_subscription_id);

  select s.next_renewal_date into target_renewal_date
  from public.shared_subscriptions ss
  join public.subscriptions s on s.id = ss.subscription_id
  where ss.id = new.shared_subscription_id
    and ss.archived_at is null;

  if target_renewal_date is not null and new.status = 'active' then
    perform public.generate_payment_request_for_member(new.id, target_renewal_date);
  end if;

  return new;
end;
$$;

drop trigger if exists shared_members_generate_initial_request on public.shared_members;
create trigger shared_members_generate_initial_request
after insert
on public.shared_members
for each row execute function public.handle_shared_member_insert();

-- =========================================================
-- 7. shared_members_rebalance_on_remove trigger: rebalances remaining active members when
--    one is soft-removed. No payment_requests side effect -- DEC-080 explicitly rules out
--    cascade-cancelling a removed member's open requests (payment history preservation).
-- =========================================================

create or replace function public.handle_shared_member_soft_remove()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if old.status = 'active' and new.status = 'removed' then
    perform public.rebalance_equal_split_members(new.shared_subscription_id);
  end if;

  return new;
end;
$$;

drop trigger if exists shared_members_rebalance_on_remove on public.shared_members;
create trigger shared_members_rebalance_on_remove
after update of status
on public.shared_members
for each row execute function public.handle_shared_member_soft_remove();

-- Notes for whoever runs this file:
--
-- - All 5 new functions are SECURITY DEFINER, matching every existing trigger function in
--   17_SubSense_Migration_v2.sql / 29_SubSense_Reminder_Lifecycle_Patch_v1.0.sql -- they
--   bypass RLS by design, but only ever fire as a side effect of a write the client could
--   already make under existing RLS (subscriptions owner-update, shared_members
--   owner-insert/update). No new client-writable surface is introduced.
-- - Idempotent to re-run: CREATE OR REPLACE FUNCTION and DROP TRIGGER IF EXISTS make the
--   whole file safe to run more than once. The two ALTER TABLE blocks at the top use
--   DROP CONSTRAINT IF EXISTS before re-adding, for the same reason.
-- - Does not touch: shared_subscriptions_archive_cascade / cancel_payment_requests_for_
--   archived_share() (archiving is a separate, already-correct case, untouched by this
--   patch); validate_shared_currency() / validate_shared_member_currency() /
--   validate_payment_request() / validate_payment_request_transition() (all unchanged);
--   the touch_updated_at triggers on any of the three tables (unchanged).
-- - No backfill: subscriptions already shared before this migration runs will not
--   retroactively generate payment_requests rows for cycles that already started. The
--   first payment_requests row for any pre-existing shared_subscriptions row appears at
--   its next next_renewal_date change, or the next time a member is added, same as every
--   other forward-only migration in this project (see file 29's own note).
