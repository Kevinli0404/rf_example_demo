import 'package:drift/drift.dart';

@DataClassName('MetadataEntity')
class Metadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
