#!/bin/bash
set -e

MANIFEST_PATH="app/src/main/AndroidManifest.xml"

echo "🔧 Fixing AndroidManifest.xml (Phase 3)"

# Check manifest exists
if [ ! -f "$MANIFEST_PATH" ]; then
  echo "❌ ERROR: $MANIFEST_PATH not found"
  exit 1
fi

# Backup existing manifest
cp "$MANIFEST_PATH" "${MANIFEST_PATH}.bak"
echo "📦 Backup created: AndroidManifest.xml.bak"

# Replace manifest content
cat <<'EOF' > "$MANIFEST_PATH"
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <application
        android:label="Kashem Locker"
        android:theme="@style/Theme.AppCompat.Light.NoActionBar">

        <!-- DASHBOARD = LAUNCHER -->
        <activity
            android:name=".DashboardActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <!-- INTERNAL ACTIVITIES -->
        <activity
            android:name=".MainActivity"
            android:exported="false"/>

        <activity
            android:name=".UnlockActivity"
            android:exported="false"/>

        <activity
            android:name=".LockedAppsActivity"
            android:exported="false"/>

        <!-- ACCESSIBILITY SERVICE -->
        <service
            android:name=".service.LockAccessibilityService"
            android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"
            android:exported="false">
            <intent-filter>
                <action android:name="android.accessibilityservice.AccessibilityService"/>
            </intent-filter>
            <meta-data
                android:name="android.accessibilityservice"
                android:resource="@xml/accessibility_service"/>
        </service>

        <!-- FOREGROUND SERVICE -->
        <service
            android:name=".service.LockService"
            android:exported="false"/>

        <!-- BOOT RECEIVER -->
        <receiver
            android:name=".receiver.BootReceiver"
            android:exported="false">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
            </intent-filter>
        </receiver>

    </application>

</manifest>
EOF

echo "✅ AndroidManifest.xml replaced successfully"

# Optional local build test
echo "🚀 Running local Gradle build test..."
./gradlew clean assembleDebug --no-daemon

echo "🎉 Phase 3 Manifest Fix completed successfully"
