import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/devices_table.dart';
import 'tables/metadata_table.dart';

part 'app_database.g.dart';

class MetadataKeys {
  static const exportTime = 'export_time';
  static const epcPrefixRules = 'epc_prefix_rules';
}

@DriftDatabase(tables: [Devices, Metadata])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // Column names changed in v2; drop and recreate devices table.
          // No user data is preserved — devices are re-imported from JSON.
          await m.drop(devices);
          await m.createTable(devices);
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'rf_example_db');
  }

  Stream<List<DeviceEntity>> watchAllDevices() => select(devices).watch();

  Future<List<DeviceEntity>> getAllDevices() => select(devices).get();

  Future<DeviceEntity?> findDeviceByEpc(String epc) {
    return (select(devices)..where((d) => d.epc.equals(epc.toUpperCase())))
        .getSingleOrNull();
  }

  Future<int> countDevices() async {
    final count = countAll();
    final query = selectOnly(devices)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<void> replaceAllDevices({
    required List<DevicesCompanion> newDevices,
    required DateTime exportTime,
  }) async {
    await transaction(() async {
      await delete(devices).go();
      await batch((b) => b.insertAll(devices, newDevices));
      await into(metadata).insertOnConflictUpdate(
        MetadataCompanion.insert(
          key: MetadataKeys.exportTime,
          value: exportTime.toIso8601String(),
        ),
      );
    });
  }

  Future<void> clearAllDevices() async {
    await transaction(() async {
      await delete(devices).go();
      await (delete(metadata)
            ..where((m) => m.key.equals(MetadataKeys.exportTime)))
          .go();
    });
  }

  Future<DateTime?> getExportTime() async {
    final row = await (select(metadata)
          ..where((m) => m.key.equals(MetadataKeys.exportTime)))
        .getSingleOrNull();
    return row == null ? null : DateTime.tryParse(row.value);
  }

  Stream<DateTime?> watchExportTime() {
    return (select(metadata)
          ..where((m) => m.key.equals(MetadataKeys.exportTime)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : DateTime.tryParse(row.value));
  }

  Future<String?> getEpcPrefixRulesRaw() async {
    final row = await (select(metadata)
          ..where((m) => m.key.equals(MetadataKeys.epcPrefixRules)))
        .getSingleOrNull();
    return row?.value;
  }

  Stream<String?> watchEpcPrefixRulesRaw() {
    return (select(metadata)
          ..where((m) => m.key.equals(MetadataKeys.epcPrefixRules)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  Future<void> setEpcPrefixRulesRaw(String value) async {
    await into(metadata).insertOnConflictUpdate(
      MetadataCompanion.insert(key: MetadataKeys.epcPrefixRules, value: value),
    );
  }
}
