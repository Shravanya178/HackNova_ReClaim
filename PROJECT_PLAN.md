# 📱 ReClaim - Complete Development Plan

## 🏗️ System Architecture Overview

### Tech Stack Implementation
- **Frontend**: Flutter (Android only)
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Real-time)
- **Additional Services**: Firebase (FCM for notifications, Analytics)
- **Maps**: OpenStreetMap with Leaflet (flutter_map)
- **AI/ML**: Circular Net TensorFlow (waste detection)
- **APIs**: REST endpoints for external integrations

## 📊 Database Schema Design

### Core Tables (Supabase PostgreSQL)

```sql
-- Users & Authentication
users (
  id UUID PRIMARY KEY,
  email VARCHAR UNIQUE,
  role ENUM('student', 'lab', 'admin'),
  campus_id UUID,
  department_id UUID,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)

-- Student Profiles
student_profiles (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  skills TEXT[],
  domains TEXT[],
  availability_hours INTEGER,
  project_interests TEXT,
  past_projects JSONB,
  match_preferences JSONB
)

-- Campus & Departments
campuses (
  id UUID PRIMARY KEY,
  name VARCHAR,
  location POINT,
  zones JSONB
)

departments (
  id UUID PRIMARY KEY,
  name VARCHAR,
  campus_id UUID REFERENCES campuses(id)
)

-- Materials & Detection
material_lots (
  id UUID PRIMARY KEY,
  lab_user_id UUID REFERENCES users(id),
  images TEXT[],
  detected_materials JSONB,
  location VARCHAR,
  campus_zone VARCHAR,
  status ENUM('detected', 'listed', 'matched', 'picked_up', 'in_use', 'completed'),
  confidence_scores JSONB,
  notes TEXT,
  created_at TIMESTAMP
)

detected_materials (
  id UUID PRIMARY KEY,
  lot_id UUID REFERENCES material_lots(id),
  material_type VARCHAR,
  quantity INTEGER,
  condition ENUM('good', 'used', 'scrap'),
  bounding_box JSONB,
  confidence_score FLOAT,
  carbon_factor FLOAT
)

-- Opportunities & Matching
opportunities (
  id UUID PRIMARY KEY,
  material_lot_id UUID REFERENCES material_lots(id),
  suggested_projects JSONB,
  matched_student_id UUID REFERENCES users(id),
  match_percentage INTEGER,
  carbon_impact FLOAT,
  logistics_notes TEXT,
  status ENUM('generated', 'confirmed', 'rejected', 'modified'),
  created_at TIMESTAMP
)

-- Student Requests
material_requests (
  id UUID PRIMARY KEY,
  student_id UUID REFERENCES users(id),
  material_type VARCHAR,
  quantity_needed INTEGER,
  deadline DATE,
  intended_project TEXT,
  status ENUM('open', 'partially_matched', 'fulfilled', 'expired'),
  progress_data JSONB
)

-- Barter System
skill_requirements (
  id UUID PRIMARY KEY,
  lab_user_id UUID REFERENCES users(id),
  required_skills TEXT[],
  project_description TEXT,
  material_access JSONB,
  deadline DATE,
  status ENUM('open', 'matched', 'completed')
)

barter_applications (
  id UUID PRIMARY KEY,
  requirement_id UUID REFERENCES skill_requirements(id),
  student_id UUID REFERENCES users(id),
  application_data JSONB,
  status ENUM('pending', 'approved', 'rejected'),
  applied_at TIMESTAMP
)

-- Lifecycle Tracking
lifecycle_events (
  id UUID PRIMARY KEY,
  material_lot_id UUID REFERENCES material_lots(id),
  event_type VARCHAR,
  timestamp TIMESTAMP,
  notes TEXT,
  photo_url VARCHAR,
  user_id UUID REFERENCES users(id)
)

-- Notifications
notifications (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  type VARCHAR,
  title VARCHAR,
  message TEXT,
  data JSONB,
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMP
)

-- Impact Tracking
impact_metrics (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  campus_id UUID REFERENCES campuses(id),
  period_start DATE,
  period_end DATE,
  co2_saved FLOAT,
  materials_diverted FLOAT,
  projects_enabled INTEGER,
  updated_at TIMESTAMP
)
```

## 🎨 Complete Screen Flow & Additional Screens

### 📱 Screen Architecture

#### **Authentication Flow**
1. **Splash Screen** - Loading + branding
2. **Onboarding Flow** (3-4 screens)
   - Welcome to ReClaim
   - How it works (material detection → matching → projects)
   - Environmental impact showcase
   - Get started
