-- Add invite_code and expires_at to invitations table
ALTER TABLE invitations ADD COLUMN invite_code VARCHAR(6);
ALTER TABLE invitations ADD COLUMN expires_at TIMESTAMPTZ;

-- Make to_email nullable (no longer required for code-based invitations)
ALTER TABLE invitations ALTER COLUMN to_email DROP NOT NULL;

-- Unique index on invite_code for pending invitations only
CREATE UNIQUE INDEX idx_invitations_code_pending
  ON invitations (invite_code)
  WHERE status = 'pending' AND invite_code IS NOT NULL;

-- Index for fast code lookup
CREATE INDEX idx_invitations_invite_code ON invitations (invite_code);

-- Allow any authenticated user to look up invitations by code
CREATE POLICY "Users can lookup invitations by code"
  ON invitations FOR SELECT
  USING (auth.role() = 'authenticated');
