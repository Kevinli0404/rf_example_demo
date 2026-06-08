import '../database/app_database.dart';

class Device {
  final String id;
  final String instrumentNumber;
  final String name;
  final String assetNumber;
  final String unit;
  final String epc;

  const Device({
    required this.id,
    required this.instrumentNumber,
    required this.name,
    required this.assetNumber,
    required this.unit,
    required this.epc,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['Id'] as String,
      instrumentNumber: json['InstrumentNumber'] as String,
      name: json['Name'] as String,
      assetNumber: json['AssetNumber'] as String,
      unit: json['Unit'] as String,
      epc: (json['EPC'] as String).toUpperCase(),
    );
  }

  factory Device.fromEntity(DeviceEntity entity) {
    return Device(
      id: entity.id,
      instrumentNumber: entity.instrumentNumber,
      name: entity.name,
      assetNumber: entity.assetNumber,
      unit: entity.unit,
      epc: entity.epc,
    );
  }

  DevicesCompanion toCompanion() {
    return DevicesCompanion.insert(
      id: id,
      instrumentNumber: instrumentNumber,
      name: name,
      assetNumber: assetNumber,
      unit: unit,
      epc: epc,
    );
  }

  @override
  String toString() => 'Device(id: $id, name: $name)';
}
