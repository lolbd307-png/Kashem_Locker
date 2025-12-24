package com/kashem/locker;

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
