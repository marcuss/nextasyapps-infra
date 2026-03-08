-- =============================================================================
-- LoveCompass — Core Schema
-- Migration 001: All tables, indexes, RLS policies, and helper functions
-- =============================================================================
-- This is the definitive schema. All tables are created with their final
-- column definitions. No ALTER TABLE migrations needed.
-- =============================================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =============================================================================
-- PROFILES
-- =============================================================================

CREATE TABLE public.profiles (
  id                uuid        NOT NULL,
  name              text        NOT NULL,
  email             text        NOT NULL UNIQUE,
  partner_id        uuid,
  is_premium        boolean     DEFAULT false,
  created_at        timestamptz NOT NULL DEFAULT timezone('utc', now()),
  city              text,
  city_updated_at   timestamptz,
  date_of_birth     date,
  gender            text,
  relationship_type text,
  partner_name      text,
  has_children      boolean     DEFAULT false,

  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id),
  CONSTRAINT profiles_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.profiles(id)
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Helper function: must be defined AFTER profiles table exists.
-- SECURITY DEFINER bypasses RLS to avoid infinite recursion.
CREATE OR REPLACE FUNCTION public.get_partner_id(user_id uuid)
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT partner_id FROM profiles WHERE id = user_id;
$$;

CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can read own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

-- Uses get_partner_id() to avoid infinite recursion
CREATE POLICY "Users can read partner profile" ON public.profiles
  FOR SELECT USING (id = public.get_partner_id(auth.uid()));

-- =============================================================================
-- INVITATIONS
-- =============================================================================

CREATE TABLE public.invitations (
  id            uuid        NOT NULL DEFAULT gen_random_uuid(),
  from_user_id  uuid        NOT NULL,
  to_email      text,                -- nullable: code-based invitations don't need email
  status        text        DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at    timestamptz NOT NULL DEFAULT timezone('utc', now()),
  invite_code   varchar(6),          -- 6-char alphanumeric code (no 0/O/1/I/L)
  expires_at    timestamptz,         -- code expiration (48h default)

  CONSTRAINT invitations_pkey PRIMARY KEY (id),
  CONSTRAINT invitations_from_user_id_fkey FOREIGN KEY (from_user_id) REFERENCES public.profiles(id)
);

-- Unique code per pending invitation
CREATE UNIQUE INDEX idx_invitations_code_pending
  ON public.invitations (invite_code)
  WHERE status = 'pending' AND invite_code IS NOT NULL;

CREATE INDEX idx_invitations_invite_code
  ON public.invitations (invite_code);

ALTER TABLE public.invitations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can create invitations" ON public.invitations
  FOR INSERT WITH CHECK (auth.uid() = from_user_id);

CREATE POLICY "Users can read own invitations" ON public.invitations
  FOR SELECT USING (auth.uid() = from_user_id);

CREATE POLICY "Users can read invitations sent to their email" ON public.invitations
  FOR SELECT USING (
    to_email = (SELECT email FROM public.profiles WHERE id = auth.uid())
  );

CREATE POLICY "Users can update invitation status" ON public.invitations
  FOR UPDATE USING (
    to_email = (SELECT email FROM public.profiles WHERE id = auth.uid())
  );

CREATE POLICY "Users can lookup invitations by code" ON public.invitations
  FOR SELECT USING (auth.role() = 'authenticated');

-- =============================================================================
-- GOALS
-- =============================================================================

CREATE TABLE public.goals (
  id          uuid        NOT NULL DEFAULT gen_random_uuid(),
  title       text        NOT NULL,
  description text,
  category    text        DEFAULT 'personal' CHECK (category IN ('travel', 'financial', 'personal', 'home', 'other')),
  target_date date,
  completed   boolean     DEFAULT false,
  created_by  uuid        NOT NULL,
  created_at  timestamptz NOT NULL DEFAULT timezone('utc', now()),

  CONSTRAINT goals_pkey PRIMARY KEY (id),
  CONSTRAINT goals_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id)
);

