-- SubSense initial Supabase schema
-- Generated from 10_Database_Architecture_v1.1.md.
-- v2: fixes Critical/High/Medium findings from live test runs (executed against a real disposable
--     Postgres instance, not just read).
--   Critical: reminder-generation triggers now SECURITY DEFINER (were blocked by their own target
--             table's RLS, which broke Add Subscription entirely); seeded subscription_catalog and
--             notification_templates so Add Subscription search and the reminder-email pipeline are
--             not empty/broken on a fresh database; replaced the self-referential
--             is_payment_request_owner()/is_payment_request_member() helpers (which re-queried
--             payment_requests from inside a policy on payment_requests) with is_shared_member_self(),
--             fixing a confirmed live bug where INSERT ... RETURNING on payment_requests -- the exact
--             pattern the Supabase client SDK uses (`.insert().select()`) -- was silently rejected by RLS.
--   High:     generate_default_reminders() now actually reads user_preferences.reminder_default_days
--             instead of hardcoding 7/2/0; added a guard trigger so users cannot self-edit their own
--             email_verified/account_status/user_code/auth_provider; added 16 missing FK indexes.
--   Medium:   removed the orphaned review_status enum; replaced the near-meaningless premium expiry
--             CHECK with a live-evaluation helper function; replaced the blanket authenticated GRANT
--             with per-table/per-function grants that mirror the actual RLS policy set.
--
-- Every fix above was verified with a live test: sign up two users, add a subscription, create a
-- shared subscription + member + payment request (with RETURNING), run the full owner/member
-- permission chain, archive-cascade, attempt premium/identity self-escalation, and re-check object
-- counts/indexes/seed data. All pass cleanly.

create extension if not exists pgcrypto;

create type public.account_status as enum ('active', 'archived', 'suspended');
create type public.theme as enum ('system', 'light', 'dark');
create type public.currency as enum ('INR', 'USD');
create type public.billing_frequency as enum ('monthly', 'every_28_days', 'yearly', 'custom');
create type public.lifecycle_status as enum ('active', 'review_due', 'renewal_confirmed', 'paused', 'archived');
create type public.payment_method as enum ('upi_autopay', 'card_emandate', 'app_store', 'manual');
create type public.delivery_status as enum ('queued', 'sent', 'failed', 'bounced');
create type public.transaction_status as enum ('created', 'verified', 'failed');
create type public.notification_channel as enum ('email');
create type public.trigger_source as enum ('system', 'user', 'developer');
create type public.actor_type as enum ('user', 'service', 'admin');
create type public.audit_action as enum (
  'auth_profile_provisioned',
  'subscription_created',
  'subscription_updated',
  'subscription_archived',
  'shared_member_changed',
  'payment_request_changed',
  'reminder_executed',
  'ai_generated',
  'email_delivery_failed',
  'payment_verified',
  'security_failure'
);
create type public.premium_source as enum ('razorpay_test_mode', 'manual_grant');
create type public.split_method as enum ('equal', 'custom');
create type public.member_status as enum ('active', 'removed');
create type public.payment_request_status as enum ('pending', 'paid_pending_confirmation', 'paid', 'cancelled');
create type public.reminder_type as enum (
  'seven_day',
  'two_day',
  'renewal_day',
  'post_renewal_checkin',
  'shared_payment',
  'dev_test'
);
create type public.reminder_status as enum ('pending', 'sent', 'skipped_archived', 'failed');
-- Medium fix: dropped the unused `review_status` enum (0 columns referenced it in the v1 migration).

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table public.users (
  id uuid primary key default gen_random_uuid(),
  user_code text not null unique default ('USR-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 10))),
  auth_user_id uuid not null unique references auth.users(id) on delete cascade,
  email text not null unique,
  auth_provider text,
  account_status public.account_status not null default 'active',
  email_verified boolean not null default false,
  last_login_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  constraint users_archived_after_created check (archived_at is null or archived_at >= created_at)
);

create table public.user_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.users(id) on delete cascade,
  display_name text,
  profile_photo_url text,
  country text,
  timezone text not null default 'Asia/Kolkata',
  default_currency public.currency not null default 'INR',
  is_premium boolean not null default false,
  premium_expires_at timestamptz,
  premium_source public.premium_source not null default 'manual_grant',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_profiles_timezone_not_blank check (length(trim(timezone)) > 0)
  -- Medium fix: removed `user_profiles_premium_expiry_consistent` (it compared premium_expires_at to
  -- created_at, which is nearly always true and does not guard anything meaningful; worse, an
  -- equivalent check against now() would block innocuous profile edits once premium organically
  -- expires before a batch job flips is_premium). Entitlement is now evaluated live via
  -- public.user_has_active_premium().
);

create table public.user_preferences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.users(id) on delete cascade,
  email_notifications boolean not null default true,
  reminder_default_days integer[] not null default array[7, 2, 0],
  theme public.theme not null default 'system',
  dashboard_layout jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_preferences_reminder_days_allowed check (
    reminder_default_days <@ array[7, 2, 0]
  )
);

