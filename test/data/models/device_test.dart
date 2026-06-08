import 'package:flutter_test/flutter_test.dart';
import 'package:rf_example/data/models/device.dart';

void main() {
  group('Device.fromJson', () {
    const validJson = {
      'Id': 'device-001',
      'InstrumentNumber': 'INS-999',
      'Name': '示波器',
      'AssetNumber': 'ASSET-123',
      'Unit': '量測組',
      'EPC': 'e280aabbccdd',
    };

    test('正常 JSON → 所有欄位正確', () {
      final device = Device.fromJson(validJson);

      expect(device.id, 'device-001');
      expect(device.instrumentNumber, 'INS-999');
      expect(device.name, '示波器');
      expect(device.assetNumber, 'ASSET-123');
      expect(device.unit, '量測組');
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

    test('缺少必要欄位（Id）→ 拋出例外', () {
      final json = Map<String, dynamic>.from(validJson)..remove('Id');
      expect(() => Device.fromJson(json), throwsA(anything));
    });

    test('缺少必要欄位（EPC）→ 拋出例外', () {
      final json = Map<String, dynamic>.from(validJson)..remove('EPC');
      expect(() => Device.fromJson(json), throwsA(anything));
    });

    test('toString 含 id 與 name', () {
      final device = Device.fromJson(validJson);
      expect(device.toString(), contains('device-001'));
      expect(device.toString(), contains('示波器'));
    });
  });
}
