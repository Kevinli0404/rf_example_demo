package com.example.rf_example.rfid

/* ============================================================================
 * RfidPlugin
 *
 * Flutter Channel ↔ RfidController 之間的翻譯層。
 *
 * Channels（跟真實版 rfid_app 使用相同名稱，方便架構對照）：
 *   rfid_test/commands        — MethodChannel：Dart 下指令給 Kotlin
 *   rfid_test/connection_state — EventChannel：連線狀態推送
 *   rfid_test/tag_read        — EventChannel：tag EPC 推送（mock 版留空）
 *   rfid_test/device_status   — EventChannel：電池/溫度，改用原生 BatteryManager
 *
 * 與真實版的差異：
 *   - 移除 rfid_test/key_event（side project 無實體扳機）
 *   - device_status 改用 BatteryManager 定時輪詢，不再依賴廠商 SDK
 *   - vibrate / beep MethodChannel 邏輯保留完整，展示原生 API 使用
 * ============================================================================ */

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.BatteryManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.VibrationAttributes
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class RfidPlugin(
    private val messenger: BinaryMessenger,
    private val controller: RfidController,
    private val eventListener: RfidEventListener,
    private val context: Context,
) {
    companion object {
        private const val TAG = "RfidPlugin"
        private const val CHANNEL_COMMANDS = "rfid_test/commands"
        private const val CHANNEL_STATE    = "rfid_test/connection_state"
        private const val CHANNEL_TAG      = "rfid_test/tag_read"
        private const val CHANNEL_STATUS   = "rfid_test/device_status"

        /** 電池/溫度輪詢間隔（ms） */
        private const val BATTERY_POLL_MS = 5_000L
    }

    private var stateSink: EventChannel.EventSink? = null
    private var tagSink: EventChannel.EventSink? = null
    private var statusSink: EventChannel.EventSink? = null

    private val mainHandler = Handler(Looper.getMainLooper())

    /** 電池輪詢 Runnable（onCancel 時停止） */
    private var batteryRunnable: Runnable? = null

    // ═══════════════════════════════════════════════════
    // 入口
    // ═══════════════════════════════════════════════════

    fun setup() {
        // (1) MethodChannel
        MethodChannel(messenger, CHANNEL_COMMANDS)
            .setMethodCallHandler { call, result -> handleMethodCall(call, result) }

        // (2) 連線狀態 EventChannel
        EventChannel(messenger, CHANNEL_STATE).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    stateSink = events
                }
                override fun onCancel(arguments: Any?) {
                    stateSink = null
                }
            }
        )

        // (3) tag 讀取 EventChannel（mock 版：Flutter 端模擬，Kotlin 只保留介面）
        EventChannel(messenger, CHANNEL_TAG).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    tagSink = events
                }
                override fun onCancel(arguments: Any?) {
                    tagSink = null
                }
            }
        )

        // (4) 裝置狀態 EventChannel：onListen 開始輪詢，onCancel 停止
        EventChannel(messenger, CHANNEL_STATUS).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    statusSink = events
                    startBatteryPolling()
                }
                override fun onCancel(arguments: Any?) {
                    stopBatteryPolling()
                    statusSink = null
                }
            }
        )

        // (5) 把 eventListener 的 lambda 接到 sink
        eventListener.onConnectionStateChanged = { state ->
            mainHandler.post { stateSink?.success(state) }
        }
        eventListener.onTagRead = { epc ->
            mainHandler.post { tagSink?.success(epc) }
        }
    }

    // ═══════════════════════════════════════════════════
    // MethodChannel 路由
    // ═══════════════════════════════════════════════════

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "ping"           -> result.success("pong from Kotlin (mock)!")
                "initialize"     -> controller.initialize(toResult(result))
                "connect"        -> controller.connect(toResult(result))
                "disconnect"     -> controller.disconnect(toResult(result))
                "startInventory" -> controller.startInventory(toResult(result))
                "stopInventory"  -> controller.stopInventory(toResult(result))
                "vibrate" -> {
                    val ms = (call.argument<Int>("durationMs") ?: 80).toLong()
                    vibrate(ms)
                    result.success(null)
                }
                "beep" -> {
                    val ms = (call.argument<Int>("durationMs") ?: 200).toLong()
                    beep(ms)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (e: Throwable) {
            result.error("UNEXPECTED", e.message ?: "Unknown error", e.stackTraceToString())
        }
    }

    private fun toResult(result: MethodChannel.Result): (RfidResult) -> Unit = { r ->
        when (r) {
            is RfidResult.Success -> result.success(r.data)
            is RfidResult.Error   -> result.error(r.code, r.message, r.details)
        }
    }

    // ═══════════════════════════════════════════════════
    // 電池/溫度輪詢（原生 BatteryManager）
    // ═══════════════════════════════════════════════════

    /**
     * 用 Handler + Runnable 每 5 秒讀一次 sticky broadcast 拿電量跟溫度。
     * 第一次立即執行（postDelayed 0ms），之後每隔 BATTERY_POLL_MS 重複。
     *
     * 為什麼不用 BroadcastReceiver？
     *   ACTION_BATTERY_CHANGED 在電量沒變化時不會重複發，示範用途需要定時刷新。
     *   直接讀 sticky intent 是 Android 官方建議的一次性查詢方式。
     */
    private fun startBatteryPolling() {
        val runnable = object : Runnable {
            override fun run() {
                readAndPushBattery()
                mainHandler.postDelayed(this, BATTERY_POLL_MS)
            }
        }
        batteryRunnable = runnable
        mainHandler.post(runnable)
    }

    private fun stopBatteryPolling() {
        batteryRunnable?.let { mainHandler.removeCallbacks(it) }
        batteryRunnable = null
    }

    private fun readAndPushBattery() {
        val intent: Intent? = context.registerReceiver(
            null,
            IntentFilter(Intent.ACTION_BATTERY_CHANGED),
        )
        intent ?: return

        val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
        val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        val temp  = intent.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1)

        if (level >= 0 && scale > 0) {
            val percent = level * 100 / scale
            Log.d(TAG, "battery=$percent%  temp=${temp / 10.0}°C")
            statusSink?.success(mapOf("type" to "battery", "value" to percent))
        }
        if (temp >= 0) {
            statusSink?.success(mapOf("type" to "temperature", "value" to temp / 10.0))
        }
    }

    // ═══════════════════════════════════════════════════
    // 震動
    // ═══════════════════════════════════════════════════

    @Suppress("DEPRECATION")
    private fun vibrate(durationMs: Long) {
        val vibrator: Vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vm = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vm.defaultVibrator
        } else {
            context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
        if (!vibrator.hasVibrator()) return

        val effect = VibrationEffect.createOneShot(durationMs, VibrationEffect.DEFAULT_AMPLITUDE)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val attrs = VibrationAttributes.Builder()
                .setUsage(VibrationAttributes.USAGE_NOTIFICATION)
                .build()
            vibrator.vibrate(effect, attrs)
        } else {
            vibrator.vibrate(effect)
        }
    }

    // ═══════════════════════════════════════════════════
    // 錯誤音
    // ═══════════════════════════════════════════════════

    private fun beep(durationMs: Long) {
        Log.d(TAG, "beep() durationMs=$durationMs")
        try {
            val tg = ToneGenerator(AudioManager.STREAM_ALARM, 80)
            tg.startTone(ToneGenerator.TONE_PROP_NACK, durationMs.toInt())
            mainHandler.postDelayed({ tg.release() }, durationMs + 300L)
        } catch (e: Exception) {
            Log.e(TAG, "ToneGenerator failed: ${e.message}")
        }
    }
}