create table public.subscription_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  slug text not null unique,
  created_at timestamptz not null default now()
);

create table public.subscription_catalog (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references public.subscription_categories(id) on delete set null,
  name text not null,
  slug text not null unique,
  website_url text,
  created_by_user_id uuid references public.users(id) on delete set null,
  approved_at timestamptz,
  created_at timestamptz not null default now(),
  constraint subscription_catalog_name_not_blank check (length(trim(name)) > 0)
);

create table public.premium_plans (
  id uuid primary key default gen_random_uuid(),
  plan_code text not null unique,
  name text not null,
  amount numeric(12,2) not null,
  currency public.currency not null default 'INR',
  duration_days integer,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  constraint premium_plans_amount_nonnegative check (amount >= 0),
  constraint premium_plans_duration_positive check (duration_days is null or duration_days > 0)
);

create table public.notification_templates (
  id uuid primary key default gen_random_uuid(),
  template_code text not null unique,
  channel public.notification_channel not null default 'email',
  subject text not null,
  body text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete restrict,
  catalog_id uuid references public.subscription_catalog(id) on delete set null,
  custom_name text,
  cost numeric(12,2) not null,
  currency public.currency not null,
  billing_frequency public.billing_frequency not null,
  custom_interval_days integer,
  next_renewal_date date not null,
  payment_method public.payment_method not null,
  payment_reference_note text,
  lifecycle_status public.lifecycle_status not null default 'active',
  monthly_equivalent numeric(12,2) not null default 0,
  annual_equivalent numeric(12,2) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  constraint subscriptions_name_required check (
    catalog_id is not null or length(trim(coalesce(custom_name, ''))) > 0
  ),
  constraint subscriptions_cost_positive check (cost > 0),
  constraint subscriptions_custom_interval_valid check (
    (billing_frequency <> 'custom' and custom_interval_days is null)
    or (billing_frequency = 'custom' and custom_interval_days is not null and custom_interval_days > 0)
  ),
  constraint subscriptions_archived_after_created check (archived_at is null or archived_at >= created_at)
);

create table public.shared_subscriptions (
  id uuid primary key default gen_random_uuid(),
  subscription_id uuid not null unique references public.subscriptions(id) on delete restrict,
  owner_user_id uuid not null references public.users(id) on delete restrict,
  split_method public.split_method not null default 'equal',
  currency public.currency not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  constraint shared_subscriptions_archived_after_created check (archived_at is null or archived_at >= created_at)
);

create table public.shared_members (
  id uuid primary key default gen_random_uuid(),
  shared_subscription_id uuid not null references public.shared_subscriptions(id) on delete restrict,
  user_id uuid references public.users(id) on delete set null,
  display_name text,
  email text,
  amount_owed numeric(12,2) not null,
  currency public.currency not null,
  status public.member_status not null default 'active',
  joined_at timestamptz not null default now(),
  removed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint shared_members_identity_present check (
    user_id is not null or length(trim(coalesce(display_name, ''))) > 0 or length(trim(coalesce(email, ''))) > 0
  ),
  constraint shared_members_amount_nonnegative check (amount_owed >= 0),
  constraint shared_members_removed_state check (
    (status = 'active' and removed_at is null)
    or (status = 'removed' and removed_at is not null)
  )
);

create table public.payment_requests (
  id uuid primary key default gen_random_uuid(),
  shared_subscription_id uuid not null references public.shared_subscriptions(id) on delete restrict,
  shared_member_id uuid not null references public.shared_members(id) on delete restrict,
  billing_cycle_date date not null,
  amount numeric(12,2) not null,
  currency public.currency not null,
  status public.payment_request_status not null default 'pending',
  member_marked_paid_at timestamptz,
  owner_confirmed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint payment_requests_one_per_member_cycle unique (shared_member_id, billing_cycle_date),
  constraint payment_requests_amount_positive check (amount > 0),
  constraint payment_requests_member_marked_paid_consistent check (
    status <> 'paid_pending_confirmation' or member_marked_paid_at is not null
  ),
  constraint payment_requests_owner_confirmed_consistent check (
    status <> 'paid' or owner_confirmed_at is not null
  )
);

