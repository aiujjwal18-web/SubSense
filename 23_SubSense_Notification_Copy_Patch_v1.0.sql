-- 23_SubSense_Notification_Copy_Patch_v1.0.sql
-- Incremental patch on top of 17_SubSense_Migration_v2.sql (which seeds the first 6 rows below)
-- and 20_SubSense_Retention_Patch_v1.0.sql (which seeds the last 2 rows below).
-- Implements the finalized notification_templates copy per DEC-047 (08_Decision_Log_v1.14).
-- Status: RUN AND VERIFIED LIVE — executed against the live Supabase project and confirmed via a
-- read-only select of all 8 notification_templates rows: all 7 updated rows match this file's
-- subject/body exactly, and reminder_dev_test is confirmed unchanged, as intended.
--
-- What changed and why: the original seed copy (17, 20) used one shared sentence skeleton across
-- reminder_seven_day/reminder_two_day ("Your {{subscription_name}} renews in N days... this is a
-- reminder that {{subscription_name}} will renew on {{renewal_date}} for {{amount}} {{currency}}"),
-- which read as mechanical and repeated the subscription name twice for no reason. Each template
-- below is written with its own opening and structure — variety is between template types, not
-- within repeated sends of the same type (that's a deliberate, recorded scope line: DEC-047 leaves
-- per-send rotation out of MVP, since the repetition-fatigue problem it would solve mainly applies
-- to AI insight cards viewed together on one screen per DEC-045, not to emails read days apart).
-- reminder_dev_test is intentionally left unchanged — it is a Developer/Test Utilities payload with
-- no real user ever seeing it, so brand-voice polish isn't worth the effort per MVP scope discipline.
--
-- All eight rows already exist (created by 17 and 20); this file only updates subject/body content,
-- it does not insert or delete rows.

update public.notification_templates
set subject = '{{subscription_name}} renews in a week',
    body = '{{subscription_name}} renews on {{renewal_date}} for {{amount}} {{currency}}. A week''s a good amount of runway if you want to reconsider it — nothing to do otherwise.',
    updated_at = now()
where template_code = 'reminder_seven_day';

update public.notification_templates
set subject = '{{subscription_name}} renews in 2 days',
    body = '{{amount}} {{currency}} charges in 2 days for {{subscription_name}}. Last real window to make a call before it renews.',
    updated_at = now()
where template_code = 'reminder_two_day';

update public.notification_templates
set subject = '{{subscription_name}} renews today',
    body = '{{amount}} {{currency}} goes out today for {{subscription_name}}. If that''s expected, no action needed — otherwise, today''s your last easy window to catch it before the charge.',
    updated_at = now()
where template_code = 'reminder_renewal_day';

update public.notification_templates
set subject = 'Still worth it — {{subscription_name}}?',
    body = '{{subscription_name}} just renewed. Worth a 10-second gut check: still using it enough to justify {{amount}} {{currency}}?',
    updated_at = now()
where template_code = 'reminder_post_renewal_checkin';

update public.notification_templates
set subject = '{{amount}} {{currency}} owed for {{subscription_name}}',
    body = 'Your share of {{subscription_name}} this cycle is {{amount}} {{currency}}. Mark it paid whenever you''ve settled it.',
    updated_at = now()
where template_code = 'reminder_shared_payment';

update public.notification_templates
set subject = '{{active_subscription_count}} subscriptions, {{monthly_spend}} {{currency}} this month',
    body = 'You''re running {{active_subscription_count}} active subscriptions at {{monthly_spend}} {{currency}} a month ({{annual_spend}} {{currency}} a year). {{ai_insight_count}} insights are sitting in your Decision Workspace if you want a closer look.',
    updated_at = now()
where template_code = 'reminder_monthly_digest';

update public.notification_templates
set subject = 'Your subscriptions didn''t pause while you were away',
    body = 'You haven''t opened SubSense in a while — meanwhile {{active_subscription_count}} subscriptions kept renewing at {{monthly_spend}} {{currency}} a month. Worth a look next time you have a minute.',
    updated_at = now()
where template_code = 'reminder_lapsed_reengagement';

-- reminder_dev_test: no change (subject 'Test reminder', body unchanged from 17_SubSense_Migration_v2).

-- =========================================================
-- Verification query — run after the updates above to confirm all 8 rows are as expected
-- =========================================================
-- select template_code, subject, body from public.notification_templates order by template_code;
