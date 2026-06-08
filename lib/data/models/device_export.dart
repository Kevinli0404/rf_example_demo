import 'device.dart';

class DeviceExport {
  final DateTime exportTime;
  final List<Device> devices;

  const DeviceExport({required this.exportTime, required this.devices});

  factory DeviceExport.fromJson(Map<String, dynamic> json) {
    return DeviceExport(
      exportTime: DateTime.parse(json['ExportTime'] as String),
      devices: (json['Devices'] as List)
          .map((e) => Device.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
