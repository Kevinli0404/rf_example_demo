import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rf_example/providers/app_providers.dart';
import '../data/models/device.dart';
import '../data/repositories/device_repository.dart';

class DeviceListState {
  final List<Device> devices;
  final DateTime? exportTime;
  final bool isImporting;
  final String? errorMessage;
  final int? lastImportedCount;

  const DeviceListState({
    this.devices = const [],
    this.exportTime,
    this.isImporting = false,
    this.errorMessage,
    this.lastImportedCount,
  });

  DeviceListState copyWith({
    List<Device>? devices,
    DateTime? exportTime,
    bool? isImporting,
    String? errorMessage,
    int? lastImportedCount,
    bool clearError = false,
    bool clearLastImportedCount = false,
  }) {
    return DeviceListState(
      devices: devices ?? this.devices,
      exportTime: exportTime ?? this.exportTime,
      isImporting: isImporting ?? this.isImporting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastImportedCount: clearLastImportedCount
          ? null
          : (lastImportedCount ?? this.lastImportedCount),
    );
  }
}

class DeviceListViewModel extends Notifier<DeviceListState> {
  late final DeviceRepository _repository;

  @override
  DeviceListState build() {
    _repository = ref.read(deviceRepositoryProvider);

    final initialDevices =
        ref.read(devicesStreamProvider).value ?? const <Device>[];
    final initialExportTime = ref.read(exportTimeStreamProvider).value;

    ref.listen(devicesStreamProvider, (_, next) {
      next.whenData((devices) => state = state.copyWith(devices: devices));
    });
    ref.listen(exportTimeStreamProvider, (_, next) {
      next.whenData((time) => state = state.copyWith(exportTime: time));
    });

    return DeviceListState(
      devices: initialDevices,
      exportTime: initialExportTime,
    );
  }

  Future<void> importFromJson(String jsonString) async {
    state = state.copyWith(isImporting: true, clearError: true);
    try {
      await _repository.importFromJsonString(jsonString);
      state = state.copyWith(isImporting: false);
    } catch (e) {
      state = state.copyWith(isImporting: false, errorMessage: '匯入失敗: $e');
    }
  }

  Future<ImportOutcome> importFromFile(File file) async {
    state = state.copyWith(
      isImporting: true,
      clearError: true,
      clearLastImportedCount: true,
    );
    final outcome = await _repository.importFromFile(file);
    _applyImportOutcome(outcome);
    return outcome;
  }

  void _applyImportOutcome(ImportOutcome outcome) {
    if (outcome.isSuccess) {
      state = state.copyWith(
        isImporting: false,
        lastImportedCount: outcome.importedCount,
      );
    } else if (outcome.isError) {
      state = state.copyWith(
        isImporting: false,
        errorMessage: outcome.errorMessage,
      );
    } else {
      state = state.copyWith(isImporting: false);
    }
  }

  Future<void> clearAll() async {
    state = state.copyWith(
      isImporting: true,
      clearError: true,
      clearLastImportedCount: true,
    );
    try {
      await _repository.clearAll();
      state = state.copyWith(isImporting: false);
    } catch (e) {
      state = state.copyWith(isImporting: false, errorMessage: '清空失敗: $e');
    }
  }
}
