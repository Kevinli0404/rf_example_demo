import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:rf_example/data/models/device.dart';
import 'package:rf_example/data/services/scan_file_service.dart';

/// 掃描結果匯出服務，寫入 RFIDExport/ 目錄
class ScanExportService {
  // 組出完整的匯出 JSON 字串
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

  // 預覽預設檔名供 dialog 顯示
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

  // 檔名驗證
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

  // 寫入 RFIDExport/
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
