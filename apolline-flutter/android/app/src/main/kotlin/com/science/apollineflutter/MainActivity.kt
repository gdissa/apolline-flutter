package com.science.apollineflutter

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.app.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterActivity() {
    private var forService: Intent? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
            GeneratedPluginRegistrant.registerWith(flutterEngine);
        }
        forService = Intent(this@MainActivity, BackgroundService::class.java)
        //le channel qui permet de communiquer avec le code flutter
        MethodChannel(flutterView, "apolline.backgroundChannel")
                .setMethodCallHandler { methodCall, result ->
                    if (methodCall.method == "startBackgroundService") { //le nom de la methode lancer depuis flutter
                        startService()
                        result.success("Service Started")
                    }
                }
    }

    override fun onDestroy() {
        super.onDestroy()
        stopService(forService)
    }

    private fun startService() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(forService)
        } else {
            startService(forService)
        }
    }
}
