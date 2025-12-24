#!/usr/bin/env bash
set -e

echo "🔧 Android project auto-fix started..."

# =========================
# BASIC CHECK
# =========================
if [ ! -d "app" ]; then
  echo "❌ app/ folder not found. Run from project root."
  exit 1
fi

# =========================
# CLEAN BROKEN STUFF
# =========================
echo "🧹 Cleaning old/broken gradle..."
rm -rf gradle
rm -f gradlew gradlew.bat
rm -rf ~/.gradle/caches
rm -rf ~/.gradle/wrapper

# =========================
# settings.gradle
# =========================
echo "✍️ Writing settings.gradle..."
cat > settings.gradle <<'S'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "KashemLocker"
include(":app")
S

# =========================
# root build.gradle
# =========================
echo "✍️ Writing root build.gradle..."
cat > build.gradle <<'B'
plugins {
    id "com.android.application" version "8.2.2" apply false
}
B

# =========================
# app/build.gradle
# =========================
echo "✍️ Writing app/build.gradle..."
cat > app/build.gradle <<'A'
apply plugin: "com.android.application"

android {
    namespace "com.kashem.locker"
    compileSdk 34

    defaultConfig {
        applicationId "com.kashem.locker"
        minSdk 26
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
        }
    }
}

dependencies {
    implementation "androidx.appcompat:appcompat:1.6.1"
    implementation "androidx.constraintlayout:constraintlayout:2.1.4"
}
A

# =========================
# ENSURE ANDROIDMANIFEST
# =========================
mkdir -p app/src/main
cat > app/src/main/AndroidManifest.xml <<'M'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <application
        android:label="Kashem Locker">

        <activity
            android:name=".MainActivity"
            android:exported="true">

            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>

        </activity>

    </application>
</manifest>
M

# =========================
# JAVA FILE CHECK
# =========================
JAVA_DIR="app/src/main/java/com/kashem/locker"
mkdir -p "$JAVA_DIR"

cat > "$JAVA_DIR/MainActivity.java" <<'J'
package com.kashem.locker;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
    }
}
J

# =========================
# LAYOUT FILE
# =========================
mkdir -p app/src/main/res/layout
cat > app/src/main/res/layout/activity_main.xml <<'L'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <TextView
        android:text="Kashem Locker Ready 🔐"
        android:textSize="22sp"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent"/>
</androidx.constraintlayout.widget.ConstraintLayout>
L

# =========================
# GRADLE WRAPPER
# =========================
echo "⚙️ Generating Gradle Wrapper..."
gradle wrapper --gradle-version 8.2 --distribution-type bin
chmod +x gradlew

# =========================
# BUILD APK
# =========================
echo "🏗️ Building Debug APK..."
./gradlew clean assembleDebug

echo "✅ DONE!"
echo "📦 APK → app/build/outputs/apk/debug/app-debug.apk"