3. **Auth Screen** - Login/Signup with role selection
4. **Campus Selection** - Search + select institution
5. **Department Selection** - Based on role
6. **Permission Requests** - Camera, location, notifications

#### **Lab/Faculty Flow**
7. **Lab Dashboard** - Quick stats + recent activity
8. **Material Capture Screen** ⭐
   - Camera viewfinder with AI overlay
   - Real-time detection bounding boxes
   - Capture confirmation
9. **Material Edit Screen**
   - Detected materials list with confidence
   - Edit material types/quantities
   - Add location/notes
   - Generate opportunities button
10. **Material Inventory Screen**
    - List view with filters
    - Status indicators
    - Search functionality
11. **Material Detail Screen**
    - Full material info
    - Photos gallery
    - Lifecycle timeline
    - Actions (edit, archive)
12. **Opportunities Dashboard** ⭐
    - Generated opportunity cards
    - Confirm/Reject actions
    - Student match details
13. **Skill Requirements Screen**
    - Post new requirements
    - Manage existing posts
    - View applications
14. **Analytics Dashboard**
    - Lab's impact metrics
    - Department leaderboard
    - Export options

#### **Student Flow**
15. **Student Dashboard** - Personalized feed + quick actions
16. **Profile Setup/Edit Screen** ⭐
    - Skills selection (multi-select chips)
    - Domain preferences
    - Project interests
    - Availability settings
17. **Discovery Map Screen** ⭐
    - Campus map with material pins
    - Distance-based filtering
    - Material preview on tap
18. **Materials Feed Screen**
    - "Near you" materials list
    - Filters (type, distance, availability)
    - Quick request buttons
19. **Material Detail Screen** (Student view)
    - Material info + photos
    - Request/Interest button
    - Similar materials
20. **Request Board Screen** ⭐
    - My requests list
    - Post new request modal
    - Progress tracking
21. **Request Creation Screen**
    - Material type selection
    - Quantity + deadline
    - Project description
    - Photo upload (optional)
22. **Barter Opportunities Screen**
    - Available skill requirements
    - Apply to opportunities
    - My applications status
23. **Project Portfolio Screen**
    - Completed projects gallery
    - Achievement badges
    - Impact contributions
24. **My Requests Screen**
    - Active/completed requests
    - Match notifications
    - Request editing

#### **Shared Screens**
25. **Notifications Screen** - All app notifications
26. **Settings Screen** - Profile, preferences, privacy
27. **Impact Dashboard** ⭐ - Personal/campus sustainability metrics
28. **Help & Support Screen** - FAQ, contact, tutorials
29. **Material Categories Screen** - Browse all available types
30. **Project Ideas Gallery** - Inspiration + examples
31. **Campus Directory Screen** - Labs, departments, contacts
32. **Lifecycle Tracking Screen** - Material journey visualization

#### **Admin Flow (Lightweight)**
33. **Admin Dashboard** - System overview
34. **User Management Screen** - Basic moderation
35. **Campus Configuration Screen** - Zones, categories
36. **System Analytics Screen** - Platform-wide metrics
37. **Content Moderation Screen** - Review flagged content

## 🚀 Implementation Phases

### **Phase 1: Foundation (Weeks 1-3)**
- [ ] Project setup (Flutter, Supabase, Firebase)
- [ ] Database schema implementation
- [ ] Authentication system (Supabase Auth)
- [ ] Basic navigation structure
- [ ] Role-based routing
- [ ] Core UI components library

**Deliverable**: Basic app with auth + role selection

### **Phase 2: Material Detection Core (Weeks 4-6)**
- [ ] Camera integration
- [ ] Circular Net TensorFlow model integration
- [ ] Material capture screen with AI overlay
- [ ] Image processing pipeline
- [ ] Material data storage
- [ ] Basic inventory management

**Deliverable**: Working material detection system

### **Phase 3: Student Discovery (Weeks 7-8)**
- [ ] Student profile system
- [ ] Campus map integration
- [ ] Material discovery feeds
- [ ] Distance-based sorting
- [ ] Basic matching algorithm

**Deliverable**: Students can discover materials

### **Phase 4: Matching & Opportunities (Weeks 9-11)**
- [ ] AI-powered student-material matching
- [ ] Opportunity card generation
- [ ] Project suggestion algorithm
- [ ] Carbon impact calculations
- [ ] Opportunity management interface

**Deliverable**: Core matching system working

### **Phase 5: Request System (Weeks 12-13)**
- [ ] Material request creation
- [ ] Request board interface
- [ ] Progress tracking
- [ ] Match notifications
- [ ] Request-opportunity linking

