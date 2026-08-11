-- 36_SubSense_Shared_Payment_Owed_To_Body_Fix_v1.0.sql
-- Incremental patch on top of 35_SubSense_Shared_Payment_Owed_To_Patch_v1.0.sql
-- (added {{owed_to}} to this row's subject and body, run and verified live).
--
-- What changed and why: email-template.ts renders the subject line a second time
-- as the email's <h1> heading inside the body (`<h1>${subject}</h1>`), before the
-- template's own `body` text follows below it. Since file 35 put {{owed_to}} in
-- both the subject and the body's opening sentence, a real sent email showed the
-- subscription owner's name twice in a row — once as the heading (mirroring the
-- subject), once again as the first two words of the paragraph immediately below
-- it. Confirmed via a live test send to uch2717@gmail.com.
--
-- Fix: keep {{owed_to}} in the subject only (that's what actually solves the
-- inbox-preview trust/spam-risk problem this was built for) and drop the
-- redundant restatement from the body, since the heading already covers it.
--
-- Only this one row changes; the other 7 notification_templates rows are untouched.

update public.notification_templates
set body = 'Your share of {{subscription_name}} this cycle is {{amount}} {{currency}}. Mark it paid whenever you''ve settled it.',
    updated_at = now()
where template_code = 'reminder_shared_payment';

-- =========================================================
-- Verification query — run after the update above to confirm
-- =========================================================
-- select template_code, subject, body from public.notification_templates where template_code = 'reminder_shared_payment';
