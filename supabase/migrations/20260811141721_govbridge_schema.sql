/*
# GovBridge — Government Schemes Discovery Platform

## Purpose
A platform to help Indian citizens discover, understand, and apply for government schemes
(Central + all States, with special Tamil Nadu support). Includes scholarships, jobs,
internships, skill development, pensions, welfare, and more.

## New Tables
- `categories` — scheme categories (Scholarships, Farmers, Women Welfare, etc.)
- `schemes` — government schemes with full details, eligibility rules (JSONB), documents, links
- `jobs` — government job notifications
- `internships` — internship / skill development programs
- `scholarships` — scholarship listings (deadline-sensitive)
- `profiles` — per-user profile data driving personalized recommendations
- `bookmarks` — user-saved schemes
- `notifications` — alerts sent to users (new schemes, deadlines, jobs)
- `admin_users` — marks which auth users are admins (RLS-gated)

## Security
- RLS enabled on every table.
- Public read on schemes/categories/jobs/internships/scholarships (anon + authenticated).
- Owner-scoped CRUD on profiles, bookmarks, notifications.
- Admin-only writes on schemes/categories/jobs/internships/scholarships (via admin_users membership).
- Admin_users table is owner-scoped read (a user can see whether they themselves are an admin).
*/

-- CATEGORIES
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text UNIQUE NOT NULL,
  name text NOT NULL,
  name_ta text,
  name_hi text,
  icon text,
  description text,
  created_at timestamptz DEFAULT now()
);

-- SCHEMES
CREATE TABLE IF NOT EXISTS schemes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  title_ta text,
  title_hi text,
  category_id uuid REFERENCES categories(id) ON DELETE SET NULL,
  state text NOT NULL DEFAULT 'Central',
  ministry text,
  overview text NOT NULL,
  benefits text NOT NULL,
  eligibility text NOT NULL,
  eligibility_rules jsonb NOT NULL DEFAULT '{}'::jsonb,
  documents text NOT NULL,
  process text NOT NULL,
  last_date date,
  official_url text,
  pdf_url text,
  simple_explanation text NOT NULL,
  simple_explanation_ta text,
  languages text[] DEFAULT ARRAY['English'],
  tags text[] DEFAULT ARRAY[]::text[],
  featured boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- JOBS
CREATE TABLE IF NOT EXISTS jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  organization text NOT NULL,
  state text NOT NULL DEFAULT 'Central',
  description text,
  eligibility text,
  last_date date,
  official_url text,
  created_at timestamptz DEFAULT now()
);

-- INTERNSHIPS
CREATE TABLE IF NOT EXISTS internships (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  organization text NOT NULL,
  description text,
  eligibility text,
  duration text,
  last_date date,
  official_url text,
  created_at timestamptz DEFAULT now()
);

-- SCHOLARSHIPS
CREATE TABLE IF NOT EXISTS scholarships (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  provider text NOT NULL,
  amount text,
  eligibility text,
  last_date date,
  official_url text,
  created_at timestamptz DEFAULT now()
);

-- PROFILES
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY DEFAULT auth.uid(),
  full_name text,
  age int,
  gender text,
  state text,
  district text,
  education text,
  occupation text,
  family_income int,
  community text,
  disability boolean DEFAULT false,
  farmer boolean DEFAULT false,
  student boolean DEFAULT false,
  widow boolean DEFAULT false,
  senior_citizen boolean DEFAULT false,
  preferred_language text DEFAULT 'English',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- BOOKMARKS
CREATE TABLE IF NOT EXISTS bookmarks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
  scheme_id uuid NOT NULL REFERENCES schemes(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE (user_id, scheme_id)
);

-- NOTIFICATIONS
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
  title text NOT NULL,
  body text,
  type text DEFAULT 'info',
  read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- ADMIN USERS
CREATE TABLE IF NOT EXISTS admin_users (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now()
);

-- INDEXES
CREATE INDEX IF NOT EXISTS idx_schemes_category ON schemes(category_id);
CREATE INDEX IF NOT EXISTS idx_schemes_state ON schemes(state);
CREATE INDEX IF NOT EXISTS idx_schemes_featured ON schemes(featured);
CREATE INDEX IF NOT EXISTS idx_bookmarks_user ON bookmarks(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);

-- RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE schemes ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE internships ENABLE ROW LEVEL SECURITY;
ALTER TABLE scholarships ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- CATEGORIES: public read, admin write
DROP POLICY IF EXISTS "public_read_categories" ON categories;
CREATE POLICY "public_read_categories" ON categories FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "admin_insert_categories" ON categories;
CREATE POLICY "admin_insert_categories" ON categories FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "admin_update_categories" ON categories;
CREATE POLICY "admin_update_categories" ON categories FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "admin_delete_categories" ON categories;
CREATE POLICY "admin_delete_categories" ON categories FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));

-- SCHEMES: public read, admin write
DROP POLICY IF EXISTS "public_read_schemes" ON schemes;
CREATE POLICY "public_read_schemes" ON schemes FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "admin_insert_schemes" ON schemes;
CREATE POLICY "admin_insert_schemes" ON schemes FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "admin_update_schemes" ON schemes;
CREATE POLICY "admin_update_schemes" ON schemes FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "admin_delete_schemes" ON schemes;
CREATE POLICY "admin_delete_schemes" ON schemes FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));

-- JOBS
DROP POLICY IF EXISTS "public_read_jobs" ON jobs;
CREATE POLICY "public_read_jobs" ON jobs FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "admin_insert_jobs" ON jobs;
CREATE POLICY "admin_insert_jobs" ON jobs FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "admin_update_jobs" ON jobs;
CREATE POLICY "admin_update_jobs" ON jobs FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "admin_delete_jobs" ON jobs;
CREATE POLICY "admin_delete_jobs" ON jobs FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));

-- INTERNSHIPS
DROP POLICY IF EXISTS "public_read_internships" ON internships;
CREATE POLICY "public_read_internships" ON internships FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "admin_insert_internships" ON internships;
CREATE POLICY "admin_insert_internships" ON internships FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "admin_update_internships" ON internships;
CREATE POLICY "admin_update_internships" ON internships FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "admin_delete_internships" ON internships;
CREATE POLICY "admin_delete_internships" ON internships FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));

-- SCHOLARSHIPS
DROP POLICY IF EXISTS "public_read_scholarships" ON scholarships;
CREATE POLICY "public_read_scholarships" ON scholarships FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "admin_insert_scholarships" ON scholarships;
CREATE POLICY "admin_insert_scholarships" ON scholarships FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "admin_update_scholarships" ON scholarships;
CREATE POLICY "admin_update_scholarships" ON scholarships FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));
DROP POLICY IF EXISTS "admin_delete_scholarships" ON scholarships;
CREATE POLICY "admin_delete_scholarships" ON scholarships FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));

-- PROFILES: owner-scoped CRUD
DROP POLICY IF EXISTS "select_own_profile" ON profiles;
CREATE POLICY "select_own_profile" ON profiles FOR SELECT TO authenticated USING (auth.uid() = id);
DROP POLICY IF EXISTS "insert_own_profile" ON profiles;
CREATE POLICY "insert_own_profile" ON profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);
DROP POLICY IF EXISTS "update_own_profile" ON profiles;
CREATE POLICY "update_own_profile" ON profiles FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
DROP POLICY IF EXISTS "delete_own_profile" ON profiles;
CREATE POLICY "delete_own_profile" ON profiles FOR DELETE TO authenticated USING (auth.uid() = id);

-- BOOKMARKS: owner-scoped
DROP POLICY IF EXISTS "select_own_bookmarks" ON bookmarks;
CREATE POLICY "select_own_bookmarks" ON bookmarks FOR SELECT TO authenticated USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "insert_own_bookmarks" ON bookmarks;
CREATE POLICY "insert_own_bookmarks" ON bookmarks FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "delete_own_bookmarks" ON bookmarks;
CREATE POLICY "delete_own_bookmarks" ON bookmarks FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- NOTIFICATIONS: owner-scoped read/update/delete
DROP POLICY IF EXISTS "select_own_notifications" ON notifications;
CREATE POLICY "select_own_notifications" ON notifications FOR SELECT TO authenticated USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "update_own_notifications" ON notifications;
CREATE POLICY "update_own_notifications" ON notifications FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "delete_own_notifications" ON notifications;
CREATE POLICY "delete_own_notifications" ON notifications FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- ADMIN_USERS: a user can read only their own admin row
DROP POLICY IF EXISTS "select_own_admin" ON admin_users;
CREATE POLICY "select_own_admin" ON admin_users FOR SELECT TO authenticated USING (user_id = auth.uid());
