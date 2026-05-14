plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.crdb"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // 🔐 CRDB Bank Application ID
        applicationId = "com.example.crdb"
        // Version information
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // 🔐 Use R8 for enhanced obfuscation over ProGuard
            // R8 provides better optimization and obfuscation capabilities
            signingConfig = signingConfigs.getByName("debug")

            // 🔐 Enable code shrinking, obfuscation, and optimization
            isMinifyEnabled = true
            isShrinkResources = true

            // 🔐 Use R8 compiler for advanced obfuscation
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
