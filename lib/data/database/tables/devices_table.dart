import 'package:drift/drift.dart';

@DataClassName('DeviceEntity')
class Devices extends Table {
  TextColumn get uid => text()();
  TextColumn get serialCode => text()();
  TextColumn get label => text()();
  TextColumn get registryId => text()();
  TextColumn get category => text()();
  TextColumn get epc => text()();

  @override
  Set<Column> get primaryKey => {uid};
}
