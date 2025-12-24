package com/kashem/locker;

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