ALTER TABLE public.goals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Couple can read goals" ON public.goals
  FOR SELECT USING (created_by = auth.uid() OR created_by = public.get_partner_id(auth.uid()));

CREATE POLICY "Users can create goals" ON public.goals
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update own goals" ON public.goals
  FOR UPDATE USING (auth.uid() = created_by);

CREATE POLICY "Users can delete own goals" ON public.goals
  FOR DELETE USING (auth.uid() = created_by);

-- =============================================================================
-- TASKS
-- =============================================================================

CREATE TABLE public.tasks (
  id          uuid        NOT NULL DEFAULT gen_random_uuid(),
  title       text        NOT NULL,
  description text,
  category    text        DEFAULT 'shared' CHECK (category IN ('home', 'work', 'personal', 'shared')),
  assigned_to uuid,
  due_date    date,
  completed   boolean     DEFAULT false,
  created_by  uuid        NOT NULL,
  created_at  timestamptz NOT NULL DEFAULT timezone('utc', now()),

  CONSTRAINT tasks_pkey PRIMARY KEY (id),
  CONSTRAINT tasks_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.profiles(id),
  CONSTRAINT tasks_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id)
);

ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Couple can read tasks" ON public.tasks
  FOR SELECT USING (
    created_by = auth.uid()
    OR assigned_to = auth.uid()
    OR created_by = public.get_partner_id(auth.uid())
  );

CREATE POLICY "Users can create tasks" ON public.tasks
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update own tasks" ON public.tasks
  FOR UPDATE USING (auth.uid() = created_by OR assigned_to = auth.uid());

CREATE POLICY "Users can delete own tasks" ON public.tasks
  FOR DELETE USING (auth.uid() = created_by);

-- =============================================================================
-- EVENTS
-- =============================================================================

CREATE TABLE public.events (
  id          uuid        NOT NULL DEFAULT gen_random_uuid(),
  title       text        NOT NULL,
  description text,
  date        date        NOT NULL,
  time        text,
  type        text        DEFAULT 'personal' CHECK (type IN ('personal', 'shared')),
  user_id     uuid        NOT NULL,
  color       text        DEFAULT '#f43f5e',
  created_at  timestamptz NOT NULL DEFAULT timezone('utc', now()),

  CONSTRAINT events_pkey PRIMARY KEY (id),
  CONSTRAINT events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);

ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Couple can read events" ON public.events
  FOR SELECT USING (user_id = auth.uid() OR user_id = public.get_partner_id(auth.uid()));

CREATE POLICY "Users can create events" ON public.events
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own events" ON public.events
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own events" ON public.events
  FOR DELETE USING (auth.uid() = user_id);

-- =============================================================================
-- BUDGETS
-- =============================================================================

CREATE TABLE public.budgets (
  id         uuid        NOT NULL DEFAULT gen_random_uuid(),
  category   text        NOT NULL,
  amount     numeric     NOT NULL,
  spent      numeric     DEFAULT 0,
  year       integer     DEFAULT EXTRACT(year FROM CURRENT_DATE),
  created_by uuid        NOT NULL,
  created_at timestamptz NOT NULL DEFAULT timezone('utc', now()),

  CONSTRAINT budgets_pkey PRIMARY KEY (id),
  CONSTRAINT budgets_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id)
);

ALTER TABLE public.budgets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Couple can read budgets" ON public.budgets
  FOR SELECT USING (created_by = auth.uid() OR created_by = public.get_partner_id(auth.uid()));

CREATE POLICY "Users can create budgets" ON public.budgets
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update own budgets" ON public.budgets
  FOR UPDATE USING (auth.uid() = created_by);

CREATE POLICY "Users can delete own budgets" ON public.budgets
  FOR DELETE USING (auth.uid() = created_by);

-- =============================================================================
-- EXPENSES
-- =============================================================================

