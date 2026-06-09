# RFID Asset Management System

以 RFID 設備盤點為應用場景的 Flutter Side Project，完整實作 Kotlin 原生整合、狀態管理、本地資料庫與 CI/CD 流程，架構與真實專案一致。

---

## Screenshots

<table>
  <tr>
    <td align="center"><b>首頁</b></td>
    <td align="center"><b>配對裝置</b></td>
    <td align="center"><b>掃描</b></td>
  </tr>
  <tr>
    <td><img src="screenshots/home.png" width="200"/></td>
    <td><img src="screenshots/pairing.png" width="200"/></td>
    <td><img src="screenshots/scan.png" width="200"/></td>
  </tr>
  <tr>
    <td align="center"><b>同步設備</b></td>
    <td align="center"><b>查看檔案</b></td>
    <td align="center"><b>FCM 推播</b></td>
  </tr>
  <tr>
    <td><img src="screenshots/device_list.png" width="200"/></td>
    <td><img src="screenshots/files.png" width="200"/></td>
    <td><img src="screenshots/fcm.png" width="200"/></td>
  </tr>
</table>

---

## Tech Stack

| 分類 | 技術 |
|------|------|
| Framework | Flutter 3.x / Dart |
| Native 整合 | Kotlin · MethodChannel · EventChannel |
| 狀態管理 | Riverpod 3 |
| 本地資料庫 | Drift (SQLite) |
| 推播通知 | Firebase Cloud Messaging (FCM) |
| 錯誤追蹤 | Firebase Crashlytics |
| 響應式尺寸 | flutter_screenutil |
| CI/CD | GitHub Actions + Firebase App Distribution |
| 多環境 | Build Flavor (dev / prod) |

---

## Architecture

```
lib/
├── core/            # 共用常數、工具
├── data/
│   ├── database/    # Drift schema & generated code
│   ├── models/      # 資料模型
│   ├── repositories/# 資料存取層
│   └── services/    # 業務邏輯服務
├── pages/           # UI 頁面
├── providers/       # Riverpod providers
├── services/        # App 層服務（FCM 等）
├── viewmodels/      # ViewModel（Riverpod Notifier）
└── widgets/         # 共用元件

android/
└── app/src/main/kotlin/
    └── rfid/
        ├── MainActivity.kt
        ├── RfidPlugin.kt        # MethodChannel / EventChannel 路由
        ├── RfidController.kt    # 硬體指令封裝
        └── RfidEventListener.kt
```

**採用 MVVM + Repository Pattern + Clean Architecture**

- Native 層透過 MethodChannel 接收 Flutter 指令，EventChannel 即時推送連線狀態與裝置資訊
- Repository 統一管理 Drift 資料庫存取
- ViewModel 封裝業務邏輯，Page 只負責 UI 渲染

---

## CI/CD Pipeline

| 觸發條件 | 執行項目 |
|----------|----------|
| Pull Request | Analyze & Test |
| Merge to main | Analyze & Test → Build dev APK → Firebase App Distribution |
| Push tag `v*` | Analyze & Test → Build prod APK |

- PR 時只跑 Analyze & Test，main 受 Branch Protection 保護
- Merge 進 main 後自動 build dev APK 並部署到 Firebase App Distribution
- Production build 僅在 push tag 時觸發

<table>
  <tr>
    <td align="center"><b>GitHub Actions</b></td>
    <td align="center"><b>Pipeline 流程</b></td>
  </tr>
  <tr>
    <td><img src="screenshots/github_actions_list.png" width="400"/></td>
    <td><img src="screenshots/github_actions_detail.png" width="400"/></td>
  </tr>
  <tr>
    <td align="center"><b>PR 紀錄</b></td>
    <td align="center"><b>Firebase App Distribution</b></td>
  </tr>
  <tr>
    <td><img src="screenshots/pull_requests.png" width="400"/></td>
    <td><img src="screenshots/firebase_app_distribution.png" width="400"/></td>
  </tr>
</table>

---

## Key Features

- **RFID 掃描** — 連線後模擬真實硬體掃描流程，每筆 tag 透過 MethodChannel 觸發 Kotlin 原生震動回饋，並進行去重複邏輯
- **設備同步** — 從 JSON 匯入設備清單至本地 Drift 資料庫，支援搜尋與清空
- **掃描結果匯出** — 將掃描結果寫入外部儲存，支援自訂檔名與重新命名
- **FCM 推播** — 整合 Firebase Cloud Messaging，支援前景 banner 與背景系統通知，可透過 Firebase Console 對所有已安裝裝置發送推播

  <table>
    <tr>
      <td align="center"><b>背景系統通知</b></td>
      <td align="center"><b>Firebase Console</b></td>
    </tr>
    <tr>
      <td><img src="screenshots/fcm.png" width="200"/></td>
      <td><img src="screenshots/fcm_console.png" width="400"/></td>
    </tr>
  </table>
- **裝置狀態監測** — 真實 RFID 硬體需特定裝置才能運作，此專案改以 Android BatteryManager 定時輪詢電池電量與溫度，透過 EventChannel 推送至 Flutter，展示相同的原生串流整合架構
- **多環境建置** — dev / prod 兩套 Firebase 設定與 applicationId，Firebase Console 分專案管理

  <img src="screenshots/firebase_projects.png" width="300"/>

- **錯誤追蹤** — Firebase Crashlytics 整合，自動捕捉未處理例外並上報；截圖為開發期間手動觸發 crash 的測試紀錄，正式版本已移除該觸發入口

  <img src="screenshots/crashlytics.png" width="400"/>

---

## Getting Started

**環境需求**
- Flutter SDK `>=3.10.0`
- Android SDK
- Firebase 專案（dev / prod 各一份 `google-services.json`）

**執行**

```bash
flutter run --flavor dev
flutter run --flavor prod
```

**測試**

```bash
flutter test
flutter analyze
```

---

## 範例資料

`assets/sample_export.txt` 為範例設備清單，可直接匯入 app 測試同步功能。
