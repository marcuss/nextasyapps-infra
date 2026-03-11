-- Migration 010: Backfill couples table for existing paired users
-- Creates a couples record for every profile that already has partner_id set.
-- Uses LEAST/GREATEST to ensure consistent ordering (partner1_id < partner2_id).

INSERT INTO public.couples (partner1_id, partner2_id)
SELECT
  LEAST(id, partner_id)::uuid,
  GREATEST(id, partner_id)::uuid
FROM public.profiles
WHERE partner_id IS NOT NULL
ON CONFLICT (partner1_id, partner2_id) DO NOTHING;
