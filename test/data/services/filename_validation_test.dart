import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rf_example/data/services/scan_file_service.dart';

void main() {
  group('validateFileName — 空白檢查', () {
    test('空字串 → empty', () {
      expect(
        () => validateFileName(''),
        throwsA(isA<ScanFileNameException>()
            .having((e) => e.error, 'error', ScanFileNameError.empty)),
      );
    });

    test('純空白字串 → empty', () {
      expect(() => validateFileName('   '), throwsA(isA<ScanFileNameException>()));
    });

    test('前後有空白 → trim 後通過，回傳 trimmed 字串', () {
      expect(validateFileName('  hello  '), 'hello');
    });
  });

  group('validateFileName — 非法字元', () {
    final illegalChars = ['/', '\\', ':', '*', '?', '"', '<', '>', '|'];

    for (final ch in illegalChars) {
      test('包含 "$ch" → invalidChar', () {
        expect(
          () => validateFileName('file${ch}name'),
          throwsA(isA<ScanFileNameException>().having(
            (e) => e.error, 'error', ScanFileNameError.invalidChar,
          )),
        );
      });
    }

    test('字母數字底線連字號 → 通過', () {
      expect(validateFileName('2026-05-01_scan_001'), '2026-05-01_scan_001');
    });

    test('中文 → 通過', () {
      expect(validateFileName('掃描結果'), '掃描結果');
    });

    test('非首尾空格 → 通過', () {
      expect(validateFileName('scan result'), 'scan result');
    });
  });

  group('ScanFileNameException.message', () {
    test('四種錯誤各有不同的訊息', () {
      final messages = ScanFileNameError.values
          .map((e) => ScanFileNameException(e).message)
          .toList();
      expect(messages.toSet().length, ScanFileNameError.values.length);
    });

    test('每種訊息都非空', () {
      for (final error in ScanFileNameError.values) {
        expect(ScanFileNameException(error).message.isNotEmpty, isTrue);
      }
    });
  });

  group('ScanFileService.validateRenameFilename', () {
    late Directory tempDir;
    late ScanFileService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('rename_validate_');
      service = ScanFileService();
    });

    tearDown(() async {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    Future<File> makeFile(String name) async {
      final f = File('${tempDir.path}/$name');
      await f.writeAsString('{}');
      return f;
    }

    test('合法且無衝突 → null', () async {
      final current = await makeFile('original.txt');
      expect(await service.validateRenameFilename('new_name', current), isNull);
    });

    test('空字串 → 非 null 錯誤訊息', () async {
      final current = await makeFile('original2.txt');
      final result = await service.validateRenameFilename('', current);
      expect(result, isNotNull);
      expect(result!.isNotEmpty, isTrue);
    });

    test('含非法字元 → 非 null', () async {
      final current = await makeFile('original3.txt');
      expect(
        await service.validateRenameFilename('bad/name', current),
        isNotNull,
      );
    });

    test('與其他檔案同名 → 非 null', () async {
      final current = await makeFile('current.txt');
      await makeFile('taken.txt');
      expect(
        await service.validateRenameFilename('taken', current),
        isNotNull,
      );
    });

    test('與自己同名 → null（不視為衝突）', () async {
      final current = await makeFile('self.txt');
      expect(await service.validateRenameFilename('self', current), isNull);
    });

    test('新名稱帶 .txt 副檔名仍偵測到衝突', () async {
      final current = await makeFile('current2.txt');
      await makeFile('conflict2.txt');
      expect(
        await service.validateRenameFilename('conflict2.txt', current),
        isNotNull,
      );
    });

    test('通過時回傳 null 而非空字串', () async {
      final current = await makeFile('pass_test.txt');
      expect(
        await service.validateRenameFilename('valid_name', current),
        isNull,
      );
    });
  });
}
