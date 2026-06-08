import 'package:flutter_test/flutter_test.dart';
import 'package:rf_example/core/epc_rules.dart';

void main() {
  group('isUnknownDeviceId', () {
    test('id 以 __unknown_ 開頭 → true', () {
      expect(isUnknownDeviceId('__unknown_1'), isTrue);
      expect(isUnknownDeviceId('__unknown_42'), isTrue);
      expect(isUnknownDeviceId('__unknown_'), isTrue);
    });

    test('一般 id → false', () {
      expect(isUnknownDeviceId('device-001'), isFalse);
      expect(isUnknownDeviceId('ABC123'), isFalse);
      expect(isUnknownDeviceId('unknown_1'), isFalse); // 少前面兩個底線
    });

    test('空字串 → false', () {
      expect(isUnknownDeviceId(''), isFalse);
    });

    test('只有前綴常數本身 → true', () {
      expect(isUnknownDeviceId(kUnknownDeviceIdPrefix), isTrue);
    });
  });

  group('EpcRules.matches', () {
    test('空 prefixes → 永遠 false', () {
      const rules = EpcRules.empty;
      expect(rules.matches('E280AABBCC'), isFalse);
      expect(rules.matches(''), isFalse);
    });

    test('EPC 大小寫不分匹配前綴', () {
      const rules = EpcRules(['E280', '1234']);
      expect(rules.matches('e280aabbcc'), isTrue); // 小寫也匹配
      expect(rules.matches('E280AABBCC'), isTrue);
      expect(rules.matches('1234567890'), isTrue);
      expect(rules.matches('FFFF000000'), isFalse);
    });

    test('defaults 包含 E280 / 1234 / 5741', () {
      expect(EpcRules.defaults.matches('E280112233'), isTrue);
      expect(EpcRules.defaults.matches('1234ABCDEF'), isTrue);
      expect(EpcRules.defaults.matches('5741001122'), isTrue);
      expect(EpcRules.defaults.matches('DEADBEEF00'), isFalse);
    });
  });

  group('EpcRules.fromString', () {
    test('null → empty', () {
      expect(EpcRules.fromString(null).prefixes, isEmpty);
    });

    test('空字串 → empty', () {
      expect(EpcRules.fromString('').prefixes, isEmpty);
      expect(EpcRules.fromString('   ').prefixes, isEmpty);
    });

    test('逗號分隔', () {
      final rules = EpcRules.fromString('E280,1234,5741');
      expect(rules.prefixes, containsAll(['E280', '1234', '5741']));
    });

    test('換行分隔', () {
      final rules = EpcRules.fromString('E280\n1234\n5741');
      expect(rules.prefixes, containsAll(['E280', '1234', '5741']));
    });

    test('自動轉大寫', () {
      final rules = EpcRules.fromString('e280,abcd');
      expect(rules.prefixes, containsAll(['E280', 'ABCD']));
    });

    test('過濾空項目', () {
      final rules = EpcRules.fromString('E280,,1234');
      expect(rules.prefixes.length, 2);
    });
  });

  group('EpcRules.toStorageString', () {
    test('以換行連接所有前綴', () {
      const rules = EpcRules(['E280', '1234']);
      expect(rules.toStorageString(), 'E280\n1234');
    });

    test('empty → 空字串', () {
      expect(EpcRules.empty.toStorageString(), '');
    });
  });
}
