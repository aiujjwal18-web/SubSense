-- 37_SubSense_Premium_Plan_Name_Patch_v1.0.sql
-- Purpose: Cosmetic fix — premium_plans.name for plan_code='premium_demo_monthly'
-- displayed as "Premium Demo Monthly" on /profile (PlanComparisonCard), which reads
-- oddly to end users. plan_code itself (the stable identifier used in code, Edge
-- Functions, and payment_transactions.premium_plan_id joins) is untouched.
-- No schema change, no RLS/constraint change — display text only.

update public.premium_plans
set name = 'Premium Monthly (Demo)'
where plan_code = 'premium_demo_monthly';
