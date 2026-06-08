import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rf_example/data/services/scan_file_service.dart';

Future<File> _writeValidScanFile(Directory dir, String filename) async {
  final file = File('${dir.path}/$filename');
  await file.writeAsString(
    jsonEncode({
      'ExportTime': '2026-05-01T10:00:00Z',
      'Devices': [
        {
          'Id': 'dev-001',
          'EPC': 'E280AABBCCDD',
          'ScanTime': '2026-05-01T09:59:00Z',
        },
      ],
    }),
  );
  return file;
}

Future<File> _writeInvalidScanFile(Directory dir, String filename) async {
  final file = File('${dir.path}/$filename');
  await file.writeAsString('this is not JSON');
  return file;
}

Future<File> _writeMissingFieldFile(Directory dir, String filename) async {
  final file = File('${dir.path}/$filename');
  await file.writeAsString(
    jsonEncode({
      'ExportTime': '2026-05-01T10:00:00Z',
      'Devices': [
        {'Id': 'dev-001', 'EPC': 'E280AABBCCDD'},
      ],
    }),
  );
  return file;
}

void main() {
  group('ScanFileService.renameScanFile', () {
    late Directory tempDir;
    late ScanFileService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('scan_file_test_');
      service = ScanFileService();
    });

    tearDown(() async {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('正常改名：舊路徑消失，新路徑存在', () async {
      final original = await _writeValidScanFile(
        tempDir,
        '2026-05-01_100000.txt',
      );
      final renamed = await service.renameScanFile(
        file: original,
        newDisplayName: 'renamed_file',
      );
      expect(await renamed.exists(), isTrue);
      expect(renamed.path, endsWith('renamed_file.txt'));
      expect(await original.exists(), isFalse);
    });

    test('已有 .txt 副檔名 → 不重複加', () async {
      final original = await _writeValidScanFile(
        tempDir,
        '2026-05-01_100001.txt',
      );
      final renamed = await service.renameScanFile(
        file: original,
        newDisplayName: 'already_has_ext.txt',
      );
      expect(renamed.path, endsWith('already_has_ext.txt'));
      expect(renamed.path, isNot(endsWith('.txt.txt')));
    });

    test('前後空白 → 自動 trim', () async {
      final original = await _writeValidScanFile(
        tempDir,
        '2026-05-01_100002.txt',
      );
      final renamed = await service.renameScanFile(
        file: original,
        newDisplayName: '  trimmed  ',
      );
      expect(renamed.path, endsWith('trimmed.txt'));
    });

    test('空字串 → ScanFileNameException(empty)', () async {
      final original = await _writeValidScanFile(
        tempDir,
        '2026-05-01_100003.txt',
      );
      await expectLater(
        service.renameScanFile(file: original, newDisplayName: ''),
        throwsA(
          isA<ScanFileNameException>().having(
            (e) => e.error,
            'error',
            ScanFileNameError.empty,
          ),
        ),
      );
    });

    test('純空白字串 → ScanFileNameException(empty)', () async {
      final original = await _writeValidScanFile(
        tempDir,
        '2026-05-01_100004.txt',
      );
      await expectLater(
        service.renameScanFile(file: original, newDisplayName: '   '),
        throwsA(isA<ScanFileNameException>()),
      );
    });

    test('非法字元 → ScanFileNameException(invalidChar)', () async {
      final original = await _writeValidScanFile(
        tempDir,
        '2026-05-01_100004b.txt',
      );
      await expectLater(
        service.renameScanFile(file: original, newDisplayName: 'bad/name'),
        throwsA(
          isA<ScanFileNameException>().having(
            (e) => e.error,
            'error',
            ScanFileNameError.invalidChar,
          ),
        ),
      );
    });

    test('同名已存在 → ScanFileNameException(duplicate)', () async {
      final original = await _writeValidScanFile(
        tempDir,
        '2026-05-01_100005.txt',
      );
      await File('${tempDir.path}/conflict.txt').writeAsString('existing');
      await expectLater(
        service.renameScanFile(file: original, newDisplayName: 'conflict'),
        throwsA(
          isA<ScanFileNameException>().having(
            (e) => e.error,
            'error',
            ScanFileNameError.duplicate,
          ),
        ),
      );
    });

    test('改名與原始名相同 → 回傳原 File，不 throw', () async {
      final original = await _writeValidScanFile(
        tempDir,
        '2026-05-01_100006.txt',
      );
      final result = await service.renameScanFile(
        file: original,
        newDisplayName: '2026-05-01_100006',
      );
      expect(result.path, original.path);
      expect(await result.exists(), isTrue);
    });
  });

  group('ScanFileService.deleteScanFile', () {
    late Directory tempDir;
    late ScanFileService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('scan_delete_test_');
      service = ScanFileService();
    });

    tearDown(() async {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('存在的檔案 → 刪除後不存在', () async {
      final file = await _writeValidScanFile(tempDir, 'to_delete.txt');
      await service.deleteScanFile(file);
      expect(await file.exists(), isFalse);
    });

    test('不存在的檔案 → 不拋出例外', () async {
      final ghost = File('${tempDir.path}/ghost.txt');
      expect(() => service.deleteScanFile(ghost), returnsNormally);
    });
  });

  group('掃描檔 JSON 格式驗證', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('scan_parse_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('合法格式：包含必要欄位 ExportTime / Devices[].Id/EPC/ScanTime', () async {
      final file = await _writeValidScanFile(tempDir, 'valid.txt');
      final raw = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      expect(raw.containsKey('ExportTime'), isTrue);
      expect(raw['Devices'], isA<List>());
      final d = (raw['Devices'] as List).first as Map;
      expect(d['Id'], isNotNull);
      expect(d['EPC'], isNotNull);
      expect(d['ScanTime'], isNotNull);
    });

    test('非 JSON 內容 → jsonDecode 拋出 FormatException', () async {
      final file = await _writeInvalidScanFile(tempDir, 'invalid.txt');
      expect(
        () async => jsonDecode(await file.readAsString()),
        throwsA(isA<FormatException>()),
      );
    });

    test('缺少 ScanTime 欄位 → 欄位值為 null', () async {
      final file = await _writeMissingFieldFile(tempDir, 'missing.txt');
      final raw = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final d = (raw['Devices'] as List).first as Map;
      expect(d['ScanTime'], isNull);
    });

    test('displayName 去除 .txt 後綴', () {
      const filename = '2026-05-01_123456.txt';
      final display = filename.toLowerCase().endsWith('.txt')
          ? filename.substring(0, filename.length - 4)
          : filename;
      expect(display, '2026-05-01_123456');
    });

    test('合法 ExportTime → DateTime.tryParse 回傳 UTC 時間', () {
      final parsed = DateTime.tryParse('2026-05-01T10:00:00Z');
      expect(parsed, isNotNull);
      expect(parsed!.isUtc, isTrue);
    });

    test('非法 ExportTime → DateTime.tryParse 回傳 null', () {
      expect(DateTime.tryParse('not-a-date'), isNull);
    });
  });
}
