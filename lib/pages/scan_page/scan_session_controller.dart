import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rf_example/data/models/device.dart';
import 'package:rf_example/data/repositories/device_repository.dart';
import 'package:rf_example/providers/rfid_providers.dart';

/// 掃描 session 狀態管理（ChangeNotifier）
///
/// 硬體不可用時以 Timer 模擬掃描行為：從 DB 取出設備清單，
/// 每 200ms emit 一筆並去重，邏輯層與真實版保持一致。
class ScanSessionController extends ChangeNotifier {
  ScanSessionController({
    required DeviceRepository repository,
    required bool Function() isConnected,
  })  : _repo = repository,
        _isConnected = isConnected;

  final DeviceRepository _repo;
  final bool Function() _isConnected;

  // ─── 狀態 ───
  final List<Device> _scannedDevices = [];
  final Map<String, DateTime> _scanTimes = {};
  final Set<String> _seenEpcs = {};
  bool _scanning = false;
  bool _toggling = false;

  // ─── mock 模擬 ───
  Timer? _simulationTimer;
  List<Device> _pendingDevices = [];

  // ─── 對外 getter（read-only）───
  List<Device> get scannedDevices => List.unmodifiable(_scannedDevices);
  Map<String, DateTime> get scanTimes => Map.unmodifiable(_scanTimes);
  bool get scanning => _scanning;
  bool get toggling => _toggling;
  int get totalCount => _scannedDevices.length;

  /// 切換模擬掃描 開 / 關。
  ///
  /// 回傳非 null 字串代表有錯誤，讓 UI 顯示 SnackBar。
  ///
  /// 切換掃描開關；回傳非 null 字串表示錯誤訊息。
  Future<String?> toggleScan() async {
    if (_toggling) return null;

    // ── 停止掃描 ────────────────────────────────────────────────
    if (_scanning) {
      _stopSimulation();
      _scanning = false;
      notifyListeners();
      return null;
    }

    // ── 開始掃描：需要連線 ──────────────────────────────────────
    if (!_isConnected()) {
      rfidBeep(); // 未連線 → NACK 錯誤音
      return '尚未連線，請先回首頁按 Connect';
    }

    _toggling = true;
    notifyListeners();

    await _startSimulation();

    _toggling = false;
    notifyListeners();
    return null;
  }

  /// 從 DB 取全部設備 → 過濾已掃過的 → 啟動 800ms timer 逐筆 emit
  Future<void> _startSimulation() async {
    final allDevices = await _repo.getAllDevices();

    // 只取還沒掃過的設備（支援多次掃描疊加）
    _pendingDevices =
        allDevices
            .where((d) => !_seenEpcs.contains(d.epc.toUpperCase()))
            .toList();

    _scanning = true;
    notifyListeners();

    _simulationTimer = Timer.periodic(const Duration(milliseconds: 200), (
      timer,
    ) {
      if (_pendingDevices.isEmpty) {
        // 所有設備都已 emit → 自動停止
        _stopSimulation();
        _scanning = false;
        notifyListeners();
        return;
      }
      _emitDevice(_pendingDevices.removeAt(0));
    });
  }

  void _stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _pendingDevices.clear();
  }

  /// 把一筆設備加進清單（模擬 tag read 命中 DB 的 Path 1）
  void _emitDevice(Device device) {
    final upper = device.epc.toUpperCase();
    if (_seenEpcs.contains(upper)) return; // 理論上過濾後不應重複

    _seenEpcs.add(upper);
    _scanTimes[device.id] = DateTime.now().toUtc();
    _scannedDevices.add(device);

    debugPrint('[mock-scan] emit "${device.name}" (${device.epc})');

    rfidVibrate(durationMs: 40); // 每筆觸覺回饋（Kotlin Vibrator，繞過 TOUCH=OFF 限制）
    notifyListeners();
  }

  /// 手動補登：外部選好 device 後呼叫
  void addManualDevice(Device device) {
    final upper = device.epc.toUpperCase();
    if (_seenEpcs.contains(upper)) return;
    _seenEpcs.add(upper);
    _scanTimes[device.id] = DateTime.now().toUtc();
    _scannedDevices.add(device);
    notifyListeners();
  }

  /// 清空掃描清單
  void clearAll() {
    _scannedDevices.clear();
    _seenEpcs.clear();
    _scanTimes.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopSimulation();
    super.dispose();
  }
}
