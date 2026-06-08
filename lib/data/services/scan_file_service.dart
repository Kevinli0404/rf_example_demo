import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rf_example/data/repositories/device_repository.dart';
import 'package:rf_example/pages/check_file_page/dialog/file_viewer_dialog.dart';

// 不允許出現在檔名中的字元（跨平台通用）
final _invalidChars = RegExp(r'[/\\:*?"<>|]');

enum ScanFileNameError { empty, invalidChar, duplicate, other }

class ScanFileNameException implements Exception {
  final ScanFileNameError error;
  const ScanFileNameException(this.error);

  String get message {
    switch (error) {
      case ScanFileNameError.empty:
        return '檔名不能空白';
      case ScanFileNameError.invalidChar:
        return '檔名含有不允許的字元：/ \\ : * ? " < > |';
      case ScanFileNameError.duplicate:
        return '已存在同名檔案，請重新命名';
      case ScanFileNameError.other:
        return '儲存失敗，請再試一次';
    }
  }
}

// 基本檔名驗證，通過回傳 trimmed 字串
String validateFileName(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) throw const ScanFileNameException(ScanFileNameError.empty);
  if (_invalidChars.hasMatch(trimmed)) throw const ScanFileNameException(ScanFileNameError.invalidChar);
  return trimmed;
}

/// RFIDExport/ 單支掃描檔摘要
class ScanFileSummary {
  final File file;
  // 不含 .txt 的檔名
  final String displayName;

  final DateTime? exportTime;
  final int deviceCount;

  const ScanFileSummary({
    required this.file,
    required this.displayName,
    required this.exportTime,
    required this.deviceCount,
  });
}

/// RFIDExport/ 掃描檔管理
class ScanFileService {
  static Future<Directory?> _getExportDir() async {
    try {
      final ext = await getExternalStorageDirectory();
      if (ext == null) return null;
      final dir = Directory('${ext.path}/RFIDExport');
      if (!await dir.exists()) return null;
      return dir;
    } catch (_) {
      return null;
    }
  }

  // 列出合法 .txt，依修改時間降冪
  Future<List<ScanFileSummary>> listValidScanFiles() async {
    final dir = await _getExportDir();
    if (dir == null) return const [];

    final files =
        (await dir.list().toList())
            .whereType<File>()
            .where((f) => f.path.toLowerCase().endsWith('.txt'))
            .toList();

    final result = <ScanFileSummary>[];
    for (final f in files) {
      final summary = await _tryParseSummary(f);
      if (summary != null) result.add(summary);
    }

    result.sort((a, b) {
      try {
        return b.file.statSync().modified.compareTo(a.file.statSync().modified);
      } catch (_) {
        return 0; // stat 失敗時保持原順序，不用 path 做無意義排序
      }
    });
    return result;
  }

  // 解析單一檔案
  Future<ScanFileSummary?> _tryParseSummary(File file) async {
    try {
      final content = await file.readAsString();
      final raw = jsonDecode(content);
      if (raw is! Map<String, dynamic>) return null;
      if (!raw.containsKey('ExportTime')) return null;
      if (raw['Devices'] is! List) return null;

      final devices = raw['Devices'] as List;
      for (final d in devices) {
        if (d is! Map) return null;
        if (d['Id'] == null || d['EPC'] == null || d['ScanTime'] == null) {
          return null;
        }
      }

      final filename = file.uri.pathSegments.last;
      final displayName = filename.toLowerCase().endsWith('.txt')
          ? filename.substring(0, filename.length - 4)
          : filename;
      final exportTime = DateTime.tryParse(
        raw['ExportTime']?.toString() ?? '',
      );

      return ScanFileSummary(
        file: file,
        displayName: displayName,
        exportTime: exportTime,
        deviceCount: devices.length,
      );
    } catch (e) {
      debugPrint('[ScanFileService] parse failed: ${file.path} → $e');
      return null;
    }
  }

  // ─── 讀檔 + EPC 查 DB ────────────────────────────────────────────────────

  // 讀檔並查 DB，組成顯示用 entry list
  Future<List<FileDeviceEntry>> readDevicesWithLookup({
    required File file,
    required DeviceRepository repository,
  }) async {
    final content = await file.readAsString();
    final raw = jsonDecode(content) as Map<String, dynamic>;
    final devices = raw['Devices'] as List;

    int unknownCounter = 0;
    final entries = <FileDeviceEntry>[];

    for (final d in devices) {
      final m = d as Map;
      final epc = (m['EPC'] as String).toUpperCase();

      final device = await repository.findByEpc(epc);
      if (device != null) {
        entries.add(
          FileDeviceEntry(
            name: device.name,
            instrument: device.instrumentNumber,
          ),
        );
      } else {
        unknownCounter++;
        entries.add(
          FileDeviceEntry(
            name: '未知設備$unknownCounter',
            instrument: '-----',
            isUnknown: true,
          ),
        );
      }
    }
    return entries;
  }

  // ─── 刪除 / 改名 ──────────────────────────────────────────────────────────

  // 刪除檔案
  Future<void> deleteScanFile(File file) async {
    if (await file.exists()) await file.delete();
  }

  // 改名前驗證
  Future<String?> validateRenameFilename(
    String newName,
    File currentFile,
  ) async {
    try {
      final trimmed = validateFileName(newName);
      final name =
          trimmed.toLowerCase().endsWith('.txt') ? trimmed : '$trimmed.txt';
      final target = File('${currentFile.parent.path}/$name');
      // 與原檔名相同 → 不算重複（使用者沒改）
      if (target.path == currentFile.path) return null;
      if (await target.exists()) {
        throw const ScanFileNameException(ScanFileNameError.duplicate);
      }
      return null;
    } on ScanFileNameException catch (e) {
      return e.message;
    }
  }

  // 改名
  Future<File> renameScanFile({
    required File file,
    required String newDisplayName,
  }) async {
    final trimmed = validateFileName(newDisplayName);
    final dir = file.parent;
    final name =
        trimmed.toLowerCase().endsWith('.txt') ? trimmed : '$trimmed.txt';
    final target = File('${dir.path}/$name');

    if (target.path == file.path) return file;
    if (await target.exists()) {
      throw const ScanFileNameException(ScanFileNameError.duplicate);
    }
    try {
      return await file.rename(target.path);
    } catch (_) {
      throw const ScanFileNameException(ScanFileNameError.other);
    }
  }
}
