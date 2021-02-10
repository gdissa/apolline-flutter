package com.science.apollineflutter

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.util.Log
import io.flutter.app.FlutterApplication


class MyApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel("messages", "Messages", NotificationManager.IMPORTANCE_LOW)
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
}