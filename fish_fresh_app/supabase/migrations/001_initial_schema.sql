-- ============================================================
-- FishCheck ZM — Supabase Database Schema
-- Run this in your Supabase SQL editor (Dashboard → SQL Editor)
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis"; -- for vendor location search

-- ────────────────────────────────────────────────────────────
-- PROFILES — extends Supabase auth.users
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.profiles (
  id            UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name     TEXT,
  phone         TEXT,
  city          TEXT,
  province      TEXT,
  is_vendor     BOOLEAN DEFAULT FALSE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ────────────────────────────────────────────────────────────
-- SCANS — cloud sync of freshness scan results
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.scans (
  id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  fish_type       TEXT NOT NULL,
  freshness       TEXT NOT NULL CHECK (freshness IN ('Fresh','Acceptable','Poor','Spoiled','Unknown')),
  score           INTEGER CHECK (score >= 0 AND score <= 100),
  confidence      INTEGER DEFAULT 0,
  eyes            TEXT,
  skin            TEXT,
  gills           TEXT,
  flesh           TEXT,
  odour_guess     TEXT,
  safe_to_eat     BOOLEAN DEFAULT TRUE,
  advice          TEXT,
  sell_by         TEXT,
  storage_tip     TEXT,
  price_impact    TEXT,
  image_url       TEXT,         -- Supabase Storage URL (compressed thumbnail)
  is_pending      BOOLEAN DEFAULT FALSE,
  analysed_at     TIMESTAMPTZ DEFAULT NOW(),
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Index for fast user history queries
CREATE INDEX IF NOT EXISTS scans_user_id_idx ON public.scans(user_id);
CREATE INDEX IF NOT EXISTS scans_analysed_at_idx ON public.scans(analysed_at DESC);

-- ────────────────────────────────────────────────────────────
-- VENDORS — fish vendor directory
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.vendors (
  id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id         UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  name            TEXT NOT NULL,
  phone           TEXT,
  whatsapp        TEXT,
  market_name     TEXT NOT NULL,
  city            TEXT NOT NULL,
  province        TEXT NOT NULL,
  latitude        DOUBLE PRECISION,
  longitude       DOUBLE PRECISION,
  location        GEOGRAPHY(POINT, 4326),  -- PostGIS point for radius search
  fish_species    TEXT[] DEFAULT '{}',
  description     TEXT,
  is_verified     BOOLEAN DEFAULT FALSE,
  is_active       BOOLEAN DEFAULT TRUE,
  average_rating  DOUBLE PRECISION DEFAULT 0,
  total_scans     INTEGER DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Spatial index for location-based queries
CREATE INDEX IF NOT EXISTS vendors_location_idx ON public.vendors USING GIST(location);
CREATE INDEX IF NOT EXISTS vendors_city_idx ON public.vendors(city);
CREATE INDEX IF NOT EXISTS vendors_active_idx ON public.vendors(is_active);

-- Auto-update PostGIS point when lat/lng changes
CREATE OR REPLACE FUNCTION public.update_vendor_location()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
    NEW.location = ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326);
  END IF;
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER update_vendor_location_trigger
  BEFORE INSERT OR UPDATE ON public.vendors
  FOR EACH ROW EXECUTE FUNCTION public.update_vendor_location();

-- ────────────────────────────────────────────────────────────
-- ML CORRECTIONS — species correction feedback
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.ml_corrections (
  id                   UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id              UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  scan_id              UUID REFERENCES public.scans(id) ON DELETE CASCADE,
  predicted_species    TEXT NOT NULL,
  corrected_species    TEXT NOT NULL,
  original_confidence  INTEGER DEFAULT 0,
  recorded_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ml_corrections_species_idx ON public.ml_corrections(corrected_species);

-- ────────────────────────────────────────────────────────────
-- ROW LEVEL SECURITY — users only see their own data
-- ────────────────────────────────────────────────────────────

-- Profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Scans
ALTER TABLE public.scans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own scans"
  ON public.scans FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own scans"
  ON public.scans FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own scans"
  ON public.scans FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own scans"
  ON public.scans FOR DELETE USING (auth.uid() = user_id);

-- Vendors — anyone can read, only owners can modify
ALTER TABLE public.vendors ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active vendors"
  ON public.vendors FOR SELECT USING (is_active = TRUE);
CREATE POLICY "Vendors can update own listing"
  ON public.vendors FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can create vendor listing"
  ON public.vendors FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ML Corrections
ALTER TABLE public.ml_corrections ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can insert own corrections"
  ON public.ml_corrections FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can view own corrections"
  ON public.ml_corrections FOR SELECT USING (auth.uid() = user_id);

-- ────────────────────────────────────────────────────────────
-- STORAGE BUCKETS
-- ────────────────────────────────────────────────────────────
-- Run this in Storage tab OR via SQL:
INSERT INTO storage.buckets (id, name, public)
VALUES ('scan-images', 'scan-images', FALSE)
ON CONFLICT DO NOTHING;

CREATE POLICY "Users can upload their scan images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'scan-images' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can view their scan images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'scan-images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- ────────────────────────────────────────────────────────────
-- SEED SAMPLE VENDORS (Lusaka markets)
-- ────────────────────────────────────────────────────────────
INSERT INTO public.vendors
  (id, name, phone, whatsapp, market_name, city, province, latitude, longitude,
   fish_species, description, is_verified, average_rating, total_scans)
VALUES
  (uuid_generate_v4(), 'Chanda Mwale', '+260977123456', '+260977123456',
   'Soweto Market', 'Lusaka', 'Lusaka Province', -15.4167, 28.2833,
   ARRAY['Kapenta','Bream','Tiger fish'],
   'Fresh fish daily from Lake Kariba. Been selling for 12 years.',
   TRUE, 4.7, 42),
  (uuid_generate_v4(), 'Mutale Banda', '+260966234567', '+260966234567',
   'City Market', 'Lusaka', 'Lusaka Province', -15.4200, 28.2780,
   ARRAY['Bream','Mpumbu','Vundu'],
   'Specialising in Lake Bangweulu fish. Wholesale and retail.',
   TRUE, 4.5, 28),
  (uuid_generate_v4(), 'Bupe Phiri', '+260955345678', '+260955345678',
   'Luburma Market', 'Lusaka', 'Lusaka Province', -15.4100, 28.3100,
   ARRAY['Kapenta','Chessa'],
   'Dried and fresh kapenta specialist. Lake Tanganyika source.',
   FALSE, 4.2, 15),
  (uuid_generate_v4(), 'Namukolo Simu', '+260977456789', '+260977456789',
   'Kamwala Market', 'Lusaka', 'Lusaka Province', -15.4250, 28.2900,
   ARRAY['Bream','Tiger fish','Mpumbu'],
   'Fresh catch every Tuesday and Friday. Best bream in Lusaka.',
   TRUE, 4.8, 61),
  (uuid_generate_v4(), 'Kelvin Mulenga', '+260966567890', '+260966567890',
   'Masala Market', 'Ndola', 'Copperbelt Province', -12.9667, 28.6333,
   ARRAY['Kapenta','Bream','Chessa'],
   'Copperbelt distributor. Bulk orders welcome.',
   FALSE, 4.1, 19)
ON CONFLICT DO NOTHING;
