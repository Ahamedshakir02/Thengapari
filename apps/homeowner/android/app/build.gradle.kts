plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.thengapari.homeowner"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.thengapari.homeowner"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
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
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// razorpay_flutter pulls `com.razorpay:checkout:1.6.+`, resolving to 1.6.41.
// From 1.6.40 onward, checkout splits into `standard-core` + `core`, both
// published under the same `com.razorpay` namespace; AGP 9 rejects the duplicate
// namespace at manifest merge (and `core` holds resources `standard-core` needs,
// so it can't simply be excluded). 1.6.38 is the last self-contained single-AAR
// release — pin to it to avoid the collision while keeping all resources.
configurations.all {
    resolutionStrategy {
        force("com.razorpay:checkout:1.6.38")
    }
}
