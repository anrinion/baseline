-dontwarn com.google.android.play.core.**
-assumenosideeffects class com.google.android.play.core.** {
    *;
}

# Keep only the Flutter utility classes required by plugins (e.g., path_provider)
-keep class io.flutter.util.PathUtils { *; }

# Keep JNI classes – required for FFI-based JNI calls
-keep class jni.** { *; }

# Required to prevent "Missing type parameter" crash when using zonedSchedule.
# flutter_local_notifications uses Gson TypeToken with anonymous subclasses;
# Gson reads generic signatures at runtime via reflection, so both the plugin
# classes and the Signature attribute must survive R8 shrinking.
-keep class com.dexterous.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keepattributes Signature