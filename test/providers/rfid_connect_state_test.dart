import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rf_example/providers/rfid_providers.dart';

void main() {
  group('RfidConnectState.fromString', () {
    test('"Connected" → connected', () {
      expect(
        RfidConnectState.fromString('Connected'),
        RfidConnectState.connected,
      );
    });

    test('"Disconnected" → disconnected', () {
      expect(
        RfidConnectState.fromString('Disconnected'),
        RfidConnectState.disconnected,
      );
    });

    test('"Connecting" → connecting', () {
      expect(
        RfidConnectState.fromString('Connecting'),
        RfidConnectState.connecting,
      );
    });

    test('未知字串 → unknown', () {
      expect(
        RfidConnectState.fromString('unknown_string'),
        RfidConnectState.unknown,
      );
    });

    test('空字串 → unknown', () {
      expect(
        RfidConnectState.fromString(''),
        RfidConnectState.unknown,
      );
    });

    test('大小寫不符（connected 小寫）→ unknown', () {
      // fromString 是 exact match
      expect(
        RfidConnectState.fromString('connected'),
        RfidConnectState.unknown,
      );
    });
  });

  group('RfidConnectState.isConnected', () {
    test('connected → isConnected = true', () {
      expect(RfidConnectState.connected.isConnected, isTrue);
    });

    test('disconnected → isConnected = false', () {
      expect(RfidConnectState.disconnected.isConnected, isFalse);
    });

    test('connecting → isConnected = false', () {
      expect(RfidConnectState.connecting.isConnected, isFalse);
    });

    test('unknown → isConnected = false', () {
      expect(RfidConnectState.unknown.isConnected, isFalse);
    });
  });

  group('RfidConnectState.label', () {
    test('connected label 非空', () {
      expect(RfidConnectState.connected.label.isNotEmpty, isTrue);
    });

    test('disconnected label 非空', () {
      expect(RfidConnectState.disconnected.label.isNotEmpty, isTrue);
    });

    test('connecting label 非空', () {
      expect(RfidConnectState.connecting.label.isNotEmpty, isTrue);
    });

    test('unknown label 非空', () {
      expect(RfidConnectState.unknown.label.isNotEmpty, isTrue);
    });

    test('四個 label 都不同（避免 copy-paste 錯誤）', () {
      final labels = [
        RfidConnectState.connected.label,
        RfidConnectState.disconnected.label,
        RfidConnectState.connecting.label,
        RfidConnectState.unknown.label,
      ];
      expect(labels.toSet().length, 4, reason: '每個 label 應該不同');
    });

    test('connected label 是「已連線」', () {
      expect(RfidConnectState.connected.label, '已連線');
    });

    test('disconnected label 是「未連線」', () {
      expect(RfidConnectState.disconnected.label, '未連線');
    });

    test('connecting label 是「連線中」', () {
      expect(RfidConnectState.connecting.label, '連線中');
    });

    test('unknown label 是「未知」', () {
      expect(RfidConnectState.unknown.label, '未知');
    });
  });

  group('RfidConnectState.color', () {
    test('connected color 非 null', () {
      expect(RfidConnectState.connected.color, isA<Color>());
    });

    test('disconnected color 非 null', () {
      expect(RfidConnectState.disconnected.color, isA<Color>());
    });

    test('connecting color 非 null', () {
      expect(RfidConnectState.connecting.color, isA<Color>());
    });

    test('unknown color 非 null', () {
      expect(RfidConnectState.unknown.color, isA<Color>());
    });

    test('四個 color 都不同（視覺上能區分）', () {
      final colors = [
        RfidConnectState.connected.color,
        RfidConnectState.disconnected.color,
        RfidConnectState.connecting.color,
        RfidConnectState.unknown.color,
      ];
      expect(colors.toSet().length, 4, reason: '每個狀態應有不同的 color');
    });

    test('connected color 是綠色（AppColors.green）', () {
      // 0xFF00A63E
      expect(RfidConnectState.connected.color, const Color(0xFF00A63E));
    });

    test('disconnected color 是紅色（AppColors.delete）', () {
      // 0xFFFF4D4F
      expect(RfidConnectState.disconnected.color, const Color(0xFFFF4D4F));
    });

    test('connecting color 是藍色（AppColors.info）', () {
      // 0xFF1890FF
      expect(RfidConnectState.connecting.color, const Color(0xFF1890FF));
    });

    test('unknown color 是灰色（AppColors.midGrey）', () {
      // 0xFFCCCCCC
      expect(RfidConnectState.unknown.color, const Color(0xFFCCCCCC));
    });
  });
}
