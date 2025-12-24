#!/bin/bash
set -e
echo "🚀 ADDING PRO LOCKER + PHASE-3 ON EXISTING PROJECT"

BASE=app/src/main
PKG=com/kashem/locker
JPATH=$BASE/java/$PKG

# ---------- FOLDERS ----------
mkdir -p $JPATH/service
mkdir -p $JPATH/receiver
mkdir -p $BASE/res/layout
mkdir -p $BASE/res/xml

# ---------- DASHBOARD ----------
cat <<EOF > $JPATH/DashboardActivity.java
package $PKG;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;

public class DashboardActivity extends Activity {
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        setContentView(R.layout.activity_dashboard);

        findViewById(R.id.btnApps).setOnClickListener(v ->
            startActivity(new Intent(this, LockedAppsActivity.class))
        );
    }
}
EOF

# ---------- UNLOCK ----------
cat <<EOF > $JPATH/UnlockActivity.java
package $PKG;

import android.app.Activity;
import android.os.Bundle;

public class UnlockActivity extends Activity {
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        setContentView(R.layout.activity_unlock);
    }
}
EOF

# ---------- LOCKED APPS ----------
cat <<EOF > $JPATH/LockedAppsActivity.java
package $PKG;

import android.app.Activity;
import android.os.Bundle;

public class LockedAppsActivity extends Activity {
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        setContentView(R.layout.activity_locked_apps);
    }
}
EOF

# ---------- ACCESSIBILITY ----------
cat <<EOF > $JPATH/service/LockAccessibilityService.java
package $PKG.service;

import android.accessibilityservice.*;
import android.content.Intent;
import android.view.accessibility.AccessibilityEvent;
import $PKG.UnlockActivity;

public class LockAccessibilityService extends AccessibilityService {
    @Override
    public void onAccessibilityEvent(AccessibilityEvent e) {
        if (e.getPackageName() != null) {
            Intent i = new Intent(this, UnlockActivity.class);
            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(i);
        }
    }
    @Override public void onInterrupt() {}
}
EOF

# ---------- FOREGROUND SERVICE ----------
cat <<EOF > $JPATH/service/LockService.java
package $PKG.service;

import android.app.*;
import android.content.Intent;
import android.os.IBinder;

public class LockService extends Service {
    @Override
    public int onStartCommand(Intent i, int f, int id) {
        Notification n = new Notification.Builder(this,"lock")
                .setContentTitle("Kashem Locker Active")
                .setSmallIcon(android.R.drawable.ic_lock_lock)
                .build();
        startForeground(1,n);
        return START_STICKY;
    }
    @Override public IBinder onBind(Intent i){return null;}
}
EOF

# ---------- BOOT RECEIVER ----------
cat <<EOF > $JPATH/receiver/BootReceiver.java
package $PKG.receiver;

import android.content.*;
import $PKG.service.LockService;

public class BootReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context c, Intent i) {
        c.startForegroundService(new Intent(c, LockService.class));
    }
}
EOF

# ---------- LAYOUTS ----------
cat <<EOF > $BASE/res/layout/activity_dashboard.xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
android:orientation="vertical"
android:padding="24dp"
android:layout_width="match_parent"
android:layout_height="match_parent">

<Button
 android:id="@+id/btnApps"
 android:text="Select Apps to Lock"
 android:layout_width="match_parent"
 android:layout_height="wrap_content"/>
</LinearLayout>
EOF

cat <<EOF > $BASE/res/layout/activity_unlock.xml
<TextView xmlns:android="http://schemas.android.com/apk/res/android"
android:text="🔒 Enter PIN (Phase-3)"
android:gravity="center"
android:textSize="20sp"
android:layout_width="match_parent"
android:layout_height="match_parent"/>
EOF

cat <<EOF > $BASE/res/layout/activity_locked_apps.xml
<TextView xmlns:android="http://schemas.android.com/apk/res/android"
android:text="📱 Locked Apps List (Phase-3)"
android:gravity="center"
android:textSize="18sp"
android:layout_width="match_parent"
android:layout_height="match_parent"/>
EOF

# ---------- ACCESSIBILITY XML ----------
cat <<EOF > $BASE/res/xml/accessibility_service.xml
<accessibility-service xmlns:android="http://schemas.android.com/apk/res/android"
android:accessibilityEventTypes="typeWindowStateChanged"
android:accessibilityFeedbackType="feedbackGeneric"
android:canRetrieveWindowContent="true"/>
EOF

# ---------- MANIFEST PATCH ----------
sed -i '/<\/application>/i \
<activity android:name=".DashboardActivity" android:exported="true"/> \
<activity android:name=".UnlockActivity" android:exported="false"/> \
<activity android:name=".LockedAppsActivity" android:exported="false"/> \
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

echo "✅ PRO + PHASE-3 SUCCESSFULLY ADDED"
