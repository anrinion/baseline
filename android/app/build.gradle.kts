import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Exclude Play Core
configurations.all {
    exclude(group = "com.google.android.play", module = "core")
}


// Load keystore properties if file exists (CI will create it)
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "io.github.anrinion.baseline"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "io.github.anrinion.baseline"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Define stable signing configuration
    signingConfigs {
        create("baseline") {
            keyAlias = keystoreProperties["keyAlias"] as? String
            keyPassword = keystoreProperties["keyPassword"] as? String
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as? String
        }
    }

    dependenciesInfo {
        // F-Droid
        includeInApk = false
        includeInBundle = false
    }

    buildFeatures {
        baselineProfile = false
    }

    buildTypes {
        getByName("debug") {
            // Use stable key for debug builds when available; otherwise fall back to default debug key
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("baseline")
            } else {
                signingConfigs.getByName("debug")
            }
        }
        release {
            // Use stable key for release builds when available; otherwise fall back to debug key
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("baseline")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    val abiCodes = mapOf("armeabi-v7a" to 1, "arm64-v8a" to 2, "x86_64" to 3)
    applicationVariants.configureEach {
        val variant = this
        outputs.forEach { output ->
            val abiFilter = output.filters.find { it.filterType == "ABI" }
            val abiName = abiFilter?.identifier
            val abiVersionCode = abiCodes[abiName]
            if (abiVersionCode != null) {
                (output as com.android.build.gradle.internal.api.ApkVariantOutputImpl).versionCodeOverride =
                    variant.versionCode * 10 + abiVersionCode
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}