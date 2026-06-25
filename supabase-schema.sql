-- ============================================================
-- ASCENDRA — DATABASE SCHEMA
-- Supabase SQL Editor ga to'liq ko'chirib ishga tushiring
-- ============================================================

-- ─── 1. PROFILES ─────────────────────────────────────────────
-- auth.users jadvalini kengaytiradi
CREATE TABLE IF NOT EXISTS public.profiles (
  id                     UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name              TEXT,
  xp                     INTEGER     NOT NULL DEFAULT 0,
  level                  INTEGER     NOT NULL DEFAULT 1,
  streak                 INTEGER     NOT NULL DEFAULT 0,
  last_activity_date     DATE,
  tasks_completed        INTEGER     NOT NULL DEFAULT 0,
  habits_completed_total INTEGER     NOT NULL DEFAULT 0,
  created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 2. TASKS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.tasks (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title        TEXT        NOT NULL,
  description  TEXT,
  difficulty   TEXT        NOT NULL DEFAULT 'orta'
                           CHECK (difficulty IN ('oson','orta','qiyin','epik')),
  due_date     DATE,
  is_completed BOOLEAN     NOT NULL DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 3. HABITS ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.habits (
  id                   UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name                 TEXT        NOT NULL,
  description          TEXT,
  icon                 TEXT        DEFAULT '⭐',
  streak               INTEGER     NOT NULL DEFAULT 0,
  last_completed_date  DATE,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 4. HABIT COMPLETIONS ────────────────────────────────────
-- Kunlik odat bajarilishini saqlaydi
CREATE TABLE IF NOT EXISTS public.habit_completions (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  habit_id       UUID        NOT NULL REFERENCES public.habits(id) ON DELETE CASCADE,
  user_id        UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  completed_date DATE        NOT NULL DEFAULT CURRENT_DATE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  -- Bir kunda bir marta bajarilishi mumkin
  UNIQUE(habit_id, completed_date)
);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- Har foydalanuvchi FAQAT o'z ma'lumotlarini ko'radi
-- ============================================================

ALTER TABLE public.profiles          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habits            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_completions ENABLE ROW LEVEL SECURITY;

-- Profiles
DROP POLICY IF EXISTS "profiles_select" ON public.profiles;
DROP POLICY IF EXISTS "profiles_all"    ON public.profiles;

CREATE POLICY "profiles_select" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "profiles_all" ON public.profiles
  FOR ALL USING (auth.uid() = id);

-- Tasks
DROP POLICY IF EXISTS "tasks_all" ON public.tasks;

CREATE POLICY "tasks_all" ON public.tasks
  FOR ALL USING (auth.uid() = user_id);

-- Habits
DROP POLICY IF EXISTS "habits_all" ON public.habits;

CREATE POLICY "habits_all" ON public.habits
  FOR ALL USING (auth.uid() = user_id);

-- Habit completions
DROP POLICY IF EXISTS "habit_completions_all" ON public.habit_completions;

CREATE POLICY "habit_completions_all" ON public.habit_completions
  FOR ALL USING (auth.uid() = user_id);

-- ============================================================
-- TRIGGERS
-- ============================================================

-- Yangi foydalanuvchi ro'yxatdan o'tganda profil avtomatik yaratiladi
CREATE OR REPLACE FUNCTION public.on_auth_user_created()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.on_auth_user_created();

-- updated_at avtomatik yangilanadi
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS profiles_updated_at ON public.profiles;
DROP TRIGGER IF EXISTS tasks_updated_at    ON public.tasks;
DROP TRIGGER IF EXISTS habits_updated_at   ON public.habits;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER tasks_updated_at
  BEFORE UPDATE ON public.tasks
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER habits_updated_at
  BEFORE UPDATE ON public.habits
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ============================================================
-- INDEXES — tezlashtirish uchun
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_tasks_user_id      ON public.tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_completed    ON public.tasks(user_id, is_completed);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date     ON public.tasks(user_id, due_date);

CREATE INDEX IF NOT EXISTS idx_habits_user_id     ON public.habits(user_id);

CREATE INDEX IF NOT EXISTS idx_hc_habit_id        ON public.habit_completions(habit_id);
CREATE INDEX IF NOT EXISTS idx_hc_user_date       ON public.habit_completions(user_id, completed_date);
