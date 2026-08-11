-- 20_SubSense_Retention_Patch_v1.0.sql
-- Incremental patch on top of the already-applied 17_SubSense_Migration_v2.sql.
-- Implements the Retention Policy (DEC-041, see 01_Product_Strategy_v1.10 and 10_Database_Architecture_v1.7).
--
-- IMPORTANT: run this in two steps, not as one pasted block.
-- Postgres will not let a new enum value be used by an INSERT in the same
-- transaction/statement batch that added it. Run Step 1, confirm it completes,
-- then run Step 2 separately.

-- =========================================================
-- STEP 1 — run this first, on its own
-- =========================================================

alter type public.reminder_type add value if not exists 'monthly_digest';
alter type public.reminder_type add value if not exists 'lapsed_reengagement';

-- =========================================================
-- STEP 2 — run this after Step 1 has committed
-- =========================================================

insert into public.notification_templates (template_code, channel, subject, body, is_active)
values
  ('reminder_monthly_digest', 'email', 'Your SubSense monthly digest',
   'Here is where your money went this month: {{monthly_spend}} {{currency}} across {{active_subscription_count}} active subscriptions ({{annual_spend}} {{currency}} a year). {{ai_insight_count}} new insights are waiting for review.', true),
  ('reminder_lapsed_reengagement', 'email', 'Your subscriptions, at a glance',
   'It has been a while. You currently have {{active_subscription_count}} active subscriptions totalling {{monthly_spend}} {{currency}} a month. Come take a look whenever it is convenient.', true)
on conflict do nothing;

-- Notes for the Phase 6 (Reminder Engine) implementation, per 10_Database_Architecture_v1.7:
--
-- monthly_digest:
--   - A scheduled function (Path B, cron) runs once per calendar month.
--   - For every user with at least one non-archived subscription, check whether a
--     'monthly_digest' row already exists for that user in the current calendar month
--     (status 'pending' or 'sent') before inserting a new one.
--   - scheduled_for should use the same local_date_at_9am_tz(...) pattern already used
--     by generate_default_reminders(), computed against user_profiles.timezone.
--
-- lapsed_reengagement:
--   - A scheduled function (Path B, cron) runs daily and selects users where
--     users.last_login_at < now() - interval '45 days' (or is null and
--     users.created_at < now() - interval '45 days').
--   - Before inserting, check no 'lapsed_reengagement' row exists for that user with
--     scheduled_for within the last 45 days, to enforce the one-per-rolling-window cap.
--   - Both jobs are system-only writes (service role), matching the existing RLS pattern
--     for the reminders table: owners get select-only; insert/update stay backend-controlled.
