// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DevicesTable extends Devices
    with TableInfo<$DevicesTable, DeviceEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instrumentNumberMeta = const VerificationMeta(
    'instrumentNumber',
  );
  @override
  late final GeneratedColumn<String> instrumentNumber = GeneratedColumn<String>(
    'instrument_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assetNumberMeta = const VerificationMeta(
    'assetNumber',
  );
  @override
  late final GeneratedColumn<String> assetNumber = GeneratedColumn<String>(
    'asset_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _epcMeta = const VerificationMeta('epc');
  @override
  late final GeneratedColumn<String> epc = GeneratedColumn<String>(
    'epc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    instrumentNumber,
    name,
    assetNumber,
    unit,
    epc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('instrument_number')) {
      context.handle(
        _instrumentNumberMeta,
        instrumentNumber.isAcceptableOrUnknown(
          data['instrument_number']!,
          _instrumentNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentNumberMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('asset_number')) {
      context.handle(
        _assetNumberMeta,
        assetNumber.isAcceptableOrUnknown(
          data['asset_number']!,
          _assetNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assetNumberMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('epc')) {
      context.handle(
        _epcMeta,
        epc.isAcceptableOrUnknown(data['epc']!, _epcMeta),
      );
    } else if (isInserting) {
      context.missing(_epcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      instrumentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_number'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      assetNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_number'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      epc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}epc'],
      )!,
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class DeviceEntity extends DataClass implements Insertable<DeviceEntity> {
  /// RFID 匯出的 Id (GUID),primary key
  final String id;

  /// 儀器編號
  final String instrumentNumber;

  /// 設備名稱
  final String name;

  /// 財產編號
  final String assetNumber;

  /// 單位
  final String unit;

  /// EPC(RFID HEX 值,統一存大寫)
  final String epc;
  const DeviceEntity({
    required this.id,
    required this.instrumentNumber,
    required this.name,
    required this.assetNumber,
    required this.unit,
    required this.epc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['instrument_number'] = Variable<String>(instrumentNumber);
    map['name'] = Variable<String>(name);
    map['asset_number'] = Variable<String>(assetNumber);
    map['unit'] = Variable<String>(unit);
    map['epc'] = Variable<String>(epc);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      instrumentNumber: Value(instrumentNumber),
      name: Value(name),
      assetNumber: Value(assetNumber),
      unit: Value(unit),
      epc: Value(epc),
    );
  }

  factory DeviceEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceEntity(
      id: serializer.fromJson<String>(json['id']),
      instrumentNumber: serializer.fromJson<String>(json['instrumentNumber']),
      name: serializer.fromJson<String>(json['name']),
      assetNumber: serializer.fromJson<String>(json['assetNumber']),
      unit: serializer.fromJson<String>(json['unit']),
      epc: serializer.fromJson<String>(json['epc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'instrumentNumber': serializer.toJson<String>(instrumentNumber),
      'name': serializer.toJson<String>(name),
      'assetNumber': serializer.toJson<String>(assetNumber),
      'unit': serializer.toJson<String>(unit),
      'epc': serializer.toJson<String>(epc),
    };
  }

  DeviceEntity copyWith({
    String? id,
    String? instrumentNumber,
    String? name,
    String? assetNumber,
    String? unit,
    String? epc,
  }) => DeviceEntity(
    id: id ?? this.id,
    instrumentNumber: instrumentNumber ?? this.instrumentNumber,
    name: name ?? this.name,
    assetNumber: assetNumber ?? this.assetNumber,
    unit: unit ?? this.unit,
    epc: epc ?? this.epc,
  );
  DeviceEntity copyWithCompanion(DevicesCompanion data) {
    return DeviceEntity(
      id: data.id.present ? data.id.value : this.id,
      instrumentNumber: data.instrumentNumber.present
          ? data.instrumentNumber.value
          : this.instrumentNumber,
      name: data.name.present ? data.name.value : this.name,
      assetNumber: data.assetNumber.present
          ? data.assetNumber.value
          : this.assetNumber,
      unit: data.unit.present ? data.unit.value : this.unit,
      epc: data.epc.present ? data.epc.value : this.epc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceEntity(')
          ..write('id: $id, ')
          ..write('instrumentNumber: $instrumentNumber, ')
          ..write('name: $name, ')
          ..write('assetNumber: $assetNumber, ')
          ..write('unit: $unit, ')
          ..write('epc: $epc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, instrumentNumber, name, assetNumber, unit, epc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceEntity &&
          other.id == this.id &&
          other.instrumentNumber == this.instrumentNumber &&
          other.name == this.name &&
          other.assetNumber == this.assetNumber &&
          other.unit == this.unit &&
          other.epc == this.epc);
}

class DevicesCompanion extends UpdateCompanion<DeviceEntity> {
  final Value<String> id;
  final Value<String> instrumentNumber;
  final Value<String> name;
  final Value<String> assetNumber;
  final Value<String> unit;
  final Value<String> epc;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.instrumentNumber = const Value.absent(),
    this.name = const Value.absent(),
    this.assetNumber = const Value.absent(),
    this.unit = const Value.absent(),
    this.epc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    required String instrumentNumber,
    required String name,
    required String assetNumber,
    required String unit,
    required String epc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       instrumentNumber = Value(instrumentNumber),
       name = Value(name),
       assetNumber = Value(assetNumber),
       unit = Value(unit),
       epc = Value(epc);
  static Insertable<DeviceEntity> custom({
    Expression<String>? id,
    Expression<String>? instrumentNumber,
    Expression<String>? name,
    Expression<String>? assetNumber,
    Expression<String>? unit,
    Expression<String>? epc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (instrumentNumber != null) 'instrument_number': instrumentNumber,
      if (name != null) 'name': name,
      if (assetNumber != null) 'asset_number': assetNumber,
      if (unit != null) 'unit': unit,
      if (epc != null) 'epc': epc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith({
    Value<String>? id,
    Value<String>? instrumentNumber,
    Value<String>? name,
    Value<String>? assetNumber,
    Value<String>? unit,
    Value<String>? epc,
    Value<int>? rowid,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      instrumentNumber: instrumentNumber ?? this.instrumentNumber,
      name: name ?? this.name,
      assetNumber: assetNumber ?? this.assetNumber,
      unit: unit ?? this.unit,
      epc: epc ?? this.epc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (instrumentNumber.present) {
      map['instrument_number'] = Variable<String>(instrumentNumber.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (assetNumber.present) {
      map['asset_number'] = Variable<String>(assetNumber.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (epc.present) {
      map['epc'] = Variable<String>(epc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('instrumentNumber: $instrumentNumber, ')
          ..write('name: $name, ')
          ..write('assetNumber: $assetNumber, ')
          ..write('unit: $unit, ')
          ..write('epc: $epc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetadataTable extends Metadata
    with TableInfo<$MetadataTable, MetadataEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetadataEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MetadataEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetadataEntity(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $MetadataTable createAlias(String alias) {
    return $MetadataTable(attachedDatabase, alias);
  }
}

class MetadataEntity extends DataClass implements Insertable<MetadataEntity> {
  final String key;
  final String value;
  const MetadataEntity({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetadataCompanion toCompanion(bool nullToAbsent) {
    return MetadataCompanion(key: Value(key), value: Value(value));
  }

  factory MetadataEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetadataEntity(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  MetadataEntity copyWith({String? key, String? value}) =>
      MetadataEntity(key: key ?? this.key, value: value ?? this.value);
  MetadataEntity copyWithCompanion(MetadataCompanion data) {
    return MetadataEntity(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetadataEntity(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetadataEntity &&
          other.key == this.key &&
          other.value == this.value);
}

class MetadataCompanion extends UpdateCompanion<MetadataEntity> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const MetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetadataCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<MetadataEntity> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetadataCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return MetadataCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $MetadataTable metadata = $MetadataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [devices, metadata];
}

typedef $$DevicesTableCreateCompanionBuilder =
    DevicesCompanion Function({
      required String id,
      required String instrumentNumber,
      required String name,
      required String assetNumber,
      required String unit,
      required String epc,
      Value<int> rowid,
    });
typedef $$DevicesTableUpdateCompanionBuilder =
    DevicesCompanion Function({
      Value<String> id,
      Value<String> instrumentNumber,
      Value<String> name,
      Value<String> assetNumber,
      Value<String> unit,
      Value<String> epc,
      Value<int> rowid,
    });

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instrumentNumber => $composableBuilder(
    column: $table.instrumentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetNumber => $composableBuilder(
    column: $table.assetNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get epc => $composableBuilder(
    column: $table.epc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instrumentNumber => $composableBuilder(
    column: $table.instrumentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetNumber => $composableBuilder(
    column: $table.assetNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get epc => $composableBuilder(
    column: $table.epc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get instrumentNumber => $composableBuilder(
    column: $table.instrumentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get assetNumber => $composableBuilder(
    column: $table.assetNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get epc =>
      $composableBuilder(column: $table.epc, builder: (column) => column);
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicesTable,
          DeviceEntity,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (
            DeviceEntity,
            BaseReferences<_$AppDatabase, $DevicesTable, DeviceEntity>,
          ),
          DeviceEntity,
          PrefetchHooks Function()
        > {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> instrumentNumber = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> assetNumber = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String> epc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                instrumentNumber: instrumentNumber,
                name: name,
                assetNumber: assetNumber,
                unit: unit,
                epc: epc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String instrumentNumber,
                required String name,
                required String assetNumber,
                required String unit,
                required String epc,
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion.insert(
                id: id,
                instrumentNumber: instrumentNumber,
                name: name,
                assetNumber: assetNumber,
                unit: unit,
                epc: epc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicesTable,
      DeviceEntity,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (
        DeviceEntity,
        BaseReferences<_$AppDatabase, $DevicesTable, DeviceEntity>,
      ),
      DeviceEntity,
      PrefetchHooks Function()
    >;
typedef $$MetadataTableCreateCompanionBuilder =
    MetadataCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$MetadataTableUpdateCompanionBuilder =
    MetadataCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$MetadataTableFilterComposer
    extends Composer<_$AppDatabase, $MetadataTable> {
  $$MetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $MetadataTable> {
  $$MetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetadataTable> {
  $$MetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetadataTable,
          MetadataEntity,
          $$MetadataTableFilterComposer,
          $$MetadataTableOrderingComposer,
          $$MetadataTableAnnotationComposer,
          $$MetadataTableCreateCompanionBuilder,
          $$MetadataTableUpdateCompanionBuilder,
          (
            MetadataEntity,
            BaseReferences<_$AppDatabase, $MetadataTable, MetadataEntity>,
          ),
          MetadataEntity,
          PrefetchHooks Function()
        > {
  $$MetadataTableTableManager(_$AppDatabase db, $MetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetadataCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => MetadataCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetadataTable,
      MetadataEntity,
      $$MetadataTableFilterComposer,
      $$MetadataTableOrderingComposer,
      $$MetadataTableAnnotationComposer,
      $$MetadataTableCreateCompanionBuilder,
      $$MetadataTableUpdateCompanionBuilder,
      (
        MetadataEntity,
        BaseReferences<_$AppDatabase, $MetadataTable, MetadataEntity>,
      ),
      MetadataEntity,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$MetadataTableTableManager get metadata =>
      $$MetadataTableTableManager(_db, _db.metadata);
}