create table public.reminders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete restrict,
  subscription_id uuid references public.subscriptions(id) on delete restrict,
  payment_request_id uuid references public.payment_requests(id) on delete restrict,
  reminder_type public.reminder_type not null,
  scheduled_for timestamptz not null,
  timezone_snapshot text not null,
  status public.reminder_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint reminders_target_present check (subscription_id is not null or payment_request_id is not null),
  constraint reminders_shared_payment_target check (
    (reminder_type = 'shared_payment' and payment_request_id is not null)
    or (reminder_type <> 'shared_payment' and subscription_id is not null)
  ),
  constraint reminders_timezone_not_blank check (length(trim(timezone_snapshot)) > 0)
);

create table public.ai_recommendations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete restrict,
  subscription_id uuid references public.subscriptions(id) on delete restrict,
  recommendation_text text not null,
  reason_text text,
  financial_impact jsonb not null default '{}'::jsonb,
  model_version text not null,
  generated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete restrict,
  reminder_id uuid references public.reminders(id) on delete set null,
  payment_request_id uuid references public.payment_requests(id) on delete set null,
  channel public.notification_channel not null default 'email',
  template_id uuid references public.notification_templates(id) on delete restrict,
  delivery_status public.delivery_status not null default 'queued',
  provider_message_id text,
  sent_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.payment_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete restrict,
  premium_plan_id uuid references public.premium_plans(id) on delete restrict,
  razorpay_order_id text not null unique,
  razorpay_payment_id text,
  razorpay_signature text,
  amount numeric(12,2) not null,
  currency public.currency not null,
  status public.transaction_status not null default 'created',
  failure_reason text,
  verified_at timestamptz,
  created_at timestamptz not null default now(),
  constraint payment_transactions_amount_positive check (amount > 0),
  constraint payment_transactions_verified_consistent check (
    status <> 'verified' or (razorpay_payment_id is not null and verified_at is not null)
  )
);

create table public.reminder_history (
  id uuid primary key default gen_random_uuid(),
  reminder_id uuid references public.reminders(id) on delete set null,
  user_id uuid references public.users(id) on delete set null,
  attempted_at timestamptz not null default now(),
  delivery_status public.delivery_status,
  provider_message_id text,
  error_code text,
  error_message text,
  trigger_source public.trigger_source not null default 'system'
);

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_user_id uuid references public.users(id) on delete set null,
  actor_type public.actor_type not null default 'user',
  action public.audit_action not null,
  entity_table text,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.system_settings (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);

create unique index shared_members_active_email_unique
  on public.shared_members (shared_subscription_id, lower(email))
  where status = 'active' and email is not null;

create unique index reminders_pending_subscription_type_unique
  on public.reminders (subscription_id, reminder_type)
  where reminder_type in ('seven_day', 'two_day', 'renewal_day', 'post_renewal_checkin')
    and status = 'pending';

create unique index payment_transactions_payment_id_unique
  on public.payment_transactions (razorpay_payment_id)
  where razorpay_payment_id is not null;

create index ai_recommendations_latest_idx
  on public.ai_recommendations (user_id, subscription_id, generated_at desc);

create index notifications_user_created_idx
  on public.notifications (user_id, created_at desc);

create index reminders_due_idx
  on public.reminders (status, scheduled_for);

create index payment_requests_shared_subscription_idx
  on public.payment_requests (shared_subscription_id, status);

-- High fix: 16 FK/RLS-filter columns previously had zero index. Added below.
create index subscriptions_user_id_idx on public.subscriptions (user_id);
create index subscriptions_catalog_id_idx on public.subscriptions (catalog_id);
create index shared_subscriptions_owner_user_id_idx on public.shared_subscriptions (owner_user_id);
create index shared_members_user_id_idx on public.shared_members (user_id);
create index reminders_user_id_idx on public.reminders (user_id);
create index reminders_payment_request_id_idx on public.reminders (payment_request_id);
create index notifications_reminder_id_idx on public.notifications (reminder_id);
create index notifications_payment_request_id_idx on public.notifications (payment_request_id);
create index notifications_template_id_idx on public.notifications (template_id);
create index payment_transactions_user_id_idx on public.payment_transactions (user_id);
create index payment_transactions_premium_plan_id_idx on public.payment_transactions (premium_plan_id);
create index reminder_history_reminder_id_idx on public.reminder_history (reminder_id);
create index reminder_history_user_id_idx on public.reminder_history (user_id);
create index audit_logs_actor_user_id_idx on public.audit_logs (actor_user_id);
create index subscription_catalog_category_id_idx on public.subscription_catalog (category_id);
create index subscription_catalog_created_by_user_id_idx on public.subscription_catalog (created_by_user_id);

create or replace function public.current_app_user_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select u.id
  from public.users u
  where u.auth_user_id = auth.uid()
  limit 1
$$;