**Deliverable**: Complete request-supply system

### **Phase 6: Lifecycle & Barter (Weeks 14-15)**
- [ ] Lifecycle tracking system
- [ ] Status management
- [ ] Barter system implementation
- [ ] Skill requirement posting
- [ ] Application workflow

**Deliverable**: Full material lifecycle tracking

### **Phase 7: Notifications & Real-time (Weeks 16-17)**
- [ ] Firebase Cloud Messaging setup
- [ ] Supabase real-time subscriptions
- [ ] Push notification system
- [ ] In-app notifications
- [ ] Real-time updates

**Deliverable**: Live notification system

### **Phase 8: Analytics & Impact (Weeks 18-19)**
- [ ] Impact calculation algorithms
- [ ] Dashboard implementations
- [ ] Leaderboards
- [ ] Data export features
- [ ] Sustainability reporting

**Deliverable**: Complete analytics system

### **Phase 9: Polish & Testing (Weeks 20-22)**
- [ ] UI/UX improvements
- [ ] Performance optimization
- [ ] Comprehensive testing
- [ ] Bug fixes
- [ ] Accessibility improvements

**Deliverable**: Production-ready app

### **Phase 10: Deployment & Launch (Weeks 23-24)**
- [ ] App store preparation
- [ ] Production deployment
- [ ] Monitoring setup
- [ ] User documentation
- [ ] Launch preparations

**Deliverable**: Live app in stores

## 🔧 Technical Implementation Details

### **State Management**
- **Recommended**: Riverpod for Flutter
- **Alternative**: Bloc pattern
- Local state for UI, global state for user/materials

### **Offline Support**
- Cached material data (Hive/SQLite)
- Offline image capture + sync
- Queue for failed network requests

### **Image Processing Pipeline**
```
Image Capture → Preprocessing → TensorFlow Model → 
Post-processing → Confidence Filtering → Database Storage
```

### **Matching Algorithm Factors**
1. Student skill alignment (40%)
2. Geographic proximity (25%)
3. Project interest match (20%)
4. Availability/deadlines (10%)
5. Past success rate (5%)

### **Real-time Features**
- Material status updates
- New opportunity notifications
- Chat/messaging (future)
- Live inventory updates

## 📱 Additional Screens Recommended

### **Missing Screens to Add**

1. **Tutorial/Walkthrough Screen** - For each user type
2. **Material Comparison Screen** - Side-by-side comparison
3. **Project Gallery Screen** - Success stories + inspiration
4. **QR Code Scanner Screen** - For physical material tracking
5. **Bulk Material Upload Screen** - Multiple materials at once
6. **Material Reservation Screen** - Temporary holds
7. **Feedback/Rating Screen** - Post-project completion
8. **Emergency Contact Screen** - Safety for material handling
9. **Calendar Integration Screen** - Pickup scheduling
10. **Material History Screen** - Previous interactions
11. **Campus Events Screen** - Sustainability events
12. **Leaderboard Screen** - Gamification elements
13. **Report Issue Screen** - Material/user reporting
14. **Maintenance Log Screen** - Equipment tracking
15. **Integration Settings Screen** - External system connections

### **Enhanced Features to Consider**

1. **Smart Notifications**
   - ML-based optimal timing
   - Personalized content
   - Batch digest options

2. **Advanced Search**
   - Visual search (image-to-material)
   - Voice search
   - Saved searches/alerts

3. **Social Features**
   - Project collaborations
   - Student groups
   - Mentor connections

4. **Gamification**
   - Achievement badges
   - Sustainability scores
   - Challenge participation

5. **Integration Capabilities**
   - Campus management systems
   - Academic calendars
   - External waste tracking

## 🔒 Security & Privacy Considerations

- **Data Encryption**: All sensitive data encrypted
- **Role-based Access Control**: Strict permission system
- **Image Privacy**: Auto-blur faces, personal info
- **GDPR Compliance**: Data export/deletion rights
- **Audit Trails**: All material movements logged

## 📈 Success Metrics

### **Technical KPIs**
- App responsiveness < 2s load times
- 99.5% uptime
- < 1% crash rate
- 95%+ detection accuracy

### **Business KPIs**
- Monthly active users
- Materials diverted from waste
- CO2 savings achieved
- Student project completion rate
- Campus adoption rate

This comprehensive plan provides a roadmap for building your ReClaim platform. The phased approach ensures steady progress while maintaining quality. Would you like me to dive deeper into any specific phase or create detailed wireframes for particular screens?