#!/bin/bash
set -e

echo "🚀 PRO ANDROID LOCKER SETUP STARTED"

PKG=com/kashem/locker
BASE=app/src/main

mkdir -p $BASE/java/$PKG
mkdir -p $BASE/res/layout
mkdir -p $BASE/res/values
mkdir -p .github/workflows

# ---------------- MANIFEST ----------------
cat <<EOF > $BASE/AndroidManifest.xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <application
        android:label="Kashem Locker"
        android:theme="@style/Theme.AppCompat.Light.NoActionBar">

        <activity android:name=".LockedAppActivity" android:exported="false"/>
        <activity android:name=".UnlockActivity" android:exported="false"/>
        <activity android:name=".SetPinActivity" android:exported="false"/>

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
EOF

# ---------------- JAVA FILES ----------------

cat <<EOF > $BASE/java/$PKG/MainActivity.java
package $PKG;

import android.content.Intent;
import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        setContentView(R.layout.activity_main);
        findViewById(R.id.btnSetPin).setOnClickListener(v ->
            startActivity(new Intent(this, SetPinActivity.class)));
        findViewById(R.id.btnApps).setOnClickListener(v ->
            startActivity(new Intent(this, UnlockActivity.class)));
    }
}
EOF

cat <<EOF > $BASE/java/$PKG/SetPinActivity.java
package $PKG;

import android.os.Bundle;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;

public class SetPinActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        setContentView(R.layout.activity_set_pin);
        EditText pin = findViewById(R.id.pinInput);
        findViewById(R.id.savePin).setOnClickListener(v -> {
            if (pin.length() >= 4) {
                Prefs.savePin(this, pin.getText().toString());
                Toast.makeText(this,"PIN Saved",Toast.LENGTH_SHORT).show();
                finish();
            }
        });
    }
}
EOF

cat <<EOF > $BASE/java/$PKG/UnlockActivity.java
package $PKG;

import android.os.Bundle;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;

public class UnlockActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        setContentView(R.layout.activity_unlock);
        EditText p = findViewById(R.id.unlockPin);
        findViewById(R.id.unlockBtn).setOnClickListener(v -> {
            if (Prefs.checkPin(this, p.getText().toString())) {
                startActivity(new android.content.Intent(this, LockedAppActivity.class));
                finish();
            } else Toast.makeText(this,"Wrong PIN",Toast.LENGTH_SHORT).show();
        });
    }
}
EOF

cat <<EOF > $BASE/java/$PKG/LockedAppActivity.java
package $PKG;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;

public class LockedAppActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        setContentView(R.layout.activity_locked_apps);
    }
}
EOF

cat <<EOF > $BASE/java/$PKG/Prefs.java
package $PKG;

import android.content.*;

public class Prefs {
    static final String P="locker",K="pin";
    static void savePin(Context c,String p){
        c.getSharedPreferences(P,0).edit().putString(K,p).apply();
    }
    static boolean checkPin(Context c,String p){
        return p.equals(c.getSharedPreferences(P,0).getString(K,""));
    }
}
EOF

# ---------------- XML ----------------

cat <<EOF > $BASE/res/layout/activity_main.xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
android:orientation="vertical" android:padding="24dp"
android:layout_width="match_parent" android:layout_height="match_parent">

<Button android:id="@+id/btnSetPin" android:text="Set PIN"
android:layout_width="match_parent" android:layout_height="wrap_content"/>

<Button android:id="@+id/btnApps" android:text="Open Locker"
android:layout_width="match_parent" android:layout_height="wrap_content"/>

</LinearLayout>
EOF

cat <<EOF > $BASE/res/layout/activity_set_pin.xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
android:orientation="vertical" android:padding="24dp"
android:layout_width="match_parent" android:layout_height="match_parent">

<EditText android:id="@+id/pinInput" android:hint="Enter PIN"
android:inputType="numberPassword"
android:layout_width="match_parent" android:layout_height="wrap_content"/>

<Button android:id="@+id/savePin" android:text="Save PIN"
android:layout_width="match_parent" android:layout_height="wrap_content"/>
</LinearLayout>
EOF

cat <<EOF > $BASE/res/layout/activity_unlock.xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
android:orientation="vertical" android:padding="24dp"
android:layout_width="match_parent" android:layout_height="match_parent">

<EditText android:id="@+id/unlockPin" android:hint="Enter PIN"
android:inputType="numberPassword"
android:layout_width="match_parent" android:layout_height="wrap_content"/>

<Button android:id="@+id/unlockBtn" android:text="Unlock"
android:layout_width="match_parent" android:layout_height="wrap_content"/>
</LinearLayout>
EOF

cat <<EOF > $BASE/res/layout/activity_locked_apps.xml
<TextView xmlns:android="http://schemas.android.com/apk/res/android"
android:text="🔒 App Lock System Ready (Phase-2)"
android:gravity="center"
android:textSize="20sp"
android:layout_width="match_parent"
android:layout_height="match_parent"/>
EOF

# ---------------- VALUES ----------------
cat <<EOF > $BASE/res/values/strings.xml
<resources>
<string name="app_name">Kashem Locker</string>
</resources>
EOF

cat <<EOF > $BASE/res/values/styles.xml
<resources>
<style name="Theme.AppCompat.Light.NoActionBar"/>
</resources>
EOF

# ---------------- GITHUB ACTION ----------------
cat <<EOF > .github/workflows/android-build.yml
name: Build APK
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-java@v4
      with:
        distribution: temurin
        java-version: 17
    - name: Build
      run: ./gradlew assembleDebug
    - uses: actions/upload-artifact@v4
      with:
        name: apk
        path: app/build/outputs/apk/debug/app-debug.apk
EOF

echo "✅ PRO LOCKER PROJECT READY"
