-- Add gender, relationship_type, partner_name, and has_children columns to profiles table
ALTER TABLE profiles ADD COLUMN gender TEXT;
ALTER TABLE profiles ADD COLUMN relationship_type TEXT;
ALTER TABLE profiles ADD COLUMN partner_name TEXT;
ALTER TABLE profiles ADD COLUMN has_children BOOLEAN DEFAULT false;
