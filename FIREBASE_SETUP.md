# 🔥 Firebase Cloud Messaging Setup Guide

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: **ReClaim**
4. Disable Google Analytics (or enable if you want analytics)
5. Click **"Create project"**

## Step 2: Add Android App to Firebase

1. In Firebase Console, click on **Android icon** to add Android app
2. Enter package name: `com.example.reclaim` (or your actual package name from `android/app/build.gradle`)
3. Enter app nickname: **ReClaim Android**
4. Leave SHA-1 blank for now (needed later for Google Sign-In)
5. Click **"Register app"**

## Step 3: Download google-services.json

1. Download `google-services.json` file
2. Place it in: `android/app/google-services.json`

**IMPORTANT**: Do NOT commit this file to Git! Add to `.gitignore`:
```
# Firebase
android/app/google-services.json
```

## Step 4: Update build.gradle Files

### File: `android/build.gradle`
Add Google services to dependencies:

```gradle
buildscript {
    dependencies {
        // ... existing dependencies
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### File: `android/app/build.gradle`
Add at the bottom of the file:

```gradle
apply plugin: 'com.google.gms.google-services'
```

## Step 5: Update Package Name (if needed)

Check your package name in `android/app/build.gradle`:
```gradle
defaultConfig {
    applicationId "com.example.reclaim"  // This should match Firebase
}
```

If it's different, update it in Firebase Console or in your gradle file.

## Step 6: Install Dependencies

Run in terminal:
```bash
flutter pub get
```

## Step 7: Run the App

```bash
flutter run
```

## Step 8: Get FCM Token

When app runs, check the debug console for:
```
FCM Token: ey.....
```

Copy this token - you'll use it for testing notifications.

## Step 9: Test Notifications

### Method 1: Firebase Console (Easy)
1. Go to Firebase Console → **Cloud Messaging**
2. Click **"Send your first message"**
3. Enter:
   - **Notification title**: "Test Notification"
   - **Notification text**: "This is a test from Firebase"
4. Click **"Send test message"**
5. Paste your FCM token
6. Click **"Test"**

### Method 2: Using Postman/cURL

**Send to Specific Device:**
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
-H "Authorization: key=YOUR_SERVER_KEY" \
-H "Content-Type: application/json" \
-d '{
  "to": "FCM_TOKEN_HERE",
  "notification": {
    "title": "New Material Available!",
    "body": "Arduino boards found in Lab A"
  },
  "data": {
    "type": "opportunity",
    "material_id": "123",
    "action": "view"
  }
}'
```

**Send to Topic:**
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
-H "Authorization: key=YOUR_SERVER_KEY" \
-H "Content-Type: application/json" \
-d '{
  "to": "/topics/all_users",
  "notification": {
    "title": "System Update",
    "body": "ReClaim has new features!"
  }
}'
```

### Method 3: From Your App (In-App Testing)

Use the test button in notification screen to trigger local notifications.

## Step 10: Subscribe Users to Topics

In your code, subscribe users based on their role:

```dart
// Subscribe student to relevant topics
await NotificationService().subscribeToTopic('students');
await NotificationService().subscribeToTopic('campus_${campusId}');
await NotificationService().subscribeToTopic('department_${deptId}');

// Subscribe lab to their topics
await NotificationService().subscribeToTopic('labs');
await NotificationService().subscribeToTopic('opportunities');
```

## Notification Types in ReClaim

### 1. Opportunity Match
```json
{
  "notification": {
    "title": "🎯 New Match Found!",
    "body": "Your Arduino boards matched with 3 student projects"
  },
  "data": {
    "type": "opportunity",
    "opportunity_id": "uuid",
    "action": "view_opportunity"
  }
}
```

### 2. Material Request
```json
{
  "notification": {
    "title": "📦 New Material Request",
    "body": "Priya needs Arduino Uno for IoT project"
  },
  "data": {
    "type": "request",
    "request_id": "uuid",
    "student_id": "uuid",
    "action": "view_request"
  }
}
```

### 3. Barter Approval
```json
{
  "notification": {
    "title": "✅ Barter Accepted!",
    "body": "Your skill exchange has been approved"
  },
  "data": {
    "type": "barter",
    "barter_id": "uuid",
    "action": "view_barter"
  }
}
```

### 4. Pickup Reminder
```json
{
  "notification": {
    "title": "⏰ Pickup Reminder",
    "body": "Don't forget to collect materials from Lab A today"
  },
  "data": {
    "type": "reminder",
    "material_id": "uuid",
    "action": "view_material"
  }
}
```

### 5. Impact Milestone
```json
{
  "notification": {
    "title": "🎉 Milestone Achieved!",
    "body": "You've saved 10kg of CO₂ this month!"
  },
  "data": {
    "type": "achievement",
    "milestone": "co2_10kg",
    "action": "view_impact"
  }
}
```

## Server Key Location

To send notifications from backend:

1. Go to Firebase Console
2. Click **Settings (gear icon)** → **Project settings**
3. Go to **Cloud Messaging** tab
4. Copy **Server key** (Cloud Messaging API - Legacy)

**IMPORTANT**: Keep this key secret! Never commit to Git.

## Supabase Integration

To send notifications from Supabase Edge Functions:

```typescript
// supabase/functions/send-notification/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const FCM_SERVER_KEY = Deno.env.get('FCM_SERVER_KEY')

serve(async (req) => {
  const { token, title, body, data } = await req.json()
  
  const response = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Authorization': `key=${FCM_SERVER_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      to: token,
      notification: { title, body },
      data: data || {},
    }),
  })
  
  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

## Troubleshooting

### Issue: No FCM token
**Solution**: Check permissions and ensure Firebase is initialized before calling `initialize()`

### Issue: Notifications not showing
**Solution**: 
- Check notification permissions
- Ensure app is in foreground/background (not killed)
- Check Android notification channel is created

### Issue: App crashes on startup
**Solution**: 
- Ensure `google-services.json` is in correct location
- Run `flutter clean && flutter pub get`
- Check package name matches

### Issue: Background notifications not working
**Solution**: 
- Ensure background handler is top-level function
- Check Android battery optimization settings
- Test with device, not emulator

## Production Checklist

- [ ] Add `google-services.json` to `.gitignore`
- [ ] Store FCM server key securely (not in code)
- [ ] Set up proper topics for user segmentation
- [ ] Implement notification preferences in settings
- [ ] Add analytics to track notification performance
- [ ] Test on both Android and iOS (if supporting iOS)
- [ ] Implement retry logic for failed notifications
- [ ] Add rate limiting to prevent spam

## Next Steps

1. ✅ Test local notifications
2. ✅ Test FCM push notifications
3. ✅ Subscribe users to topics based on role
4. ✅ Integrate with your backend to send notifications
5. ✅ Add notification navigation logic
6. ✅ Implement notification preferences screen

Your notifications are now set up! 🎉
