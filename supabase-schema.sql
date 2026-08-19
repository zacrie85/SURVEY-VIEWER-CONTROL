-- ============================================================
-- COMSUR Survey v9 - Supabase SQL Schema
-- Jalankan SQL ini di SQL Editor projek Supabase kamu
-- ============================================================

-- 1. Tabel app_settings (password, konfigurasi)
CREATE TABLE IF NOT EXISTS app_settings (
  id TEXT PRIMARY KEY DEFAULT 'security',
  password_hash TEXT,
  viewer_password_hash TEXT,
  admin_uid TEXT DEFAULT 'admin-local',
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Insert default row
INSERT INTO app_settings (id) VALUES ('security')
ON CONFLICT (id) DO NOTHING;

-- 2. Tabel projects (daftar proyek)
CREATE TABLE IF NOT EXISTS projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT DEFAULT '',
  created_by TEXT DEFAULT 'admin',
  created_at TIMESTAMPTZ DEFAULT now(),
  last_modified TIMESTAMPTZ DEFAULT now()
);

-- 3. Tabel project_data (data per proyek - JSON blob)
-- Menyimpan seluruh state: markers, folders, polygonFolders, drawnLines, dll
CREATE TABLE IF NOT EXISTS project_data (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  data JSONB NOT NULL DEFAULT '{}',
  version INTEGER DEFAULT 1,
  updated_by TEXT DEFAULT 'admin',
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(project_id)
);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- Supabase anon key bisa akses semua (karena app pakai password gate sendiri)
-- ============================================================

ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_data ENABLE ROW LEVEL SECURITY;

-- Policy: anon bisa baca/tulis semua (keamanan dihandle oleh password gate)
CREATE POLICY "anon_all_app_settings" ON app_settings FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_projects" ON projects FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_project_data" ON project_data FOR ALL USING (true) WITH CHECK (true);

-- ============================================================
-- INDEXES untuk performa
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_project_data_project_id ON project_data(project_id);
CREATE INDEX IF NOT EXISTS idx_projects_created_at ON projects(created_at DESC);

-- ============================================================
-- REALTIME (untuk sinkronisasi multi-user)
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE project_data;
ALTER PUBLICATION supabase_realtime ADD TABLE projects;
