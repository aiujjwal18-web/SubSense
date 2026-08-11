-- 32_SubSense_Equal_Split_Fixes_v1.0.sql
-- Two scoped fixes to rebalance_equal_split_members() (31_SubSense_Shared_Payment_
-- Requests_v1.0.sql), both found live-testing Phase 8 (Shared Subscriptions). No schema
-- change, no new enum value -- single transaction, no two-step split needed.
--
-- Fix 1 -- equal-split formula must count the owner as a sharer. Before this patch,
-- per_member = round(cost / active_count, 2), where active_count only counts
-- shared_members rows -- the owner (who pays nothing into shared_members, since they ARE
-- the subscription) was never represented in that count at all. With 1 member, that
-- member was billed the FULL cost instead of half. Fix: divide by active_count + 1 -- the
-- owner is the implicit "+1," no new shared_members row needed for them, no schema change.
--
-- Fix 2 -- a still-pending payment_requests row must track the live split, not freeze the
-- instant it's created. Confirmed live: add member A (a request generates for A at
-- whatever the split is right then, per the shared_members-insert trigger from file 31),
-- then add member B -- B's shared_members.amount_owed recalculates correctly via the
-- existing rebalance, but A's already-generated request stayed stuck at the old, wrong
-- number even though A hadn't done anything with it yet. Fix: the same function that
-- rebalances shared_members.amount_owed now also syncs payment_requests.amount for any
-- request that is still status = 'pending' AND belongs to a currently-active member of
-- this split. The instant a request moves past pending (paid_pending_confirmation, paid,
-- cancelled), it's untouched -- exactly as it already worked before this patch. A removed
-- member's own already-issued pending request is also left untouched, since it's excluded
-- by the "currently-active member" filter -- that's a separate, already-correct behavior
-- (payment-history preservation), not something this patch changes.
--
-- Both fixes apply uniformly whether the rebalance was triggered by a member joining
-- (shared_members_generate_initial_request) or a member being removed
-- (shared_members_rebalance_on_remove) -- both triggers already call this same function,
-- so neither trigger itself needs any change.
--
-- Verified against the existing payment_requests_validate_transition trigger (doc 10 /
-- file 17, DEC-037) before writing this: the new UPDATE below only ever touches `amount`/
-- `updated_at`, never `status` -- and that trigger's owner branch explicitly allows
-- `old.status = new.status` (a same-status update), so this cannot be rejected by it. It
-- also never touches shared_subscription_id/shared_member_id/currency, so the separate
-- payment_requests_validate_parentage trigger (BEFORE INSERT OR UPDATE OF those three
-- columns specifically) never even fires for this UPDATE.

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

  -- No currently-active member means nothing to rebalance -- also means no pending
  -- payment_requests row could belong to a "currently-active member" either, so skipping
  -- the sync below in this case is correct, not just an optimization.
  if active_count = 0 then
    return;
  end if;

  -- +1: the owner is an implicit sharer, never represented by a shared_members row of
  -- their own. Rounding note (unchanged from file 31): round(cost / (active_count + 1), 2)
  -- will not always sum exactly back to cost (e.g. Rs.1000 with 2 members -> Rs.1000/3 ->
  -- Rs.333.33 x 3 = Rs.999.99 total across the 2 members alone, before the owner's own
  -- Rs.333.34-ish share). Accepted MVP simplification, not a bug being deferred.
  per_member := round(parent_cost / (active_count + 1), 2);

  update public.shared_members
  set amount_owed = per_member, updated_at = now()
  where shared_subscription_id = target_shared_subscription_id and status = 'active';

  -- Sync still-open requests to the freshly computed amount -- closes the "frozen at
  -- creation time" gap. Deliberately scoped to status = 'pending' only (never
  -- paid_pending_confirmation/paid/cancelled) and to currently-active members only (a
  -- removed member's own pending request is left exactly as it was).
  update public.payment_requests pr
  set amount = per_member, updated_at = now()
  where pr.shared_subscription_id = target_shared_subscription_id
    and pr.status = 'pending'
    and pr.shared_member_id in (
      select id from public.shared_members
      where shared_subscription_id = target_shared_subscription_id and status = 'active'
    );
end;
$$;

-- Notes for whoever runs this file:
--
-- - CREATE OR REPLACE FUNCTION only -- no new trigger, no trigger drop/recreate, no schema
--   change. Idempotent to re-run.
-- - Does not touch: generate_payment_request_for_member(),
--   generate_payment_requests_for_shared_subscription(),
--   handle_subscription_renewal_payment_requests(), handle_shared_member_insert(),
--   handle_shared_member_soft_remove(), or either of their triggers (all unchanged --
--   both already call rebalance_equal_split_members(), so the fix reaches both call paths
--   automatically). Does not touch shared_subscriptions_archive_cascade,
--   payment_requests_validate_transition, payment_requests_validate_parentage, or any RLS
--   policy.
-- - No backfill: shared_members.amount_owed and any still-pending payment_requests.amount
--   for an EXISTING equal-split subscription won't self-correct until the next time this
--   function actually runs (a member joins or is removed on that subscription). If you
--   want already-wrong live rows corrected immediately, that's a one-off manual step (e.g.
--   re-running `select rebalance_equal_split_members(id) from shared_subscriptions where
--   split_method = 'equal'`), not something this migration does automatically -- same
--   forward-only convention every prior migration in this project has followed.
