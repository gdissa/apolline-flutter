package com.science.apollineflutter

import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat


class BackgroundService : Service() {
    override fun onCreate() {
        super.onCreate()
            //crée la notification
            val builder = NotificationCompat.Builder(this, "messages")
                    .setContentText("Apolline is running in Background")
                    .setContentTitle("Flutter Background")
                    .setSmallIcon(R.drawable.ic_android_black_24dp)
            startForeground(101, builder.build())

    }

    override fun onBind(intent: Intent): IBinder? {
        return null
    }
}