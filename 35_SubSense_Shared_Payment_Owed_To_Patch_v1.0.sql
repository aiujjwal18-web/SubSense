-- 35_SubSense_Shared_Payment_Owed_To_Patch_v1.0.sql
-- Incremental patch on top of 17_SubSense_Migration_v2.sql (seeds this row) and
-- 23_SubSense_Notification_Copy_Patch_v1.0.sql (last updated this row's copy, DEC-047).
--
-- What changed and why: send-reminder-email's shared_payment context previously carried
-- only { subscription_name, amount, currency } — the email never stated who the money was
-- owed to. A payment request with no named sender reads as suspicious/spam-like, a real
-- trust problem for a feature whose whole point is getting people to actually pay each
-- other. The Edge Function now resolves the subscription owner's name (user_profiles.
-- display_name, populated at signup independent of the still-unbuilt Profile page; falls
-- back to users.email, then a generic "the subscription owner" string, if somehow both are
-- null) and passes it as a new {{owed_to}} context token. This patch adds that token to the
-- live template copy.
--
-- Placement: the owner's name is put in the subject line, not just the body — visible in an
-- inbox preview before the email is even opened, which is what actually fixes the
-- trust/spam-risk problem rather than just documenting it inside an opened email.
--
-- Only this one row changes; the other 7 notification_templates rows are untouched.

update public.notification_templates
set subject = '{{owed_to}} requests {{amount}} {{currency}} for {{subscription_name}}',
    body = '{{owed_to}} is requesting your share of {{subscription_name}} this cycle — {{amount}} {{currency}}. Mark it paid whenever you''ve settled it.',
    updated_at = now()
where template_code = 'reminder_shared_payment';

-- =========================================================
-- Verification query — run after the update above to confirm
-- =========================================================
-- select template_code, subject, body from public.notification_templates where template_code = 'reminder_shared_payment';
