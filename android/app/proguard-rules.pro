-keep class io.flutter.** { *; }
-dontwarn com.google.android.play.core.**

# Flutter Local Notifications ProGuard rules
# Required to prevent "Missing type parameter" crash when using zonedSchedule
# Keep Flutter Local Notifications plugin classes
-keep class com.dexterous.** { *; }
# Keep Gson TypeToken - required for reflection used by flutter_local_notifications
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken { *; }
# Keep Gson annotations and attributes
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
# Prevent Gson from being stripped
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
# Keep classes with @SerializedName annotation
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}