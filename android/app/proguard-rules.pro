-dontwarn com.google.android.play.core.**
-assumenosideeffects class com.google.android.play.core.** {
    *;
}

# Keep only the Flutter utility classes required by plugins (e.g., path_provider)
-keep class io.flutter.util.PathUtils { *; }

# Keep JNI classes – required for FFI-based JNI calls
-keep class jni.** { *; }

# Required to prevent "Missing type parameter" crash when using zonedSchedule
-keep class com.dexterous.** { *; }