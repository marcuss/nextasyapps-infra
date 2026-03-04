-- ============================================================
-- SCHEMA INICIAL COUPLESAPP
-- Migración: 001_initial_schema.sql
-- Aplicar en orden. Las RLS policies están incluidas.
-- ============================================================

-- PROFILES
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  name text NOT NULL,
  email text NOT NULL UNIQUE,
  partner_id uuid,
  is_premium boolean DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc', now()),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id),
  CONSTRAINT profiles_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.profiles(id)
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can read own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can read partner profile" ON public.profiles
  FOR SELECT USING (
    id IN (SELECT partner_id FROM public.profiles WHERE id = auth.uid())
  );

-- ============================================================
-- INVITATIONS
-- ============================================================
CREATE TABLE public.invitations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  from_user_id uuid NOT NULL,
  to_email text NOT NULL,
  status text DEFAULT 'pending' CHECK (status = ANY (ARRAY['pending','accepted','rejected'])),
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc', now()),
  CONSTRAINT invitations_pkey PRIMARY KEY (id),
  CONSTRAINT invitations_from_user_id_fkey FOREIGN KEY (from_user_id) REFERENCES public.profiles(id)
);

ALTER TABLE public.invitations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can create invitations" ON public.invitations
  FOR INSERT WITH CHECK (auth.uid() = from_user_id);

CREATE POLICY "Users can read own invitations" ON public.invitations
  FOR SELECT USING (auth.uid() = from_user_id);

CREATE POLICY "Anyone can read invitations sent to their email" ON public.invitations
  FOR SELECT USING (
    to_email = (SELECT email FROM public.profiles WHERE id = auth.uid())
  );

CREATE POLICY "Users can update invitation status" ON public.invitations
  FOR UPDATE USING (
    to_email = (SELECT email FROM public.profiles WHERE id = auth.uid())
  );

-- ============================================================
-- GOALS
-- ============================================================
CREATE TABLE public.goals (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  category text DEFAULT 'personal' CHECK (category = ANY (ARRAY['travel','financial','personal','home','other'])),
  target_date date,
  completed boolean DEFAULT false,
  created_by uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc', now()),
  CONSTRAINT goals_pkey PRIMARY KEY (id),
  CONSTRAINT goals_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id)
);

ALTER TABLE public.goals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Couple can read goals" ON public.goals
  FOR SELECT USING (
    created_by = auth.uid() OR
    created_by = (SELECT partner_id FROM public.profiles WHERE id = auth.uid())
  );

CREATE POLICY "Users can create goals" ON public.goals
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update own goals" ON public.goals
  FOR UPDATE USING (auth.uid() = created_by);

CREATE POLICY "Users can delete own goals" ON public.goals
  FOR DELETE USING (auth.uid() = created_by);

-- ============================================================
-- TASKS
-- ============================================================
CREATE TABLE public.tasks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  category text DEFAULT 'shared' CHECK (category = ANY (ARRAY['home','work','personal','shared'])),
  assigned_to uuid,
  due_date date,
  completed boolean DEFAULT false,
  created_by uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc', now()),
  CONSTRAINT tasks_pkey PRIMARY KEY (id),
  CONSTRAINT tasks_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.profiles(id),
  CONSTRAINT tasks_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id)
);

ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Couple can read tasks" ON public.tasks
  FOR SELECT USING (
    created_by = auth.uid() OR
    assigned_to = auth.uid() OR
    created_by = (SELECT partner_id FROM public.profiles WHERE id = auth.uid())
  );

CREATE POLICY "Users can create tasks" ON public.tasks
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update own tasks" ON public.tasks
  FOR UPDATE USING (auth.uid() = created_by OR assigned_to = auth.uid());

CREATE POLICY "Users can delete own tasks" ON public.tasks
  FOR DELETE USING (auth.uid() = created_by);

-- ============================================================
-- EVENTS
-- ============================================================
CREATE TABLE public.events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  date date NOT NULL,
  time text,
  type text DEFAULT 'personal' CHECK (type = ANY (ARRAY['personal','shared'])),
  user_id uuid NOT NULL,
  color text DEFAULT '#f43f5e',
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc', now()),
  CONSTRAINT events_pkey PRIMARY KEY (id),
  CONSTRAINT events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);

ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Couple can read events" ON public.events
  FOR SELECT USING (
    user_id = auth.uid() OR
    user_id = (SELECT partner_id FROM public.profiles WHERE id = auth.uid())
  );

CREATE POLICY "Users can create events" ON public.events
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own events" ON public.events
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own events" ON public.events
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================================
-- BUDGETS
-- ============================================================
CREATE TABLE public.budgets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  category text NOT NULL,
  amount numeric NOT NULL,
  spent numeric DEFAULT 0,
  year integer DEFAULT EXTRACT(year FROM CURRENT_DATE),
  created_by uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc', now()),
  CONSTRAINT budgets_pkey PRIMARY KEY (id),
  CONSTRAINT budgets_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id)
);

ALTER TABLE public.budgets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Couple can read budgets" ON public.budgets
  FOR SELECT USING (
    created_by = auth.uid() OR
    created_by = (SELECT partner_id FROM public.profiles WHERE id = auth.uid())
  );

CREATE POLICY "Users can create budgets" ON public.budgets
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update own budgets" ON public.budgets
  FOR UPDATE USING (auth.uid() = created_by);

CREATE POLICY "Users can delete own budgets" ON public.budgets
  FOR DELETE USING (auth.uid() = created_by);

-- ============================================================
-- EXPENSES
-- ============================================================
CREATE TABLE public.expenses (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  budget_id uuid NOT NULL,
  description text NOT NULL,
  amount numeric NOT NULL,
  date date DEFAULT CURRENT_DATE,
  created_by uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc', now()),
  CONSTRAINT expenses_pkey PRIMARY KEY (id),
  CONSTRAINT expenses_budget_id_fkey FOREIGN KEY (budget_id) REFERENCES public.budgets(id),
  CONSTRAINT expenses_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id)
);

ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Couple can read expenses" ON public.expenses
  FOR SELECT USING (
    created_by = auth.uid() OR
    created_by = (SELECT partner_id FROM public.profiles WHERE id = auth.uid())
  );

CREATE POLICY "Users can create expenses" ON public.expenses
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update own expenses" ON public.expenses
  FOR UPDATE USING (auth.uid() = created_by);

CREATE POLICY "Users can delete own expenses" ON public.expenses
  FOR DELETE USING (auth.uid() = created_by);

-- ============================================================
-- TRAVELS
-- ============================================================
CREATE TABLE public.travels (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  destination text NOT NULL,
  description text,
  start_date date,
  end_date date,
  estimated_budget numeric,
  status text DEFAULT 'planning' CHECK (status = ANY (ARRAY['planning','booked','completed'])),
  created_by uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc', now()),
  CONSTRAINT travels_pkey PRIMARY KEY (id),
  CONSTRAINT travels_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id)
);

ALTER TABLE public.travels ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Couple can read travels" ON public.travels
  FOR SELECT USING (
    created_by = auth.uid() OR
    created_by = (SELECT partner_id FROM public.profiles WHERE id = auth.uid())
  );

CREATE POLICY "Users can create travels" ON public.travels
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update own travels" ON public.travels
  FOR UPDATE USING (auth.uid() = created_by);

CREATE POLICY "Users can delete own travels" ON public.travels
  FOR DELETE USING (auth.uid() = created_by);