create or replace function public.is_shared_subscription_owner(target_shared_subscription_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.shared_subscriptions ss
    where ss.id = target_shared_subscription_id
      and ss.owner_user_id = public.current_app_user_id()
  )
$$;

create or replace function public.is_shared_subscription_member(target_shared_subscription_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.shared_members sm
    where sm.shared_subscription_id = target_shared_subscription_id
      and sm.user_id = public.current_app_user_id()
      and sm.status = 'active'
  )
$$;

-- Critical fix: the original is_payment_request_owner()/is_payment_request_member() took the
-- payment_requests.id and re-queried `payment_requests` itself (a self-join back into the very table
-- the RLS policy protects). That self-reference silently breaks `INSERT ... RETURNING` on
-- payment_requests -- the exact pattern the Supabase client SDK uses (`.insert().select()`) -- even
-- though the functions are SECURITY DEFINER: a plain SELECT after the insert sees the row fine, but the
-- RETURNING clause's row-security check on the same command does not. Confirmed via live test (insert
-- succeeds without RETURNING, fails with it, and fails identically even with the INSERT policy forced to
-- `true`, proving the SELECT policy's self-referential lookup was the cause).
-- Fix: check the row's own foreign keys (shared_subscription_id, shared_member_id) directly instead of
-- re-querying payment_requests by id. Neither helper below queries payment_requests at all.
create or replace function public.is_shared_member_self(target_shared_member_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.shared_members sm
    where sm.id = target_shared_member_id
      and sm.user_id = public.current_app_user_id()
  )
$$;

-- Medium fix: live entitlement check, replacing the removed static premium-expiry CHECK constraint.
create or replace function public.user_has_active_premium(target_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select p.is_premium and (p.premium_expires_at is null or p.premium_expires_at > now())
     from public.user_profiles p
     where p.user_id = target_user_id),
    false
  )
$$;

create or replace function public.calculate_subscription_equivalents()
returns trigger
language plpgsql
as $$
declare
  interval_days numeric;
begin
  interval_days := case new.billing_frequency
    when 'monthly' then 365.0 / 12.0
    when 'every_28_days' then 28
    when 'yearly' then 365
    when 'custom' then new.custom_interval_days
  end;

  if interval_days is null or interval_days <= 0 then
    raise exception 'Invalid billing interval';
  end if;

  new.annual_equivalent := round((new.cost * (365.0 / interval_days))::numeric, 2);
  new.monthly_equivalent := round((new.annual_equivalent / 12.0)::numeric, 2);
  return new;
end;
$$;

create trigger subscriptions_calculate_equivalents
before insert or update of cost, billing_frequency, custom_interval_days
on public.subscriptions
for each row execute function public.calculate_subscription_equivalents();

create or replace function public.local_date_at_9am_tz(input_date date, input_timezone text)
returns timestamptz
language sql
stable
as $$
  select (input_date + time '09:00')::timestamp at time zone input_timezone
$$;

-- Critical fix: was plain SECURITY INVOKER. `reminders` intentionally has no client INSERT policy
-- (system-only writes), so when this ran as the invoking `authenticated` role, its own INSERT was
-- rejected by RLS, rolling back the entire subscription insert. Now SECURITY DEFINER, matching the
-- same pattern already used by handle_new_user().
-- High fix: now actually reads user_preferences.reminder_default_days instead of hardcoding 7/2/0.
create or replace function public.generate_default_reminders()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  user_tz text;
  selected_days integer[];
  d integer;
  target_type public.reminder_type;
  target_date date;
begin
  if new.archived_at is not null then
    return new;
  end if;

  select p.timezone into user_tz
  from public.user_profiles p
  where p.user_id = new.user_id;

  user_tz := coalesce(user_tz, 'Asia/Kolkata');

  select pr.reminder_default_days into selected_days
  from public.user_preferences pr
  where pr.user_id = new.user_id;

  selected_days := coalesce(selected_days, array[7, 2, 0]);

  foreach d in array selected_days loop
    target_type := case d
      when 7 then 'seven_day'
      when 2 then 'two_day'
      when 0 then 'renewal_day'
      else null
    end;

    if target_type is null then
      continue;
    end if;

    target_date := new.next_renewal_date - d;

    insert into public.reminders (user_id, subscription_id, reminder_type, scheduled_for, timezone_snapshot)
    values (new.user_id, new.id, target_type, public.local_date_at_9am_tz(target_date, user_tz), user_tz)
    on conflict do nothing;
  end loop;

  return new;
end;
$$;

create trigger subscriptions_generate_default_reminders
after insert or update of next_renewal_date, archived_at
on public.subscriptions
for each row execute function public.generate_default_reminders();

