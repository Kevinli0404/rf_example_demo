plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "com.example.rf_example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // applicationId 由各 flavor 覆寫
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "env"

    productFlavors {
        create("dev") {
            dimension = "env"
            applicationId = "com.example.rf_example.dev"
            resValue("string", "app_name", "RF Demo Dev")
        }
        create("prod") {
            dimension = "env"
            applicationId = "com.example.rf_example"
            resValue("string", "app_name", "RF Demo")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BoM — 統一管理所有 Firebase 套件版本
    implementation(platform("com.google.firebase:firebase-bom:34.0.0"))
    // Crashlytics
    implementation("com.google.firebase:firebase-crashlytics")
    // Analytics（Crashlytics 需要）
    implementation("com.google.firebase:firebase-analytics")
}
