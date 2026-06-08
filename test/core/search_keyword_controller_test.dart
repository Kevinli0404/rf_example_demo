import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rf_example/core/search_keyword_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SearchKeywordController', () {
    late SearchKeywordController controller;

    setUp(() => controller = SearchKeywordController());
    tearDown(() => controller.dispose());

    test('初始 keyword 為空字串', () {
      expect(controller.keyword, '');
    });

    test('初始 hasKeyword 為 false', () {
      expect(controller.hasKeyword, isFalse);
    });

    test('輸入文字後 keyword 更新、hasKeyword 為 true', () {
      controller.textController.text = 'hello';
      expect(controller.keyword, 'hello');
      expect(controller.hasKeyword, isTrue);
    });

    test('首尾空白自動 trim', () {
      controller.textController.text = '  hello  ';
      expect(controller.keyword, 'hello');
    });

    test('文字變更觸發 notifyListeners', () {
      int count = 0;
      controller.addListener(() => count++);
      controller.textController.text = 'abc';
      expect(count, greaterThan(0));
    });

    test('只移動游標不觸發 rebuild', () {
      controller.textController.text = 'abc';
      int count = 0;
      controller.addListener(() => count++);
      controller.textController.selection =
          const TextSelection.collapsed(offset: 1);
      expect(count, 0);
    });

    test('clear() 後 keyword 歸空、hasKeyword 為 false', () {
      controller.textController.text = 'search';
      controller.clear();
      expect(controller.keyword, '');
      expect(controller.hasKeyword, isFalse);
    });

    test('matchesAny：空 keyword → 永遠 true', () {
      expect(controller.matchesAny(['anything']), isTrue);
      expect(controller.matchesAny([]), isTrue);
    });

    test('matchesAny：大小寫不分', () {
      controller.textController.text = 'HELLO';
      expect(controller.matchesAny(['hello world']), isTrue);
    });

    test('matchesAny：子字串命中', () {
      controller.textController.text = 'lo';
      expect(controller.matchesAny(['hello']), isTrue);
    });

    test('matchesAny：任一欄位命中即 true', () {
      controller.textController.text = 'xyz';
      expect(controller.matchesAny(['abc', 'xyz-device']), isTrue);
    });

    test('matchesAny：全部不匹配 → false', () {
      controller.textController.text = 'zzz';
      expect(controller.matchesAny(['abc', 'def']), isFalse);
    });

    test('IME 組字中（not collapsed）不更新 keyword', () {
      controller.textController.text = 'before';
      controller.textController.value = const TextEditingValue(
        text: '組字中',
        composing: TextRange(start: 0, end: 3),
      );
      expect(controller.keyword, 'before');
    });

    test('IME 組字結束（collapsed）後更新 keyword', () {
      controller.textController.value = const TextEditingValue(
        text: '確認文字',
        composing: TextRange.empty,
      );
      expect(controller.keyword, '確認文字');
    });
  });
}
