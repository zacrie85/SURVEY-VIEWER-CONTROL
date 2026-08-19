-- ============================================
-- COMSUR SURVEY TOOLS — Supabase Database Setup
-- Run this SQL in: Supabase Dashboard → SQL Editor → New Query
-- ============================================

-- 1. Buat tabel "projects"
CREATE TABLE IF NOT EXISTS projects (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT DEFAULT '',
  created_by TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now(),
  last_modified TIMESTAMPTZ DEFAULT now()
);

-- 2. Buat tabel "project_data"
CREATE TABLE IF NOT EXISTS project_data (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id TEXT UNIQUE NOT NULL,
  data JSONB DEFAULT '{}',
  version INTEGER DEFAULT 1,
  updated_by TEXT DEFAULT '',
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Enable Realtime untuk project_data (supaya sync otomatis)
ALTER PUBLICATION supabase_realtime ADD TABLE project_data;

-- 4. Enable Row Level Security
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_data ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies — izinkan akses penuh via anon key
-- (Keamanan dihandle oleh password gate di aplikasi)
CREATE POLICY "allow_all_projects" ON projects
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "allow_all_project_data" ON project_data
  FOR ALL USING (true) WITH CHECK (true);

-- 6. Index untuk performa
CREATE INDEX IF NOT EXISTS idx_project_data_project_id ON project_data(project_id);
CREATE INDEX IF NOT EXISTS idx_projects_created_at ON projects(created_at DESC);

-- Selesai! ✅
-- Sekarang kembali ke chat dan beritahu bahwa SQL sudah dijalankan.
