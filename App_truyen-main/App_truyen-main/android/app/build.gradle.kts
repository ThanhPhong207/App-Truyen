import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.do_an_truyen"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.do_an_truyen"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    /*
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"]?.toString() ?: error("Missing keyAlias in key.properties")
            keyPassword = keystoreProperties["keyPassword"]?.toString() ?: error("Missing keyPassword in key.properties")
            storeFile = keystoreProperties["storeFile"]?.toString()?.let { file(it) } ?: error("Missing storeFile in key.properties")
            storePassword = keystoreProperties["storePassword"]?.toString() ?: error("Missing storePassword in key.properties")
        }
    }
    */
    buildTypes {
        release {
            // signingConfig = signingConfigs.getByName("release")
            // isMinifyEnabled = true // nếu có ProGuard
            // isMinifyEnabled = false
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
}

flutter {
    source = "../.."
}
