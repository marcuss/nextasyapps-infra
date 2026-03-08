-- =============================================================================
-- Migration 009: Normalize RLS policies across dev and prod
-- =============================================================================
-- Problem: In prod, the policy "Users can read their couple assignments" was
-- manually modified after migration 005 failed (referenced non-existent
-- public.couples table). This migration ensures both environments have
-- the exact same policy definition.
--
-- This migration is idempotent: DROP IF EXISTS + CREATE.
-- =============================================================================

-- Drop the old policy (may have different definitions in dev vs prod)
DROP POLICY IF EXISTS "Users can read their couple assignments" ON public.daily_question_assignments;

-- Recreate with the correct definition (uses profiles.partner_id, not couples table)
CREATE POLICY "Users can read their couple assignments" ON public.daily_question_assignments
  FOR SELECT USING (
    couple_id IN (
      -- User's own ID
      SELECT auth.uid()
      UNION
      -- Partner's ID (if paired)
      SELECT p.partner_id FROM public.profiles p
      WHERE p.id = auth.uid() AND p.partner_id IS NOT NULL
    )
  );

-- Also normalize the insert policy to be consistent
DROP POLICY IF EXISTS "Users can insert couple assignments" ON public.daily_question_assignments;

CREATE POLICY "Users can insert couple assignments" ON public.daily_question_assignments
  FOR INSERT WITH CHECK (
    couple_id IN (
      SELECT auth.uid()
      UNION
      SELECT p.partner_id FROM public.profiles p
      WHERE p.id = auth.uid() AND p.partner_id IS NOT NULL
    )
  );

-- Normalize answer policies too
DROP POLICY IF EXISTS "Users can insert their own answers" ON public.daily_answers;
DROP POLICY IF EXISTS "Users can read couple answers" ON public.daily_answers;

CREATE POLICY "Users can insert their own answers" ON public.daily_answers
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can read couple answers" ON public.daily_answers
  FOR SELECT USING (
    user_id = auth.uid()
    OR user_id IN (
      SELECT p.partner_id FROM public.profiles p
      WHERE p.id = auth.uid() AND p.partner_id IS NOT NULL
    )
  );
