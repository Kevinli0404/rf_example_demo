import '../database/app_database.dart';

class Device {
  final String uid;
  final String serialCode;
  final String label;
  final String registryId;
  final String category;
  final String epc;

  const Device({
    required this.uid,
    required this.serialCode,
    required this.label,
    required this.registryId,
    required this.category,
    required this.epc,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      uid: json['Uid'] as String,
      serialCode: json['SerialCode'] as String,
      label: json['Label'] as String,
      registryId: json['RegistryId'] as String,
      category: json['Category'] as String,
      epc: (json['EPC'] as String).toUpperCase(),
    );
  }

  factory Device.fromEntity(DeviceEntity entity) {
    return Device(
      uid: entity.uid,
      serialCode: entity.serialCode,
      label: entity.label,
      registryId: entity.registryId,
      category: entity.category,
      epc: entity.epc,
    );
  }

  DevicesCompanion toCompanion() {
    return DevicesCompanion.insert(
      uid: uid,
      serialCode: serialCode,
      label: label,
      registryId: registryId,
      category: category,
      epc: epc,
    );
  }

  @override
  String toString() => 'Device(uid: $uid, label: $label)';
}
