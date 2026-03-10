-- Migration 004: Add city_override column to profiles
-- Allows users to manually pin a city for date ideas,
-- independently of their GPS/detected location.

ALTER TABLE profiles ADD COLUMN IF NOT EXISTS city_override TEXT;
