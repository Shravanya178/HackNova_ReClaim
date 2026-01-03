class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://osdfgvujgqcliqyaujhk.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9zZGZndnVqZ3FjbGlxeWF1amhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc0MjE3MDAsImV4cCI6MjA4Mjk5NzcwMH0.3A7uAuQZxSBRXwI__GPheQrsNVTkFpDmS4Bj3whkyyY',
  );
  
  // Environment
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  
  // App Constants
  static const String appName = 'ReClaim';
  static const String appVersion = '1.0.0';
  
  // AI Model Constants
  static const String materialDetectionModelPath = 'assets/models/material_detection_model.tflite';
  static const double defaultConfidenceThreshold = 0.7;
  static const int maxDetectionsPerImage = 10;
  
  // UI Constants
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const double defaultBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  
  // Business Logic Constants
  static const int maxImageSize = 1024; // Max width/height in pixels
  static const int maxImagesPerLot = 5;
  static const int defaultMatchRadius = 5000; // 5km in meters
  static const Duration cacheExpiry = Duration(hours: 24);
}