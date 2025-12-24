package com/kashem/locker.service;

import android.accessibilityservice.*;
import android.content.Intent;
import android.view.accessibility.AccessibilityEvent;
import com/kashem/locker.UnlockActivity;

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
