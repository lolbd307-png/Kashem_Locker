package com/kashem/locker.service;

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