-- Critical fix: was plain SECURITY INVOKER; writes to `reminders` (no client UPDATE policy) were
-- rejected by RLS when a real user archived their own subscription. Now SECURITY DEFINER.
create or replace function public.skip_reminders_for_archived_subscription()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if old.archived_at is null and new.archived_at is not null then
    update public.reminders
    set status = 'skipped_archived', updated_at = now()
    where subscription_id = new.id and status = 'pending';

    update public.shared_subscriptions
    set archived_at = coalesce(archived_at, new.archived_at), updated_at = now()
    where subscription_id = new.id and archived_at is null;
  end if;

  return new;
end;
$$;

create trigger subscriptions_archive_cascade
after update of archived_at
on public.subscriptions
for each row execute function public.skip_reminders_for_archived_subscription();

-- Hardening: made SECURITY DEFINER for consistency with the other cascade triggers rather than relying
-- on the coincidence that the subscription owner and shared_subscription owner are always the same user.
create or replace function public.cancel_payment_requests_for_archived_share()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if old.archived_at is null and new.archived_at is not null then
    update public.payment_requests
    set status = 'cancelled', updated_at = now()
    where shared_subscription_id = new.id
      and status in ('pending', 'paid_pending_confirmation');
  end if;

  return new;
end;
$$;

create trigger shared_subscriptions_archive_cascade
after update of archived_at
on public.shared_subscriptions
for each row execute function public.cancel_payment_requests_for_archived_share();

create or replace function public.validate_shared_currency()
returns trigger
language plpgsql
as $$
declare
  parent_currency public.currency;
begin
  select s.currency into parent_currency
  from public.subscriptions s
  where s.id = new.subscription_id;

  if parent_currency is null or new.currency <> parent_currency then
    raise exception 'Shared subscription currency must match parent subscription currency';
  end if;

  return new;
end;
$$;

create trigger shared_subscriptions_validate_currency
before insert or update of subscription_id, currency
on public.shared_subscriptions
for each row execute function public.validate_shared_currency();

create or replace function public.validate_shared_member_currency()
returns trigger
language plpgsql
as $$
declare
  parent_currency public.currency;
begin
  select ss.currency into parent_currency
  from public.shared_subscriptions ss
  where ss.id = new.shared_subscription_id;

  if parent_currency is null or new.currency <> parent_currency then
    raise exception 'Shared member currency must match parent shared subscription currency';
  end if;

  return new;
end;
$$;

create trigger shared_members_validate_currency
before insert or update of shared_subscription_id, currency
on public.shared_members
for each row execute function public.validate_shared_member_currency();

create or replace function public.validate_payment_request()
returns trigger
language plpgsql
as $$
declare
  member_parent uuid;
  member_currency public.currency;
begin
  select sm.shared_subscription_id, sm.currency
  into member_parent, member_currency
  from public.shared_members sm
  where sm.id = new.shared_member_id;

  if member_parent is null or member_parent <> new.shared_subscription_id then
    raise exception 'Payment request member must belong to the shared subscription';
  end if;

  if new.currency <> member_currency then
    raise exception 'Payment request currency must match shared member currency';
  end if;

  return new;
end;
$$;

create trigger payment_requests_validate_parentage
before insert or update of shared_subscription_id, shared_member_id, currency
on public.payment_requests
for each row execute function public.validate_payment_request();

create or replace function public.validate_payment_request_transition()
returns trigger
language plpgsql
as $$
declare
  actor_user_id uuid;
  owner_user_id uuid;
  member_user_id uuid;
  is_owner boolean;
  is_member boolean;
begin
  if tg_op <> 'UPDATE' then
    return new;
  end if;

  if auth.role() = 'service_role' then
    return new;
  end if;

  select public.current_app_user_id() into actor_user_id;

  select ss.owner_user_id, sm.user_id
  into owner_user_id, member_user_id
  from public.payment_requests pr
  join public.shared_subscriptions ss on ss.id = pr.shared_subscription_id
  join public.shared_members sm on sm.id = pr.shared_member_id
  where pr.id = old.id;

  is_owner := actor_user_id is not null and actor_user_id = owner_user_id;
  is_member := actor_user_id is not null and actor_user_id = member_user_id;

  if is_member and not is_owner then
    if old.status = new.status then
      raise exception 'Linked members may only update payment status through pending to paid_pending_confirmation';
    end if;

    if not (old.status = 'pending' and new.status = 'paid_pending_confirmation') then
      raise exception 'Linked members may only mark pending requests as paid_pending_confirmation';
    end if;

    if new.shared_subscription_id <> old.shared_subscription_id
      or new.shared_member_id <> old.shared_member_id
      or new.billing_cycle_date <> old.billing_cycle_date
      or new.amount <> old.amount
      or new.currency <> old.currency
      or new.owner_confirmed_at is distinct from old.owner_confirmed_at then
      raise exception 'Linked members may not change payment request business fields';
    end if;

    new.member_marked_paid_at := coalesce(new.member_marked_paid_at, now());
  elsif is_owner then
    if not (
      (old.status = 'pending' and new.status in ('paid_pending_confirmation', 'paid', 'cancelled'))
      or (old.status = 'paid_pending_confirmation' and new.status in ('paid', 'cancelled'))
      or old.status = new.status
    ) then
      raise exception 'Invalid owner payment request status transition';
    end if;

    if new.status = 'paid' then
      new.owner_confirmed_at := coalesce(new.owner_confirmed_at, now());
    end if;
  elsif old.status = new.status then
    return new;
  else
    raise exception 'Not authorized to update payment request status';
  end if;

  return new;
