import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val signingPropertiesFile = rootProject.file("key.properties")
val signingProperties = Properties()
if (signingPropertiesFile.exists()) {
    FileInputStream(signingPropertiesFile).use { signingProperties.load(it) }
}
val buildingRelease = gradle.startParameter.taskNames.any { it.contains("Release", ignoreCase = true) }
// Explicit preparation mode lets compilation finish before a private upload key is supplied.
// Ordinary release builds always require the real upload keystore; there is no debug fallback.
val preparingUnsignedRelease = providers.gradleProperty("prepareUnsignedRelease").orNull == "true" ||
    providers.environmentVariable("SAVING_GOALS_PREPARE_UNSIGNED_RELEASE").orNull == "true"
if (buildingRelease && !preparingUnsignedRelease) {
    check(signingPropertiesFile.exists()) {
        "Release signing is not configured. Create android/key.properties using tools/setup_upload_key.ps1."
    }
    listOf("storeFile", "storePassword", "keyAlias", "keyPassword").forEach { property ->
        check(!signingProperties.getProperty(property).isNullOrBlank()) {
            "Release signing property is missing: $property"
        }
    }
    check(rootProject.file(signingProperties.getProperty("storeFile")).exists()) {
        "The upload keystore configured in android/key.properties was not found."
    }
}

android {
    namespace = "com.savings.goals.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.savings.goals.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (signingPropertiesFile.exists()) {
                storeFile = rootProject.file(signingProperties.getProperty("storeFile"))
                storePassword = signingProperties.getProperty("storePassword")
                keyAlias = signingProperties.getProperty("keyAlias")
                keyPassword = signingProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (preparingUnsignedRelease) null else signingConfigs.getByName("release")
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
