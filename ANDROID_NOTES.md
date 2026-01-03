# 📱 ReClaim - Android Development Notes

## Android-Only Configuration

This app has been configured specifically for Android development to streamline the development process and focus resources on one platform.

## Key Android Features

### Permissions Configured
- **INTERNET** - Network access for API calls
- **CAMERA** - Material detection via camera
- **ACCESS_FINE_LOCATION** - Finding materials near campus
- **ACCESS_COARSE_LOCATION** - General location services
- **WRITE_EXTERNAL_STORAGE** - Saving captured images
- **READ_EXTERNAL_STORAGE** - Accessing saved images

### Material Design 3
- Follows Android's Material You design guidelines
- Dynamic theming support
- Responsive layouts for different screen sizes

### Performance Optimizations
- **MultiDex** enabled for large app size
- **ProGuard** minification in release builds
- **Shrink resources** to reduce APK size
- **Target SDK 34** for latest Android features

## Building for Release

```bash
# Build release APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

## Testing on Device

```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in release mode
flutter run --release
```

## Android Studio Setup

1. Install Android Studio
2. Install Flutter plugin
3. Set up Android SDK (API level 34)
4. Create Android Virtual Device (AVD) for testing

## Play Store Preparation

When ready for Play Store release:

1. **Generate signing key**:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **Configure signing** in `android/app/build.gradle`

3. **Update app metadata** in `android/app/src/main/AndroidManifest.xml`

4. **Build signed bundle**:
```bash
flutter build appbundle
```

## Why Android-Only?

- **Faster Development**: Single platform focus
- **Market Priority**: Android has larger global market share
- **Cost Efficiency**: Reduced development and maintenance overhead
- **Feature Parity**: Avoid platform-specific feature gaps
- **Team Expertise**: Concentrate Android development skills

Future iOS support can be added later if needed by running `flutter create --platforms=ios .` and reconfiguring the project.