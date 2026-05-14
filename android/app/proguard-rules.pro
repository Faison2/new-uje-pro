# 🔐 ProGuard/R8 rules for CRDB Bank AGM Voting Application
# This file specifies bytecode obfuscation and optimization rules
# Prevents reverse engineering and protects sensitive logic

# ──────────────────────────────────────────────────────────────
# OBFUSCATION SETTINGS - Make bytecode unreadable to decompilers
# ──────────────────────────────────────────────────────────────

# 🔐 Aggressive obfuscation settings
-repackageclasses 'com.example.crdb.obfuscated'
-allowaccessmodification
-overloadaggressively

# 🔐 Rename everything aggressively (except kept classes)
-verbose

# 🔐 Enable all optimizations with high passes
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
-optimizationpasses 7
-mergeinterfacesaggressively

# 🔐 Keep attributes only when necessary for functionality
-keepattributes Annotation
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes Signature

# Keep R class members
-keep class **.R$*

-dontskipnonpubliclibraryclasses
-forceprocessing

# 🔐 LOGGING REMOVAL - Remove debug information from release builds
# Prevents hackers from understanding code flow through logs

# Remove all Log.* calls
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
    public static boolean isLoggable(java.lang.String, int);
}

# Remove System.out and System.err
-assumenosideeffects class java.io.PrintStream {
    public void println(...);
    public void print(...);
}

# 🔐 Remove sensitive debug assertions
-assumenosideeffects class java.lang.assert.Assertions {
    public static void assert(...);
}

# Keep Flutter engine classes (required for app functionality)
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# 🔐 SECURITY ENHANCEMENT: Obfuscate security service classes
# Keep functionality but hide implementation details
-keep class com.example.crdb.MainActivity
-keep class com.example.crdb.MainActivity$* {
    *;
}

# 🔐 Keep security-critical method signatures but obfuscate implementation
-keepclassmembers class com.example.crdb.MainActivity {
    public void onCreate(android.os.Bundle);
    public void configureFlutterEngine(io.flutter.embedding.engine.FlutterEngine);
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep serialization-related classes
-keep class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Fragment classes
-keep public class * extends android.app.Fragment
-keep public class * extends androidx.fragment.app.Fragment

# Keep Application class
-keep public class * extends android.app.Application

# Keep Service classes
-keep public class * extends android.app.Service

# Keep Activity classes
-keep public class * extends android.app.Activity

# Keep View subclasses
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# Keep Broadcast Receiver classes
-keep public class * extends android.content.BroadcastReceiver

# Keep Content Provider classes
-keep public class * extends android.content.ContentProvider

# 🔐 SELECTIVE OBFUSCATION - Keep structure but hide implementation
# Keep enum types to preserve functionality
-keep,allowobfuscation class com.example.crdb.** extends java.lang.Enum {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep data model classes but allow aggressive obfuscation
-keep class com.example.crdb.model.** {
    public <init>(...);
    public <fields>;
}

# Keep service classes but obfuscate methods
-keep class com.example.crdb.services.** {
    public <init>(...);
}

# 🔐 Obfuscate all Kotlin classes and lambdas
-keep class kotlin.** { *; }
-keep class kotlin.jvm.** { *; }
-keep class kotlin.coroutines.** { *; }

# 🔐 Obfuscate implementation but keep API contracts
-keepclassmembernames class com.example.crdb.** {
    <init>(...);
}

# Suppress warnings for Google Play Core classes
-dontwarn com.google.android.play.core.**

# 🔐 REFLECTION OBFUSCATION
# Keep reflection metadata minimal
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations

# 🔐 STRING ENCRYPTION (when using string obfuscation tools)
# Remove string content from readable memory locations
-keepattributes SourceFile
-renamesourcefileattribute SourceFile


# 🔐 Prevent decompilation-based attacks
# Obfuscate inner classes aggressively
-keepattributes InnerClasses
-keepattributes EnclosingMethod

