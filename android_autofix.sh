#!/bin/bash
set -e

echo "🚀 Android Pro Auto Fix Started"

# ---- ENV CLEAN (important for AAPT2) ----
unset ANDROID_HOME
unset ANDROID_SDK_ROOT
hash -r

# ---- gradle.properties ----
cat <<EOF > gradle.properties
android.useAndroidX=true
android.enableJetifier=true
android.useAapt2Daemon=false
android.enableResourceOptimizations=false
org.gradle.jvmargs=-Xmx1024m
org.gradle.daemon=false
EOF

# ---- settings.gradle ----
cat <<EOF > settings.gradle
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
EOF

# ---- app/build.gradle ----
mkdir -p app
cat <<EOF > app/build.gradle
plugins {
    id "com.android.application"
}

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
EOF

# ---- Java source ----
mkdir -p app/src/main/java/com/kashem/locker
cat <<EOF > app/src/main/java/com/kashem/locker/MainActivity.java
package com.kashem.locker;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(android.R.layout.simple_list_item_1);
    }
}
EOF

# ---- AndroidManifest ----
mkdir -p app/src/main
cat <<EOF > app/src/main/AndroidManifest.xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.kashem.locker">

    <application
        android:label="Kashem Locker"
        android:theme="@style/Theme.AppCompat.Light.NoActionBar">

        <activity android:name=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

    </application>
</manifest>
EOF

# ---- CLEAN & BUILD ----
rm -rf ~/.gradle app/build
./gradlew --stop || true
./gradlew assembleDebug --no-daemon

echo "✅ APK READY: app/build/outputs/apk/debug/app-debug.apk"
