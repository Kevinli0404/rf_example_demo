import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rf_example/data/models/device.dart';
import 'package:rf_example/data/repositories/device_repository.dart';
import 'package:rf_example/pages/scan_page/scan_session_controller.dart';

class MockDeviceRepository extends Fake implements DeviceRepository {
  final List<Device> _devices;
  final Device? _findByEpcResult;

  MockDeviceRepository(this._devices, {Device? findByEpcResult})
      : _findByEpcResult = findByEpcResult;

  @override
  Future<List<Device>> getAllDevices() async => List.of(_devices);

  @override
  Future<Device?> findByEpc(String epc) async => _findByEpcResult;
}

const _deviceA = Device(
  id: 'dev-001',
  instrumentNumber: 'INS-001',
  name: '頻譜分析儀',
  assetNumber: 'ASSET-001',
  unit: '量測組',
  epc: 'E280AABBCCDD',
);

const _deviceB = Device(
  id: 'dev-002',
  instrumentNumber: 'INS-002',
  name: '萬用表',
  assetNumber: 'ASSET-002',
  unit: '量測組',
  epc: 'E280001122',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('rfid_test/commands'),
      (call) async => null,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('rfid_test/commands'),
      null,
    );
  });

  group('ScanSessionController — 初始狀態', () {
    late ScanSessionController controller;

    setUp(() {
      controller = ScanSessionController(
        repository: MockDeviceRepository([]),
        isConnected: () => false,
      );
    });

    tearDown(() => controller.dispose());

    test('scanning 初始為 false', () {
      expect(controller.scanning, isFalse);
    });

    test('totalCount 初始為 0', () {
      expect(controller.totalCount, 0);
    });

    test('scannedDevices 初始為空', () {
      expect(controller.scannedDevices, isEmpty);
    });

    test('toggling 初始為 false', () {
      expect(controller.toggling, isFalse);
    });
  });

  group('ScanSessionController — toggleScan 未連線', () {
    late ScanSessionController controller;

    setUp(() {
      controller = ScanSessionController(
        repository: MockDeviceRepository([_deviceA]),
        isConnected: () => false,
      );
    });

    tearDown(() => controller.dispose());

    test('未連線時 toggleScan() 回傳非 null 錯誤字串', () async {
      final result = await controller.toggleScan();
      expect(result, isNotNull);
      expect(result, isA<String>());
      expect(result!.isNotEmpty, isTrue);
    });

    test('未連線時 scanning 仍為 false', () async {
      await controller.toggleScan();
      expect(controller.scanning, isFalse);
    });
  });

  group('ScanSessionController — toggleScan 已連線', () {
    late ScanSessionController controller;

    setUp(() {
      controller = ScanSessionController(
        repository: MockDeviceRepository([_deviceA, _deviceB]),
        isConnected: () => true,
      );
    });

    tearDown(() => controller.dispose());

    test('已連線且有設備：toggleScan() 後 scanning = true', () async {
      await controller.toggleScan();
      expect(controller.scanning, isTrue);
    });

    test('已連線且有設備：toggleScan() 回傳 null（無錯誤）', () async {
      final result = await controller.toggleScan();
      expect(result, isNull);
    });

    test('掃描中再次 toggleScan() → scanning = false（停止）', () async {
      await controller.toggleScan();
      expect(controller.scanning, isTrue);

      await controller.toggleScan();
      expect(controller.scanning, isFalse);
    });

    test('停止後 toggleScan() 回傳 null', () async {
      await controller.toggleScan();
      final result = await controller.toggleScan();
      expect(result, isNull);
    });
  });

  group('ScanSessionController — clearAll', () {
    late ScanSessionController controller;

    setUp(() {
      controller = ScanSessionController(
        repository: MockDeviceRepository([_deviceA]),
        isConnected: () => true,
      );
    });

    tearDown(() => controller.dispose());

    test('clearAll() 清空 scannedDevices', () async {
      controller.addManualDevice(_deviceA);
      expect(controller.scannedDevices.length, 1);

      controller.clearAll();
      expect(controller.scannedDevices, isEmpty);
    });

    test('clearAll() 清空 scanTimes', () {
      controller.addManualDevice(_deviceA);
      controller.clearAll();
      expect(controller.scanTimes, isEmpty);
    });

    test('clearAll() 後 totalCount 歸零', () {
      controller.addManualDevice(_deviceA);
      controller.clearAll();
      expect(controller.totalCount, 0);
    });

    test('clearAll() 後可再次加入同 EPC 的設備', () {
      controller.addManualDevice(_deviceA);
      controller.clearAll();
      controller.addManualDevice(_deviceA);
      expect(controller.totalCount, 1);
    });
  });

  group('ScanSessionController — addManualDevice', () {
    late ScanSessionController controller;

    setUp(() {
      controller = ScanSessionController(
        repository: MockDeviceRepository([]),
        isConnected: () => false,
      );
    });

    tearDown(() => controller.dispose());

    test('addManualDevice() 加入設備', () {
      controller.addManualDevice(_deviceA);
      expect(controller.scannedDevices.length, 1);
      expect(controller.scannedDevices.first.id, 'dev-001');
    });

    test('重複 EPC 不加第二次', () {
      controller.addManualDevice(_deviceA);
      controller.addManualDevice(_deviceA); // 同一個 device
      expect(controller.scannedDevices.length, 1);
    });

    test('不同 EPC 的設備可以都加入', () {
      controller.addManualDevice(_deviceA);
      controller.addManualDevice(_deviceB);
      expect(controller.scannedDevices.length, 2);
    });

    test('addManualDevice() 後 totalCount 增加', () {
      expect(controller.totalCount, 0);
      controller.addManualDevice(_deviceA);
      expect(controller.totalCount, 1);
    });

    test('addManualDevice() 後 scanTimes 有該 device 的時間', () {
      controller.addManualDevice(_deviceA);
      expect(controller.scanTimes.containsKey(_deviceA.id), isTrue);
    });

    test('EPC 大小寫視為相同（去重）', () {
      const deviceLower = Device(
        id: 'dev-999',
        instrumentNumber: 'INS-999',
        name: '重複設備',
        assetNumber: 'ASSET-999',
        unit: '測試組',
        epc: 'e280aabbccdd',
      );
      controller.addManualDevice(_deviceA);
      controller.addManualDevice(deviceLower);
      expect(controller.scannedDevices.length, 1);
    });

    test('addManualDevice() 後 scannedDevices 是不可修改的 List', () {
      controller.addManualDevice(_deviceA);
      expect(
        () => (controller.scannedDevices as List).add(_deviceB),
        throwsUnsupportedError,
      );
    });
  });

  group('ScanSessionController — dispose', () {
    test('dispose() 不 crash', () {
      final controller = ScanSessionController(
        repository: MockDeviceRepository([]),
        isConnected: () => false,
      );
      expect(() => controller.dispose(), returnsNormally);
    });

    test('掃描中 dispose() 也不 crash', () async {
      final controller = ScanSessionController(
        repository: MockDeviceRepository([_deviceA, _deviceB]),
        isConnected: () => true,
      );
      await controller.toggleScan();
      expect(() => controller.dispose(), returnsNormally);
    });
  });
}
