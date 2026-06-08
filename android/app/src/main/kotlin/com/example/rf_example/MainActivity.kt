package com.example.rf_example


import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import com.example.rf_example.rfid.RfidController
import com.example.rf_example.rfid.RfidEventListener
import com.example.rf_example.rfid.RfidPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private lateinit var controller: RfidController
    private lateinit var plugin: RfidPlugin
    private lateinit var eventListener: RfidEventListener

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        createNotificationChannel()
        eventListener = RfidEventListener()
        controller    = RfidController(eventListener)
        plugin        = RfidPlugin(
            flutterEngine.dartExecutor.binaryMessenger,
            controller,
            eventListener,
            applicationContext,
        )
        plugin.setup()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "rf_demo_channel",
                "RF Demo 通知",
                NotificationManager.IMPORTANCE_HIGH,
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        if (::controller.isInitialized) {
            controller.dispose()
        }
        super.onDestroy()
    }
}
