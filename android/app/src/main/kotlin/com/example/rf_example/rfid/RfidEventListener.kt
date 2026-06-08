package com.example.rf_example.rfid

/* ============================================================================
 * RfidEventListener
 *
 * 純 lambda 容器，負責把 RfidController 的回呼橋接給 RfidPlugin。
 * side project 版本不需要實作任何 SDK interface，只保留 lambda 屬性。
 * ============================================================================ */

class RfidEventListener {
    /** 連線狀態變化："Connected" | "Connecting" | "Disconnected" */
    var onConnectionStateChanged: ((String) -> Unit)? = null

    /** 讀到 tag 時推送 EPC 字串（mock 版由 Flutter 端自己模擬，這裡預留介面） */
    var onTagRead: ((String) -> Unit)? = null

    /** 硬體鍵事件（side project 無實體扳機，預留介面） */
    var onKeyEvent: ((type: String, state: String) -> Unit)? = null

    /** 電池電量變化（0–100） */
    var onBatteryChanged: ((Int) -> Unit)? = null

    /** 裝置溫度變化（攝氏） */
    var onTemperatureChanged: ((Double) -> Unit)? = null
}
