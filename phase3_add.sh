#!/bin/bash
set -e
echo "🚀 PHASE-3 LOCKER FEATURES ADDING..."

PKG=com/kashem/locker
BASE=app/src/main

mkdir -p $BASE/java/$PKG/service
mkdir -p $BASE/java/$PKG/receiver
mkdir -p $BASE/res/xml
mkdir -p $BASE/res/layout

# ---------------- ACCESSIBILITY SERVICE ----------------
cat <<EOF > $BASE/java/$PKG/service/LockAccessibilityService.java
package $PKG.service;

import android.accessibilityservice.*;
import android.view.accessibility.AccessibilityEvent;
import android.content.Intent;
import $PKG.UnlockActivity;

public class LockAccessibilityService extends AccessibilityService {
    @Override
    public void onAccessibilityEvent(AccessibilityEvent e) {
        if (e.getPackageName() != null) {
            String pkg = e.getPackageName().toString();
            if (getSharedPreferences("locker", MODE_PRIVATE)
                .getBoolean(pkg, false)) {
                Intent i = new Intent(this, UnlockActivity.class);
                i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(i);
            }
        }
    }
    @Override public void onInterrupt() {}
}
EOF

# ---------------- BOOT RECEIVER ----------------
cat <<EOF > $BASE/java/$PKG/receiver/BootReceiver.java
package $PKG.receiver;

import android.content.*;
import android.os.Build;
import $PKG.service.LockService;

public class BootReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context c, Intent i) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(i.getAction())) {
            c.startForegroundService(new Intent(c, LockService.class));
        }
    }
}
EOF

# ---------------- FOREGROUND SERVICE ----------------
cat <<EOF > $BASE/java/$PKG/service/LockService.java
package $PKG.service;

import android.app.*;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;

public class LockService extends Service {
    @Override
    public int onStartCommand(Intent i, int f, int id) {
        Notification n = new Notification.Builder(this,"lock")
                .setContentTitle("Kashem Locker Running")
                .setSmallIcon(android.R.drawable.ic_lock_lock)
                .build();
        startForeground(1,n);
        return START_STICKY;
    }
    @Override public IBinder onBind(Intent i){return null;}
}
EOF

# ---------------- APP LIST UI ----------------
cat <<EOF > $BASE/res/layout/activity_locked_apps.xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
android:orientation="vertical"
android:layout_width="match_parent"
android:layout_height="match_parent">

<TextView
 android:text="Select Apps to Lock (Phase-3)"
 android:textSize="18sp"
 android:padding="16dp"
 android:layout_width="match_parent"
 android:layout_height="wrap_content"/>

<ListView
 android:id="@+id/appList"
 android:layout_width="match_parent"
 android:layout_height="match_parent"/>
</LinearLayout>
EOF

# ---------------- ACCESSIBILITY CONFIG ----------------
cat <<EOF > $BASE/res/xml/accessibility_service.xml
<accessibility-service xmlns:android="http://schemas.android.com/apk/res/android"
android:accessibilityEventTypes="typeWindowStateChanged"
android:accessibilityFeedbackType="feedbackGeneric"
android:notificationTimeout="100"
android:canRetrieveWindowContent="true"
android:settingsActivity="$PKG.MainActivity"/>
EOF

# ---------------- MANIFEST UPDATE ----------------
sed -i '/<\/application>/i \
        <service android:name=".service.LockAccessibilityService" \
        android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE" \
        android:exported="false"> \
        <intent-filter> \
        <action android:name="android.accessibilityservice.AccessibilityService"/> \
        </intent-filter> \
        <meta-data android:name="android.accessibilityservice" \
        android:resource="@xml/accessibility_service"/> \
        </service> \
        <service android:name=".service.LockService" android:exported="false"/> \
        <receiver android:name=".receiver.BootReceiver" android:exported="false"> \
        <intent-filter> \
        <action android:name="android.intent.action.BOOT_COMPLETED"/> \
        </intent-filter> \
        </receiver>' $BASE/AndroidManifest.xml

echo "✅ PHASE-3 FEATURES ADDED SUCCESSFULLY"
