package com/kashem/locker;

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
