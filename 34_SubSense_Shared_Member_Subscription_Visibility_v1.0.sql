-- 34_SubSense_Shared_Member_Subscription_Visibility_v1.0.sql
-- Fixes a real bug found live-testing Phase 8: a linked shared member (real account,
-- shared_members.user_id correctly linked, status = 'active') saw "Nothing shared yet" on
-- SharedSubscriptionsPage, even though shared_subscriptions_select_owner_or_member's RLS
-- check should have passed for her.
--
-- Root cause, confirmed by a full static trace of current_app_user_id() /
-- is_shared_subscription_member() / the RLS policy itself (all structurally correct as
-- deployed): the failure isn't the RLS person-check at all. useSharedSubscriptionsList.ts's
-- query embeds subscriptions(...) inside the same shared_subscriptions select, and
-- subscriptions_select_own (17_SubSense_Migration_v2.sql) grants SELECT to the owner only
-- -- zero member exception. Since shared_subscriptions.subscription_id is NOT NULL,
-- PostgREST's default embed for that relationship is inner-join-like: when the embedded
-- subscriptions row is invisible to the caller's role (true for every linked member, on
-- every share, unconditionally), the ENTIRE parent shared_subscriptions row silently
-- disappears from the result -- even though shared_subscriptions' own RLS would have
-- allowed it. This migration is the DB-side half of the fix; the other half is a one-line
-- query change (subscriptions!left(...) instead of subscriptions(...) in
-- useSharedSubscriptionsList.ts) so the parent row can never be swallowed this way again,
-- regardless of future RLS changes.
--
-- Confirmed with the user before writing this (not silently scoped): closing this
-- properly means giving members real visibility into which subscription they're sharing,
-- not just stopping the row from disappearing and leaving them looking at "Untitled
-- subscription" forever.
--
-- No schema change, no new enum value -- single transaction, no two-step split needed.
-- Idempotent to re-run (DROP POLICY IF EXISTS before CREATE POLICY).

-- Additive policy -- Postgres OR's multiple permissive policies for the same command on
-- the same table, so this does NOT touch or replace the existing subscriptions_select_own
-- (owner-only) policy; it only adds a second condition under which SELECT is permitted.
--
-- Scope tradeoff, flagged rather than narrowed silently: this is a full-row SELECT grant,
-- matching this project's own established RLS convention everywhere else in this schema
-- (no column-level security exists anywhere in this codebase -- every policy here,
-- including subscriptions_select_own itself, is table+row scoped, never column scoped).
-- That means a linked member also gains visibility into cost, payment_method, and
-- payment_reference_note for the shared subscription, not just its display name. cost is
-- arguably not new sensitive information (a member already sees their own derived share
-- via payment_requests.amount); payment_method/payment_reference_note (e.g. a personal UPI
-- note) is closer to owner-private information. Inventing a column-level-security
-- mechanism this codebase has never used anywhere would be a bigger departure than this
-- bug fix warrants -- accepted as-is per direct confirmation, not assumed.
--
-- No archived-subscription exclusion -- matches subscriptions_select_own's own precedent,
-- which doesn't exclude archived rows either (the owner can see their own archived
-- subscriptions too); consistency over inventing a new rule this migration wasn't asked
-- to add.
drop policy if exists subscriptions_select_shared_member on public.subscriptions;
create policy subscriptions_select_shared_member
on public.subscriptions for select
to authenticated
using (
  exists (
    select 1
    from public.shared_subscriptions ss
    join public.shared_members sm on sm.shared_subscription_id = ss.id
    where ss.subscription_id = subscriptions.id
      and sm.user_id = public.current_app_user_id()
      and sm.status = 'active'
  )
);

-- Notes for whoever runs this file:
--
-- - Does not touch: subscriptions_select_own, subscriptions_update_own, or any other
--   existing policy on any table. Does not touch RLS on shared_subscriptions,
--   shared_members, or payment_requests -- those were already correct.
-- - The query-side half of this fix (subscriptions!left(...) in
--   useSharedSubscriptionsList.ts) ships as a normal code commit in the Subsense-web repo,
--   not as part of this migration.
