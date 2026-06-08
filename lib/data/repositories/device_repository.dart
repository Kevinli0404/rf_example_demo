import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;

import '../../core/epc_rules.dart';
import '../database/app_database.dart';
import '../models/device.dart';
import '../models/device_export.dart';

@visibleForTesting
String stripJsonTrailingCommas(String json) {
  return json.replaceAllMapped(
    RegExp(r',(\s*[\]\}])'),
    (m) => m.group(1)!,
  );
}

class ImportOutcome {
  final bool cancelled;
  final int? importedCount;
  final String? errorMessage;

  const ImportOutcome._({
    this.cancelled = false,
    this.importedCount,
    this.errorMessage,
  });

  bool get isSuccess => importedCount != null;
  bool get isError => errorMessage != null;

  factory ImportOutcome.cancelled() => const ImportOutcome._(cancelled: true);
  factory ImportOutcome.success(int count) =>
      ImportOutcome._(importedCount: count);
  factory ImportOutcome.error(String message) =>
      ImportOutcome._(errorMessage: message);
}

class DeviceRepository {
  final AppDatabase _db;

  DeviceRepository(this._db);

  Future<void> importFromJsonString(String jsonString) async {
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    final export = DeviceExport.fromJson(jsonMap);
    await _db.replaceAllDevices(
      newDevices: export.devices.map((d) => d.toCompanion()).toList(),
      exportTime: export.exportTime,
    );
  }

  Future<ImportOutcome> importFromFile(File file) async {
    if (!await file.exists()) {
      return ImportOutcome.error('檔案不存在: ${file.path}');
    }
    final String content;
    try {
      content = await file.readAsString();
    } catch (e) {
      return ImportOutcome.error('讀取檔案失敗: $e');
    }
    return _importFromRawString(content);
  }

  Future<ImportOutcome> _importFromRawString(String content) async {
    final cleaned = stripJsonTrailingCommas(content);
    final dynamic raw;
    try {
      raw = jsonDecode(cleaned);
    } catch (_) {
      return ImportOutcome.error('檔案內容不是合法的 JSON');
    }
    if (raw is! Map<String, dynamic>) {
      return ImportOutcome.error('JSON 根層必須是物件');
    }
    if (!raw.containsKey('ExportTime')) {
      return ImportOutcome.error('檔案缺少 ExportTime 欄位');
    }
    if (!raw.containsKey('Devices') || raw['Devices'] is! List) {
      return ImportOutcome.error('檔案缺少或格式錯誤的 Devices 欄位');
    }
    try {
      final export = DeviceExport.fromJson(raw);
      await _db.replaceAllDevices(
        newDevices: export.devices.map((d) => d.toCompanion()).toList(),
        exportTime: export.exportTime,
      );
      return ImportOutcome.success(export.devices.length);
    } catch (e) {
      return ImportOutcome.error('解析設備清單失敗: $e');
    }
  }

  Future<void> clearAll() => _db.clearAllDevices();

  Stream<List<Device>> watchAllDevices() {
    return _db.watchAllDevices().map(
      (entities) => entities.map(Device.fromEntity).toList(),
    );
  }

  Future<List<Device>> getAllDevices() async {
    final entities = await _db.getAllDevices();
    return entities.map(Device.fromEntity).toList();
  }

  Stream<DateTime?> watchExportTime() => _db.watchExportTime();

  Future<Device?> findByEpc(String epc) async {
    final entity = await _db.findDeviceByEpc(epc);
    return entity == null ? null : Device.fromEntity(entity);
  }

  Future<int> count() => _db.countDevices();

  Future<EpcRules> getEpcRules() async {
    final raw = await _db.getEpcPrefixRulesRaw();
    return raw == null ? EpcRules.defaults : EpcRules.fromString(raw);
  }

  Stream<EpcRules> watchEpcRules() {
    return _db.watchEpcPrefixRulesRaw().map(
      (raw) => raw == null ? EpcRules.defaults : EpcRules.fromString(raw),
    );
  }

  Future<void> setEpcRules(EpcRules rules) async {
    await _db.setEpcPrefixRulesRaw(rules.toStorageString());
  }
}
