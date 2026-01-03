-- ReClaim Supabase Database Schema
-- Run this in your Supabase SQL Editor to set up the database

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================= PROFILES TABLE =================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  department TEXT,
  campus_id UUID REFERENCES campuses(id),
  role TEXT DEFAULT 'student' CHECK (role IN ('student', 'lab', 'admin')),
  skills TEXT[] DEFAULT '{}',
  interests TEXT[] DEFAULT '{}',
  availability TEXT DEFAULT 'part-time',
  co2_saved DECIMAL(10, 2) DEFAULT 0,
  materials_reused INTEGER DEFAULT 0,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view all profiles" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update their own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert their own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- ================= CAMPUSES TABLE =================
CREATE TABLE IF NOT EXISTS campuses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  location TEXT NOT NULL,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on campuses
ALTER TABLE campuses ENABLE ROW LEVEL SECURITY;

-- Campuses policies (public read)
CREATE POLICY "Anyone can view campuses" ON campuses FOR SELECT USING (true);

-- Insert sample campuses
INSERT INTO campuses (name, location) VALUES
  ('VESIT - Vivekanand Education Society Institute of Technology', 'Chembur, Mumbai, Maharashtra'),
  ('IIT Bombay', 'Powai, Mumbai, Maharashtra'),
  ('VJTI - Veermata Jijabai Technological Institute', 'Matunga, Mumbai, Maharashtra'),
  ('SPIT - Sardar Patel Institute of Technology', 'Andheri, Mumbai, Maharashtra'),
  ('DJ Sanghvi College of Engineering', 'Vile Parle, Mumbai, Maharashtra'),
  ('KJ Somaiya College of Engineering', 'Vidyavihar, Mumbai, Maharashtra');

-- ================= DEPARTMENTS TABLE =================
CREATE TABLE IF NOT EXISTS departments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  campus_id UUID REFERENCES campuses(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on departments
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;

-- Departments policies (public read)
CREATE POLICY "Anyone can view departments" ON departments FOR SELECT USING (true);

-- ================= MATERIALS TABLE =================
CREATE TABLE IF NOT EXISTS materials (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('Electronic', 'Metal', 'Plastic', 'Glass', 'Wood', 'Chemical', 'Other')),
  quantity TEXT NOT NULL,
  condition TEXT NOT NULL CHECK (condition IN ('Excellent', 'Good', 'Fair', 'Poor')),
  location TEXT NOT NULL,
  confidence DECIMAL(3, 2) DEFAULT 0,
  image_url TEXT,
  notes TEXT,
  status TEXT DEFAULT 'detected' CHECK (status IN ('detected', 'listed', 'matched', 'in_use', 'completed')),
  carbon_saved DECIMAL(10, 2) DEFAULT 0,
  campus_id UUID REFERENCES campuses(id),
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on materials
ALTER TABLE materials ENABLE ROW LEVEL SECURITY;

-- Materials policies
CREATE POLICY "Anyone can view materials" ON materials FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert materials" ON materials FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Material creators can update" ON materials FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Material creators can delete" ON materials FOR DELETE USING (auth.uid() = created_by);

-- Enable realtime for materials
ALTER PUBLICATION supabase_realtime ADD TABLE materials;

-- ================= OPPORTUNITIES TABLE =================
CREATE TABLE IF NOT EXISTS opportunities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  material_id UUID REFERENCES materials(id) ON DELETE CASCADE,
  material_name TEXT NOT NULL,
  material_type TEXT NOT NULL,
  suggested_projects TEXT[] DEFAULT '{}',
  carbon_impact DECIMAL(10, 2) DEFAULT 0,
  matched_student_id UUID REFERENCES profiles(id),
  match_percentage INTEGER DEFAULT 0,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'rejected', 'completed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on opportunities
ALTER TABLE opportunities ENABLE ROW LEVEL SECURITY;

-- Opportunities policies
CREATE POLICY "Anyone can view opportunities" ON opportunities FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert opportunities" ON opportunities FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can update opportunities" ON opportunities FOR UPDATE USING (auth.uid() IS NOT NULL);

-- Enable realtime for opportunities
ALTER PUBLICATION supabase_realtime ADD TABLE opportunities;

-- ================= REQUESTS TABLE =================
CREATE TABLE IF NOT EXISTS requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  material_type TEXT NOT NULL,
  quantity TEXT NOT NULL,
  project TEXT NOT NULL,
  description TEXT,
  deadline TIMESTAMP WITH TIME ZONE,
  urgency TEXT DEFAULT 'medium' CHECK (urgency IN ('low', 'medium', 'high', 'urgent')),
  requester_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  matched_material_id UUID REFERENCES materials(id),
  matched_percentage INTEGER DEFAULT 0,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'fulfilled', 'cancelled')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on requests
