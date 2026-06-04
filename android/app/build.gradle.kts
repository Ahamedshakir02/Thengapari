plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase google-services plugin (reads src/<flavor>/google-services.json)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.agrimarketplace.agri_platform"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.agrimarketplace.agri_platform"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Firebase Auth/Firestore 6.x require Android 23+.
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Three Firebase environments map to three Flutter flavors.
    // Run with:  flutter run --flavor dev    -t lib/main_dev.dart
    //            flutter run --flavor staging -t lib/main_staging.dart
    //            flutter run --flavor prod    -t lib/main_prod.dart
    // Each flavor reads its own google-services.json from
    // android/app/src/<flavor>/google-services.json
    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Agri Dev")
        }
        create("staging") {
            dimension = "env"
            applicationIdSuffix = ".staging"
            resValue("string", "app_name", "Agri Staging")
        }
        create("prod") {
            dimension = "env"
            // No suffix — prod uses the base applicationId.
            resValue("string", "app_name", "Agri Marketplace")
        }
    }
}

flutter {
    source = "../.."
}
