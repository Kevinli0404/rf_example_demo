import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/epc_rules.dart';
import '../data/database/app_database.dart';
import '../data/models/device.dart';
import '../data/repositories/device_repository.dart';
import '../viewmodels/device_list_viewmodel.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepository(ref.watch(appDatabaseProvider));
});

final devicesStreamProvider = StreamProvider<List<Device>>((ref) {
  return ref.watch(deviceRepositoryProvider).watchAllDevices();
});

final exportTimeStreamProvider = StreamProvider<DateTime?>((ref) {
  return ref.watch(deviceRepositoryProvider).watchExportTime();
});

final epcRulesProvider = StreamProvider<EpcRules>((ref) {
  return ref.watch(deviceRepositoryProvider).watchEpcRules();
});

final deviceListViewModelProvider =
    NotifierProvider<DeviceListViewModel, DeviceListState>(
      DeviceListViewModel.new,
    );
