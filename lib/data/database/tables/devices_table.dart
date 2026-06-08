import 'package:drift/drift.dart';

@DataClassName('DeviceEntity')
class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get instrumentNumber => text()();
  TextColumn get name => text()();
  TextColumn get assetNumber => text()();
  TextColumn get unit => text()();
  TextColumn get epc => text()();

  @override
  Set<Column> get primaryKey => {id};
}