ALTER TABLE requests ENABLE ROW LEVEL SECURITY;

-- Requests policies
CREATE POLICY "Anyone can view requests" ON requests FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert requests" ON requests FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Request creators can update" ON requests FOR UPDATE USING (auth.uid() = requester_id);
CREATE POLICY "Request creators can delete" ON requests FOR DELETE USING (auth.uid() = requester_id);

-- Enable realtime for requests
ALTER PUBLICATION supabase_realtime ADD TABLE requests;

-- ================= NOTIFICATIONS TABLE =================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('opportunity', 'match', 'approval', 'reminder', 'impact', 'system')),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on notifications
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Notifications policies
CREATE POLICY "Users can view their own notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Authenticated users can insert notifications" ON notifications FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Users can update their own notifications" ON notifications FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own notifications" ON notifications FOR DELETE USING (auth.uid() = user_id);

-- Enable realtime for notifications
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;

-- ================= BARTER_EXCHANGES TABLE =================
CREATE TABLE IF NOT EXISTS barter_exchanges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  offerer_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  skill_offered TEXT NOT NULL,
  skill_wanted TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'matched', 'in_progress', 'completed', 'cancelled')),
  matched_user_id UUID REFERENCES profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on barter_exchanges
ALTER TABLE barter_exchanges ENABLE ROW LEVEL SECURITY;

-- Barter policies
CREATE POLICY "Anyone can view barter exchanges" ON barter_exchanges FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create exchanges" ON barter_exchanges FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Exchange owners can update" ON barter_exchanges FOR UPDATE USING (auth.uid() = offerer_id);

-- Enable realtime for barter_exchanges
ALTER PUBLICATION supabase_realtime ADD TABLE barter_exchanges;

-- ================= FUNCTIONS & TRIGGERS =================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_materials_updated_at BEFORE UPDATE ON materials FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_opportunities_updated_at BEFORE UPDATE ON opportunities FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_requests_updated_at BEFORE UPDATE ON requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_barter_updated_at BEFORE UPDATE ON barter_exchanges FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to update user's CO2 saved when a material is completed
CREATE OR REPLACE FUNCTION update_user_co2_saved()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    UPDATE profiles
    SET co2_saved = co2_saved + NEW.carbon_saved,
        materials_reused = materials_reused + 1
    WHERE id = NEW.created_by;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_co2_on_material_complete 
AFTER UPDATE ON materials 
FOR EACH ROW 
EXECUTE FUNCTION update_user_co2_saved();

-- ================= STORAGE BUCKET =================
-- Run these commands in Supabase Dashboard > Storage

-- Create a bucket for material images
-- INSERT INTO storage.buckets (id, name, public) VALUES ('materials', 'materials', true);

-- Storage policies (run in SQL editor with proper permissions)
-- CREATE POLICY "Anyone can view material images" ON storage.objects FOR SELECT USING (bucket_id = 'materials');
-- CREATE POLICY "Authenticated users can upload images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'materials' AND auth.uid() IS NOT NULL);

-- ================= SAMPLE DATA (Optional) =================

-- Sample materials (uncomment to use)
/*
INSERT INTO materials (name, type, quantity, condition, location, confidence, status, carbon_saved) VALUES
  ('Arduino Boards', 'Electronic', '5 units', 'Good', 'Lab A - Chemistry', 0.94, 'listed', 0.8),
  ('Copper Wire Spools', 'Metal', '3 kg', 'Good', 'Lab B - Electronics', 0.89, 'listed', 1.2),
  ('Acrylic Sheets', 'Plastic', '10 sheets', 'Good', 'Workshop', 0.85, 'matched', 2.5),
  ('Glass Beakers', 'Glass', '8 units', 'Fair', 'Lab A - Chemistry', 0.72, 'in_use', 0.5);
*/
