package com/kashem/locker.receiver;

import android.content.*;
import com/kashem/locker.service.LockService;

public class BootReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context c, Intent i) {
        c.startForegroundService(new Intent(c, LockService.class));
    }
}
