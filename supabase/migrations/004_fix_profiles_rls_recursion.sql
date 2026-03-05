-- Fix: infinite recursion in profiles RLS policy
-- The "Users can read partner profile" policy queries profiles table
-- which triggers itself causing infinite recursion.
-- Solution: use a SECURITY DEFINER function to bypass RLS when looking up partner_id.

-- Step 1: Create a security definer function to get partner_id without RLS
CREATE OR REPLACE FUNCTION get_partner_id(user_id uuid)
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT partner_id FROM profiles WHERE id = user_id;
$$;

-- Step 2: Replace the recursive policy with one using the function
DROP POLICY IF EXISTS "Users can read partner profile" ON profiles;

CREATE POLICY "Users can read partner profile" ON profiles
  FOR SELECT
  USING (id = get_partner_id(auth.uid()));
