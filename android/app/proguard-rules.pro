# Geolocator and Geocoding
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**
-keep class com.google.android.gms.location.** { *; }
-dontwarn com.google.android.gms.location.**
-keep class com.google.android.libraries.places.** { *; }
-dontwarn com.google.android.libraries.places.**

# HTTP
-keep class com.google.api.client.** { *; }
-dontwarn com.google.api.client.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# JSON serialization
-keep class com.example.weatherapp.models.** { *; }

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Provider
-keep class com.example.weatherapp.theme_provider.** { *; }

# Animated Text Kit
-keep class com.example.weatherapp.animated_text_kit.** { *; }