CREATE TABLE public.expenses (
  id          uuid        NOT NULL DEFAULT gen_random_uuid(),
  budget_id   uuid        NOT NULL,
  description text        NOT NULL,
  amount      numeric     NOT NULL,
  date        date        DEFAULT CURRENT_DATE,
  created_by  uuid        NOT NULL,
  created_at  timestamptz NOT NULL DEFAULT timezone('utc', now()),

  CONSTRAINT expenses_pkey PRIMARY KEY (id),
  CONSTRAINT expenses_budget_id_fkey FOREIGN KEY (budget_id) REFERENCES public.budgets(id),
  CONSTRAINT expenses_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id)
);

ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Couple can read expenses" ON public.expenses
  FOR SELECT USING (created_by = auth.uid() OR created_by = public.get_partner_id(auth.uid()));

CREATE POLICY "Users can create expenses" ON public.expenses
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update own expenses" ON public.expenses
  FOR UPDATE USING (auth.uid() = created_by);

CREATE POLICY "Users can delete own expenses" ON public.expenses
  FOR DELETE USING (auth.uid() = created_by);

-- =============================================================================
-- TRAVELS
-- =============================================================================

CREATE TABLE public.travels (
  id               uuid        NOT NULL DEFAULT gen_random_uuid(),
  destination      text        NOT NULL,
  description      text,
  start_date       date,
  end_date         date,
  estimated_budget numeric,
  status           text        DEFAULT 'planning' CHECK (status IN ('planning', 'booked', 'completed')),
  created_by       uuid        NOT NULL,
  created_at       timestamptz NOT NULL DEFAULT timezone('utc', now()),

  CONSTRAINT travels_pkey PRIMARY KEY (id),
  CONSTRAINT travels_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id)
);

ALTER TABLE public.travels ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Couple can read travels" ON public.travels
  FOR SELECT USING (created_by = auth.uid() OR created_by = public.get_partner_id(auth.uid()));

CREATE POLICY "Users can create travels" ON public.travels
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update own travels" ON public.travels
  FOR UPDATE USING (auth.uid() = created_by);

CREATE POLICY "Users can delete own travels" ON public.travels
  FOR DELETE USING (auth.uid() = created_by);

-- =============================================================================
-- DATE IDEAS
-- =============================================================================

CREATE TABLE public.date_ideas (
  id           uuid    PRIMARY KEY DEFAULT gen_random_uuid(),
  city         text    NOT NULL,
  date         date    NOT NULL DEFAULT CURRENT_DATE,
  ideas        jsonb   NOT NULL,
  generated_at timestamptz DEFAULT now(),
  UNIQUE(city, date)
);

CREATE TABLE public.date_ideas_feedback (
  id                uuid    PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           uuid    NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  city              text    NOT NULL,
  date              date    NOT NULL DEFAULT CURRENT_DATE,
  feedback_text     text,
  personalized_ideas jsonb,
  created_at        timestamptz DEFAULT now()
);

ALTER TABLE public.date_ideas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.date_ideas_feedback ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read date ideas" ON public.date_ideas
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users manage own feedback" ON public.date_ideas_feedback
  FOR ALL TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- =============================================================================
-- CALENDAR CONNECTIONS
-- =============================================================================

CREATE TABLE public.calendar_connections (
  id                      uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                 uuid        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  provider                text        NOT NULL CHECK (provider IN ('google', 'apple')),
  provider_account_email  text,
  access_token            text,
  refresh_token           text,
  token_expires_at        timestamptz,
  is_active               boolean     NOT NULL DEFAULT true,
  selected_calendars      jsonb       NOT NULL DEFAULT '[]'::jsonb,
  webhook_channel_id      text,
  webhook_resource_id     text,
  webhook_expires_at      timestamptz,
  last_synced_at          timestamptz,
  created_at              timestamptz NOT NULL DEFAULT now(),
  updated_at              timestamptz NOT NULL DEFAULT now(),
  UNIQUE(user_id, provider)
);

