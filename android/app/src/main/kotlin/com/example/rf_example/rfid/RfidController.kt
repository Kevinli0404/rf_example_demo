package com.example.rf_example.rfid

/* ============================================================================
 * RfidController（mock 版）
 *
 * side project 版本不依賴任何廠商 SDK。
 * 所有操作直接回 success，並透過 RfidEventListener 推送對應狀態事件，
 * 讓上層（RfidPlugin / Flutter）的架構跟真實版完全一致。
 *
 * 對應真實版的行為差異：
 *   - initialize()     → 直接 success（真實版：初始化 SDK reader 物件）
 *   - connect()        → 直接 success + 推 "Connected"（真實版：SDK 連接底座）
 *   - disconnect()     → 直接 success + 推 "Disconnected"（真實版：SDK 斷線）
 *   - startInventory() → 直接 success（真實版：SDK 開始掃描 RFID tag）
 *   - stopInventory()  → 直接 success（真實版：SDK 停止掃描）
 * ============================================================================ */

import android.os.Handler
import android.os.Looper

/** RfidController 所有操作的回傳結果 */
sealed class RfidResult {
    data class Success(val data: Any? = null) : RfidResult()
    data class Error(
        val code: String,
        val message: String,
        val details: Any? = null,
    ) : RfidResult()
}

class RfidController(
    private val eventListener: RfidEventListener,
) {
    private val mainHandler = Handler(Looper.getMainLooper())

    /**
     * 初始化（mock：直接 success）
     * 真實版：建立 SDK reader 物件、設定 event listener
     */
    fun initialize(callback: (RfidResult) -> Unit) {
        mainHandler.post {
            callback(RfidResult.Success("initialized"))
        }
    }

    /**
     * 連線（mock：直接推 Connected + success）
     * 真實版：SDK reader.connect()，等待 onConnectionStateChanged 回呼
     */
    fun connect(callback: (RfidResult) -> Unit) {
        mainHandler.post {
            // 先推連線狀態，再回 success — 跟 SDK 的非同步事件順序一致
            eventListener.onConnectionStateChanged?.invoke("Connected")
            callback(RfidResult.Success("connected"))
        }
    }

    /**
     * 斷線（mock：直接推 Disconnected + success）
     * 真實版：SDK reader.disconnect()
     */
    fun disconnect(callback: (RfidResult) -> Unit) {
        mainHandler.post {
            eventListener.onConnectionStateChanged?.invoke("Disconnected")
            callback(RfidResult.Success("disconnected"))
        }
    }

    /**
     * 開始掃描（mock：直接 success）
     * 真實版：SDK 開啟 RFID inventory，tag 事件透過 onTagRead 推送
     * side project 的 tag 模擬在 Flutter 端的 ScanSessionController 處理
     */
    fun startInventory(callback: (RfidResult) -> Unit) {
        mainHandler.post {
            callback(RfidResult.Success("inventory started"))
        }
    }

    /**
     * 停止掃描（mock：直接 success）
     * 真實版：SDK 停止 inventory
     */
    fun stopInventory(callback: (RfidResult) -> Unit) {
        mainHandler.post {
            callback(RfidResult.Success("inventory stopped"))
        }
    }

    /** 釋放資源（mock：無需清理） */
    fun dispose() {
        // 真實版：reader.disconnect() + reader.release()
    }
}
