# 🚀 ReClaim Setup Guide

## Prerequisites

1. **Flutter SDK** (>=3.10.0)
2. **Dart SDK** (>=3.0.0)
3. **Android Studio** for Android development
4. **Supabase Account** - [supabase.com](https://supabase.com)
5. **Firebase Account** - [firebase.google.com](https://firebase.google.com)

## Setup Instructions

### 1. Database Setup (Supabase)

1. Create a new Supabase project at [supabase.com](https://supabase.com)
2. Go to SQL Editor in your Supabase dashboard
3. Copy and paste the contents of `database/schema.sql`
4. Execute the SQL to create all tables and relationships
5. Go to Settings > API to get your:
   - Project URL
   - Anon public key

### 2. Firebase Setup

1. Create a new Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add an Android app to your Firebase project
3. Enable Authentication with Email/Password
4. Enable Cloud Messaging for push notifications
5. Install FlutterFire CLI: `npm install -g firebase-tools`
6. Login: `firebase login`
7. Configure for Android only: `flutterfire configure --platforms=android`
8. This will update `firebase_options.dart` with your Android config

### 3. Environment Configuration

1. Update `lib/core/config/app_config.dart` with your keys:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

2. For Maps (Phase 3):
   - Uses OpenStreetMap via Leaflet (flutter_map)
   - No API keys required - completely free and open source

### 4. Flutter Project Setup

```bash
# Navigate to project directory
cd ReClaim

# Get dependencies
flutter pub get

# Generate code (for Riverpod)
flutter packages pub run build_runner build

# Run the app
flutter run
```

### 5. Android Configuration

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Permissions -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**Note**: No API keys needed for maps - using OpenStreetMap!



## Development Workflow

### Phase 1: Foundation ✅
- [x] Database schema created
- [x] Flutter project structure
- [x] Authentication screens
- [x] Basic navigation
- [x] UI theme system

### Phase 2: Next Steps
- [ ] Implement Supabase authentication
- [ ] Add camera integration
- [ ] Create material detection pipeline
- [ ] Build material capture UI

## Folder Structure

```
lib/
├── core/
│   ├── config/          # App configuration
│   ├── models/          # Data models
│   ├── router/          # Navigation
│   └── theme/           # UI theme
├── features/
│   ├── auth/            # Authentication
│   ├── dashboard/       # Role-based dashboards
│   ├── materials/       # Material management
│   ├── discovery/       # Material discovery
│   ├── profile/         # User profiles
│   ├── opportunities/   # Matching system
│   ├── requests/        # Material requests
│   ├── barter/          # Skill exchange
│   ├── impact/          # Sustainability metrics
│   └── notifications/   # Push notifications
└── shared_screens.dart  # Placeholder screens
```

## Key Files Created

- ✅ **Database Schema**: Complete PostgreSQL schema with all tables
- ✅ **Flutter App**: Main app structure with navigation
- ✅ **Authentication Flow**: Onboarding → Auth → Role → Campus selection
- ✅ **UI System**: Theme, colors, typography using Material 3
- ✅ **Project Configuration**: pubspec.yaml with all dependencies

## Running the App

1. Make sure you have completed the Supabase and Firebase setup
2. Update configuration files with your API keys
3. Run `flutter pub get` to install dependencies
4. Connect an Android device or start an Android emulator
5. Run `flutter run`

**Note**: This app is designed for Android only. iOS support has been removed to focus development resources on the Android platform.

## Next Development Phase

Ready to implement:
1. **Supabase Authentication** - Connect login/signup to backend
2. **Camera Integration** - Add material detection capability
3. **Real-time Features** - Set up Supabase subscriptions
4. **State Management** - Implement Riverpod providers

The foundation is complete and ready for feature development! 🎉