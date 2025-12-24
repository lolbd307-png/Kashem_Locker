package com/kashem/locker;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;

public class LockedAppActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        setContentView(R.layout.activity_locked_apps);
    }
}
