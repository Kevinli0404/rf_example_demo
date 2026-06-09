import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rf_example/data/models/device.dart';
import 'package:rf_example/data/services/scan_export_service.dart';

final _utcIsoRegex = RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$');

const _sampleDevice = Device(
  uid: 'dev-001',
  serialCode: 'INS-001',
  label: '頻譜分析儀',
  registryId: 'ASSET-001',
  category: '量測組',
  epc: 'E280AABBCCDD',
);

void main() {
  group('ScanExportService.buildJsonString', () {
    test('空 devices → 含 ExportTime 與空 Devices array', () {
      final map = jsonDecode(
        ScanExportService.buildJsonString(devices: [], scanTimes: {}),
      ) as Map<String, dynamic>;
      expect(map.containsKey('ExportTime'), isTrue);
      expect((map['Devices'] as List).isEmpty, isTrue);
    });

    test('ExportTime 格式：UTC ISO8601 秒級', () {
      final map = jsonDecode(
        ScanExportService.buildJsonString(devices: [], scanTimes: {}),
      ) as Map<String, dynamic>;
      expect(_utcIsoRegex.hasMatch(map['ExportTime'] as String), isTrue);
    });

    test('單筆 device：輸出包含 Uid, EPC, ScanTime', () {
      final result = ScanExportService.buildJsonString(
        devices: [_sampleDevice],
        scanTimes: {_sampleDevice.uid: DateTime.utc(2026, 5, 22, 6, 29, 54)},
      );
      final d = ((jsonDecode(result) as Map)['Devices'] as List).first as Map;
      expect(d['Uid'], 'dev-001');
      expect(d['EPC'], 'E280AABBCCDD');
      expect(d.containsKey('ScanTime'), isTrue);
    });

    test('ScanTime 從 scanTimes map 取值', () {
      final result = ScanExportService.buildJsonString(
        devices: [_sampleDevice],
        scanTimes: {_sampleDevice.uid: DateTime.utc(2026, 1, 15, 8, 30, 0)},
      );
      final d = ((jsonDecode(result) as Map)['Devices'] as List).first as Map;
      expect(d['ScanTime'], '2026-01-15T08:30:00Z');
    });

    test('沒有對應 scanTime 時 fallback 為 ExportTime', () {
      final result = ScanExportService.buildJsonString(
        devices: [_sampleDevice],
        scanTimes: {},
      );
      final map = jsonDecode(result) as Map<String, dynamic>;
      final d = (map['Devices'] as List).first as Map;
      expect(d['ScanTime'], map['ExportTime']);
    });

    test('多筆 device → 各自獨立 ScanTime', () {
      const device2 = Device(
        uid: 'dev-002',
        serialCode: 'INS-002',
        label: '萬用表',
        registryId: 'ASSET-002',
        category: '測試組',
        epc: 'E280DDEEFF00',
      );
      final result = ScanExportService.buildJsonString(
        devices: [_sampleDevice, device2],
        scanTimes: {
          _sampleDevice.uid: DateTime.utc(2026, 5, 1, 10, 0, 0),
          device2.uid: DateTime.utc(2026, 5, 1, 10, 0, 5),
        },
      );
      final devices = ((jsonDecode(result) as Map)['Devices'] as List);
      expect((devices[0] as Map)['ScanTime'], '2026-05-01T10:00:00Z');
      expect((devices[1] as Map)['ScanTime'], '2026-05-01T10:00:05Z');
    });

    test('輸出是合法 JSON', () {
      expect(
        () => jsonDecode(ScanExportService.buildJsonString(
          devices: [_sampleDevice],
          scanTimes: {_sampleDevice.uid: DateTime.utc(2026, 3, 10, 12, 0, 0)},
        )),
        returnsNormally,
      );
    });

    test('ScanTime 格式也符合 UTC ISO8601 秒級', () {
      final result = ScanExportService.buildJsonString(
        devices: [_sampleDevice],
        scanTimes: {_sampleDevice.uid: DateTime.utc(2026, 12, 31, 23, 59, 59)},
      );
      final d = ((jsonDecode(result) as Map)['Devices'] as List).first as Map;
      expect(_utcIsoRegex.hasMatch(d['ScanTime'] as String), isTrue);
    });
  });
}
