package com.example.rf_example

/* ============================================================================
 * MainActivity
 *
 * 薄薄的入口，負責：
 *   1. 在 Flutter Engine 啟動時建立 controller / eventListener / plugin
 *   2. onDestroy 時 dispose controller
 *
 * 與真實版（rfid_app）的差異：
 *   - 移除硬體 keycode 攔截（dispatchKeyEvent）
 *     → side project 沒有 RFID 扳機，掃描由 UI 按鈕觸發
 *   - 其餘架構完全一致
 * ============================================================================ */

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

    override fun onDestroy() {
        if (::controller.isInitialized) {
            controller.dispose()
        }
        super.onDestroy()
    }
}
