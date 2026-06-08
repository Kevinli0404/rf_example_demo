import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:rf_example/data/models/device.dart';
import 'package:rf_example/data/services/scan_file_service.dart';

/// 掃描結果匯出服務
///
/// 寫入路徑：`<externalStorageDir>/RFIDExport/`，不需要 MANAGE_EXTERNAL_STORAGE，
/// 可透過 `adb pull` 取出。
///
/// 輸出格式：
/// ```json
/// {
///   "ExportTime": "2026-05-22T06:30:00Z",
///   "Devices": [{ "Id": "...", "EPC": "...", "ScanTime": "..." }]
/// }
/// ```
class ScanExportService {
  /// 組出完整的匯出 JSON 字串
  static String buildJsonString({
    required List<Device> devices,
    required Map<String, DateTime> scanTimes,
  }) {
    final now = DateTime.now().toUtc();
    final body = {
      'ExportTime': _toUtcIso(now),
      'Devices': devices.map((d) {
        final st = scanTimes[d.id]?.toUtc() ?? now;
        return {'Id': d.id, 'EPC': d.epc, 'ScanTime': _toUtcIso(st)};
      }).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(body);
  }

  /// 預覽目前時間產生的預設檔名（含衝突後綴），供 dialog 顯示用
  static Future<String> previewFilename() async {
    final base = _dateTimePart(DateTime.now());
    final dir = await _getExportDir();
    if (dir == null) return '$base.txt';
    String filename = '$base.txt';
    int counter = 2;
    while (await File('${dir.path}/$filename').exists()) {
      filename = '${base}_$counter.txt';
      counter++;
    }
    return filename;
  }

  /// 驗證檔名（空白 / 非法字元 / 重複），成功回傳 null，失敗回傳錯誤訊息
  static Future<String?> validateFilenameOnly(String filename) async {
    try {
      final trimmed = validateFileName(filename);
      final dir = await _getExportDir();
      if (dir != null) {
        final name = trimmed.toLowerCase().endsWith('.txt')
            ? trimmed
            : '$trimmed.txt';
        if (await File('${dir.path}/$name').exists()) {
          throw const ScanFileNameException(ScanFileNameError.duplicate);
        }
      }
      return null;
    } on ScanFileNameException catch (e) {
      return e.message;
    }
  }

  /// 把掃描資料寫到 RFIDExport/，成功回傳完整路徑，失敗回傳 null
  ///
  /// [preferredFilename] 由 dialog 回傳的使用者自訂檔名（不含 .txt 也可）；
  /// 不傳則以當前時間自動產生。
  static Future<String?> saveToExternalDir({
    required List<Device> devices,
    required Map<String, DateTime> scanTimes,
    String? preferredFilename,
  }) async {
    if (devices.isEmpty) return null;

    try {
      final dir = await _getExportDir();
      if (dir == null) return null;

      final jsonText = buildJsonString(devices: devices, scanTimes: scanTimes);
      final filename = await _resolveFilename(dir, preferredFilename);
      final file = File('${dir.path}/$filename');
      await file.writeAsString(jsonText);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  // ─── helpers ──────────────────────────────────────────────────────────────

  static Future<Directory?> _getExportDir() async {
    final extDir = await getExternalStorageDirectory();
    if (extDir == null) return null;
    final dir = Directory('${extDir.path}/RFIDExport');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<String> _resolveFilename(
    Directory dir,
    String? preferredFilename,
  ) async {
    final base = preferredFilename != null && preferredFilename.trim().isNotEmpty
        ? preferredFilename.trim().replaceAll(RegExp(r'\.txt$', caseSensitive: false), '')
        : _dateTimePart(DateTime.now());

    String filename = '$base.txt';
    int counter = 2;
    while (await File('${dir.path}/$filename').exists()) {
      filename = '${base}_$counter.txt';
      counter++;
    }
    return filename;
  }

  static String _dateTimePart(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)}'
        '_${two(t.hour)}${two(t.minute)}${two(t.second)}';
  }

  static String _toUtcIso(DateTime t) {
    final u = t.toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${u.year}-${two(u.month)}-${two(u.day)}'
        'T${two(u.hour)}:${two(u.minute)}:${two(u.second)}Z';
  }
}
