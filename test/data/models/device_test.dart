import 'package:flutter_test/flutter_test.dart';
import 'package:rf_example/data/models/device.dart';

void main() {
  group('Device.fromJson', () {
    const validJson = {
      'Uid': 'device-001',
      'SerialCode': 'INS-999',
      'Label': '示波器',
      'RegistryId': 'ASSET-123',
      'Category': '量測組',
      'EPC': 'e280aabbccdd',
    };

    test('正常 JSON → 所有欄位正確', () {
      final device = Device.fromJson(validJson);

      expect(device.uid, 'device-001');
      expect(device.serialCode, 'INS-999');
      expect(device.label, '示波器');
      expect(device.registryId, 'ASSET-123');
      expect(device.category, '量測組');
    });

    test('EPC 自動轉大寫', () {
      final device = Device.fromJson(validJson);
      expect(device.epc, 'E280AABBCCDD');
    });

    test('EPC 已是大寫維持不變', () {
      final json = Map<String, dynamic>.from(validJson)
        ..['EPC'] = 'E280001122';
      final device = Device.fromJson(json);
      expect(device.epc, 'E280001122');
    });

    test('EPC 混合大小寫全轉大寫', () {
      final json = Map<String, dynamic>.from(validJson)
        ..['EPC'] = 'e280AbCdEf';
      final device = Device.fromJson(json);
      expect(device.epc, 'E280ABCDEF');
    });

    test('缺少必要欄位（Uid）→ 拋出例外', () {
      final json = Map<String, dynamic>.from(validJson)..remove('Uid');
      expect(() => Device.fromJson(json), throwsA(anything));
    });

    test('缺少必要欄位（EPC）→ 拋出例外', () {
      final json = Map<String, dynamic>.from(validJson)..remove('EPC');
      expect(() => Device.fromJson(json), throwsA(anything));
    });

    test('toString 含 uid 與 label', () {
      final device = Device.fromJson(validJson);
      expect(device.toString(), contains('device-001'));
      expect(device.toString(), contains('示波器'));
    });
  });
}