end;
$$;

create trigger payment_requests_validate_transition
before update
on public.payment_requests
for each row execute function public.validate_payment_request_transition();

create or replace function public.protect_premium_profile_fields()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'UPDATE'
    and auth.role() <> 'service_role'
    and (
      new.is_premium is distinct from old.is_premium
      or new.premium_expires_at is distinct from old.premium_expires_at
      or new.premium_source is distinct from old.premium_source
    ) then
    raise exception 'Premium entitlement fields are service-role write only';
  end if;

  return new;
end;
$$;

create trigger user_profiles_protect_premium_fields
before update
on public.user_profiles
for each row execute function public.protect_premium_profile_fields();

-- High fix: same protection pattern as premium fields, applied to identity/status columns on `users`
-- that were previously self-editable by the row owner (users_update_own_limited only checked ownership,
-- not which columns changed).
create or replace function public.protect_user_identity_fields()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'UPDATE'
    and auth.role() <> 'service_role'
    and (
      new.email_verified is distinct from old.email_verified
      or new.account_status is distinct from old.account_status
      or new.user_code is distinct from old.user_code
      or new.auth_provider is distinct from old.auth_provider
    ) then
    raise exception 'Identity and status fields on users are service-role write only';
  end if;

  return new;
end;
$$;

create trigger users_protect_identity_fields
before update
on public.users
for each row execute function public.protect_user_identity_fields();

create or replace function public.scrub_payment_signature()
returns trigger
language plpgsql
as $$
begin
  new.razorpay_signature := null;
  return new;
end;
$$;

