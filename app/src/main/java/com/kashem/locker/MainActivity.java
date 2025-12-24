package com/kashem/locker;

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