-- =============================================================================
-- CALENDAR EVENTS CACHE
-- =============================================================================

CREATE TABLE public.calendar_events_cache (
  id                   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  connection_id        uuid        NOT NULL REFERENCES public.calendar_connections(id) ON DELETE CASCADE,
  user_id              uuid        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  external_id          text        NOT NULL,
  calendar_id          text,
  title                text        NOT NULL,
  description          text,
  start_time           timestamptz NOT NULL,
  end_time             timestamptz,
  is_all_day           boolean     NOT NULL DEFAULT false,
  location             text,
  color                text,
  provider             text        NOT NULL CHECK (provider IN ('google', 'apple')),
  raw_data             jsonb,
  couple_plan_event_id uuid        REFERENCES public.events(id) ON DELETE SET NULL,
  etag                 text,
  synced_at            timestamptz NOT NULL DEFAULT now(),
  UNIQUE(connection_id, external_id)
);

-- =============================================================================
-- CALENDAR SYNC LOG
-- =============================================================================

CREATE TABLE public.calendar_sync_log (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  connection_id   uuid        REFERENCES public.calendar_connections(id) ON DELETE SET NULL,
  user_id         uuid        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  sync_type       text        NOT NULL CHECK (sync_type IN ('push', 'pull', 'webhook', 'manual')),
  direction       text        NOT NULL CHECK (direction IN ('to_external', 'from_external', 'both')),
  status          text        NOT NULL CHECK (status IN ('success', 'partial', 'failed')),
  events_pushed   integer     NOT NULL DEFAULT 0,
  events_pulled   integer     NOT NULL DEFAULT 0,
  conflicts_found integer     NOT NULL DEFAULT 0,
  error_message   text,
  metadata        jsonb,
  started_at      timestamptz NOT NULL DEFAULT now(),
  completed_at    timestamptz
);

-- Calendar indexes
CREATE INDEX idx_calendar_connections_user_id ON public.calendar_connections(user_id);
CREATE INDEX idx_calendar_connections_active ON public.calendar_connections(user_id, provider) WHERE is_active = true;
CREATE INDEX idx_calendar_connections_webhook ON public.calendar_connections(webhook_expires_at) WHERE webhook_channel_id IS NOT NULL;
CREATE INDEX idx_calendar_events_cache_user_time ON public.calendar_events_cache(user_id, start_time);
CREATE INDEX idx_calendar_events_cache_connection ON public.calendar_events_cache(connection_id);
CREATE INDEX idx_calendar_events_cache_couple ON public.calendar_events_cache(couple_plan_event_id) WHERE couple_plan_event_id IS NOT NULL;
CREATE INDEX idx_calendar_sync_log_user ON public.calendar_sync_log(user_id, started_at DESC);

-- Calendar RLS
ALTER TABLE public.calendar_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calendar_events_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calendar_sync_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own connections" ON public.calendar_connections
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own connections" ON public.calendar_connections
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own connections" ON public.calendar_connections
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own connections" ON public.calendar_connections
  FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own and partner cached events" ON public.calendar_events_cache
  FOR SELECT USING (
    auth.uid() = user_id
    OR user_id = public.get_partner_id(auth.uid())
  );

CREATE POLICY "Service role can manage event cache" ON public.calendar_events_cache
  FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "Users can view own sync logs" ON public.calendar_sync_log
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Service role can insert sync logs" ON public.calendar_sync_log
  FOR INSERT WITH CHECK (auth.role() = 'service_role' OR auth.uid() = user_id);

-- Calendar updated_at trigger
CREATE OR REPLACE FUNCTION public.update_calendar_connections_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_calendar_connections_updated_at
  BEFORE UPDATE ON public.calendar_connections
  FOR EACH ROW
  EXECUTE FUNCTION public.update_calendar_connections_updated_at();

-- =============================================================================
-- END OF MIGRATION 001
-- =============================================================================