create trigger payment_transactions_scrub_signature
before insert or update of razorpay_signature, status
on public.payment_transactions
for each row execute function public.scrub_payment_signature();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  app_user_id uuid;
begin
  insert into public.users (auth_user_id, email, auth_provider, email_verified)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_app_meta_data ->> 'provider', 'email'),
    coalesce((new.email_confirmed_at is not null), false)
  )
  on conflict (auth_user_id) do update
    set email = excluded.email,
        updated_at = now()
  returning id into app_user_id;

  insert into public.user_profiles (user_id, display_name, profile_photo_url)
  values (
    app_user_id,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name'),
    new.raw_user_meta_data ->> 'avatar_url'
  )
  on conflict (user_id) do nothing;

  insert into public.user_preferences (user_id)
  values (app_user_id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create trigger users_touch_updated_at
before update on public.users
for each row execute function public.touch_updated_at();

create trigger user_profiles_touch_updated_at
before update on public.user_profiles
for each row execute function public.touch_updated_at();

create trigger user_preferences_touch_updated_at
before update on public.user_preferences
for each row execute function public.touch_updated_at();

create trigger notification_templates_touch_updated_at
before update on public.notification_templates
for each row execute function public.touch_updated_at();

create trigger subscriptions_touch_updated_at
before update on public.subscriptions
for each row execute function public.touch_updated_at();

create trigger shared_subscriptions_touch_updated_at
before update on public.shared_subscriptions
for each row execute function public.touch_updated_at();

create trigger shared_members_touch_updated_at
before update on public.shared_members
for each row execute function public.touch_updated_at();

create trigger payment_requests_touch_updated_at
before update on public.payment_requests
for each row execute function public.touch_updated_at();

create trigger reminders_touch_updated_at
before update on public.reminders
for each row execute function public.touch_updated_at();

alter table public.users enable row level security;
alter table public.user_profiles enable row level security;
alter table public.user_preferences enable row level security;
alter table public.subscription_categories enable row level security;
alter table public.subscription_catalog enable row level security;
alter table public.premium_plans enable row level security;
alter table public.notification_templates enable row level security;
alter table public.subscriptions enable row level security;
alter table public.shared_subscriptions enable row level security;
alter table public.shared_members enable row level security;
alter table public.payment_requests enable row level security;
alter table public.reminders enable row level security;
alter table public.ai_recommendations enable row level security;
alter table public.notifications enable row level security;
alter table public.payment_transactions enable row level security;
alter table public.reminder_history enable row level security;
alter table public.audit_logs enable row level security;
alter table public.system_settings enable row level security;

create policy users_select_own
on public.users for select
to authenticated
using (auth_user_id = auth.uid());

create policy users_update_own_limited
on public.users for update
to authenticated
using (auth_user_id = auth.uid())
with check (auth_user_id = auth.uid());

create policy user_profiles_select_own
on public.user_profiles for select
to authenticated
using (user_id = public.current_app_user_id());

create policy user_profiles_update_own
on public.user_profiles for update
to authenticated
using (user_id = public.current_app_user_id())
with check (user_id = public.current_app_user_id());

create policy user_preferences_select_own
on public.user_preferences for select
to authenticated
using (user_id = public.current_app_user_id());

create policy user_preferences_update_own
on public.user_preferences for update
to authenticated
using (user_id = public.current_app_user_id())
with check (user_id = public.current_app_user_id());

create policy subscription_categories_authenticated_read
on public.subscription_categories for select
to authenticated
using (true);

create policy subscription_catalog_authenticated_read
on public.subscription_catalog for select
to authenticated
using (approved_at is not null or created_by_user_id = public.current_app_user_id());

create policy premium_plans_authenticated_read
on public.premium_plans for select
to authenticated
using (is_active = true);

create policy subscriptions_select_own
on public.subscriptions for select
to authenticated
using (user_id = public.current_app_user_id());

create policy subscriptions_insert_own
on public.subscriptions for insert
to authenticated
with check (user_id = public.current_app_user_id());

create policy subscriptions_update_own
on public.subscriptions for update
to authenticated
using (user_id = public.current_app_user_id())
with check (user_id = public.current_app_user_id());

create policy shared_subscriptions_select_owner_or_member
on public.shared_subscriptions for select
to authenticated
using (
  owner_user_id = public.current_app_user_id()
  or public.is_shared_subscription_member(id)
);

create policy shared_subscriptions_insert_owner
on public.shared_subscriptions for insert
to authenticated
with check (owner_user_id = public.current_app_user_id());

create policy shared_subscriptions_update_owner
on public.shared_subscriptions for update
to authenticated
using (owner_user_id = public.current_app_user_id())
with check (owner_user_id = public.current_app_user_id());

create policy shared_members_select_owner_or_self
on public.shared_members for select
to authenticated
using (
  user_id = public.current_app_user_id()
  or public.is_shared_subscription_owner(shared_subscription_id)
);

create policy shared_members_insert_owner
on public.shared_members for insert
to authenticated
with check (public.is_shared_subscription_owner(shared_subscription_id));

create policy shared_members_update_owner
on public.shared_members for update
to authenticated
using (public.is_shared_subscription_owner(shared_subscription_id))
with check (public.is_shared_subscription_owner(shared_subscription_id));

create policy payment_requests_select_owner_or_member
on public.payment_requests for select
to authenticated
using (
  public.is_shared_subscription_owner(shared_subscription_id)
  or public.is_shared_member_self(shared_member_id)
);

create policy payment_requests_insert_owner
on public.payment_requests for insert
to authenticated
with check (public.is_shared_subscription_owner(shared_subscription_id));

create policy payment_requests_update_owner_or_member
on public.payment_requests for update
to authenticated
using (
  public.is_shared_subscription_owner(shared_subscription_id)
  or public.is_shared_member_self(shared_member_id)
)
with check (
  public.is_shared_subscription_owner(shared_subscription_id)
  or public.is_shared_member_self(shared_member_id)
);

create policy reminders_select_own
on public.reminders for select
to authenticated
using (user_id = public.current_app_user_id());

create policy ai_recommendations_select_own
on public.ai_recommendations for select
to authenticated
using (user_id = public.current_app_user_id());

create policy notifications_select_own
on public.notifications for select
to authenticated
using (user_id = public.current_app_user_id());

create policy payment_transactions_select_own
on public.payment_transactions for select
to authenticated
using (user_id = public.current_app_user_id());

create policy reminder_history_select_own
on public.reminder_history for select
to authenticated
using (user_id = public.current_app_user_id());

-- Medium fix: replaced the blanket "grant select, insert, update on all tables ... to authenticated"
-- with per-table grants that mirror the actual RLS policy set. RLS was already the real gate (no policy
-- existed for the tables that had no business being writable), but a blanket table-level grant is a
-- single point of failure if RLS is ever accidentally disabled on one table in a future migration.
grant usage on schema public to anon, authenticated, service_role;

grant all privileges on all tables in schema public to service_role;
grant all privileges on all sequences in schema public to service_role;
grant execute on all functions in schema public to service_role;

-- Read-only master/system/output data for authenticated clients (RLS still scopes which rows are visible)
grant select on
  public.subscription_categories,
  public.subscription_catalog,
  public.premium_plans,
  public.reminders,
  public.ai_recommendations,
  public.notifications,
  public.payment_transactions,
  public.reminder_history
to authenticated;

-- users: update grant retained for policy compatibility; the protect_user_identity_fields trigger now
-- blocks the specific columns that must remain service-role only regardless of this grant.
grant select, update on public.users to authenticated;

-- Path A CRUD tables per 11_API_Integration_Architecture_v1.0
grant select, insert, update on
  public.user_profiles,
  public.user_preferences,
  public.subscriptions,
  public.shared_subscriptions,
  public.shared_members,
  public.payment_requests
to authenticated;

-- RLS-helper functions invoked directly from policy USING/WITH CHECK expressions.
grant execute on function
  public.current_app_user_id(),
  public.is_shared_subscription_owner(uuid),
  public.is_shared_subscription_member(uuid),
  public.is_shared_member_self(uuid),
  public.user_has_active_premium(uuid)
to authenticated;

insert into public.subscription_categories (name, slug)
values
  ('Entertainment', 'entertainment'),
  ('Productivity', 'productivity'),
  ('Education', 'education'),
  ('Utilities', 'utilities'),
  ('Other', 'other')
on conflict do nothing;

insert into public.premium_plans (plan_code, name, amount, currency, duration_days)
values
  ('free', 'Free', 0, 'INR', null),
  ('premium_demo_monthly', 'Premium Demo Monthly', 199, 'INR', 30)
on conflict do nothing;

-- Critical fix: subscription_catalog previously shipped with zero rows, so Add Subscription's
-- "searchable catalog" (01_Product_Strategy_v1.3) would be empty on any fresh environment.
insert into public.subscription_catalog (category_id, name, slug, website_url, approved_at)
select c.id, v.name, v.slug, v.website_url, now()
from (values
  ('entertainment', 'Netflix', 'netflix', 'https://netflix.com'),
  ('entertainment', 'Amazon Prime Video', 'amazon-prime-video', 'https://primevideo.com'),
  ('entertainment', 'Disney+ Hotstar', 'disney-plus-hotstar', 'https://hotstar.com'),
  ('entertainment', 'YouTube Premium', 'youtube-premium', 'https://youtube.com/premium'),
  ('entertainment', 'Spotify', 'spotify', 'https://spotify.com'),
  ('productivity', 'ChatGPT Plus', 'chatgpt-plus', 'https://openai.com/chatgpt'),
  ('productivity', 'Google One', 'google-one', 'https://one.google.com'),
  ('productivity', 'Microsoft 365', 'microsoft-365', 'https://microsoft.com/microsoft-365'),
  ('productivity', 'Notion', 'notion', 'https://notion.so'),
  ('utilities', 'iCloud+', 'icloud-plus', 'https://apple.com/icloud')
) as v(category_slug, name, slug, website_url)
join public.subscription_categories c on c.slug = v.category_slug
on conflict do nothing;

-- Critical fix: notification_templates previously shipped with zero rows, so every single reminder
-- would fail with NOTIF_001 template missing (11_API_Integration_Architecture_v1.0) on a fresh database.
insert into public.notification_templates (template_code, channel, subject, body, is_active)
values
  ('reminder_seven_day', 'email', 'Your {{subscription_name}} renews in 7 days',
   'This is a reminder that {{subscription_name}} will renew on {{renewal_date}} for {{amount}} {{currency}}.', true),
  ('reminder_two_day', 'email', 'Your {{subscription_name}} renews in 2 days',
   'This is a reminder that {{subscription_name}} will renew on {{renewal_date}} for {{amount}} {{currency}}.', true),
  ('reminder_renewal_day', 'email', '{{subscription_name}} renews today',
   '{{subscription_name}} renews today for {{amount}} {{currency}}. Review it in SubSense if you want to make a change.', true),
  ('reminder_post_renewal_checkin', 'email', 'How is {{subscription_name}} working out?',
   '{{subscription_name}} renewed recently. Take a moment to review whether it is still worth keeping.', true),
  ('reminder_shared_payment', 'email', 'Payment request for {{subscription_name}}',
   'You have a pending payment request of {{amount}} {{currency}} for {{subscription_name}}.', true),
  ('reminder_dev_test', 'email', 'Test reminder',
   'This is a Developer/Test Utilities test reminder payload.', true)
on conflict do nothing;
