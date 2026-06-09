// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DevicesTable extends Devices
    with TableInfo<$DevicesTable, DeviceEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serialCodeMeta = const VerificationMeta(
    'serialCode',
  );
  @override
  late final GeneratedColumn<String> serialCode = GeneratedColumn<String>(
    'serial_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registryIdMeta = const VerificationMeta(
    'registryId',
  );
  @override
  late final GeneratedColumn<String> registryId = GeneratedColumn<String>(
    'registry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
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
    uid,
    serialCode,
    label,
    registryId,
    category,
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
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('serial_code')) {
      context.handle(
        _serialCodeMeta,
        serialCode.isAcceptableOrUnknown(data['serial_code']!, _serialCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_serialCodeMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('registry_id')) {
      context.handle(
        _registryIdMeta,
        registryId.isAcceptableOrUnknown(data['registry_id']!, _registryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_registryIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
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
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  DeviceEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceEntity(
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      serialCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serial_code'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      registryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registry_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
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
  final String uid;
  final String serialCode;
  final String label;
  final String registryId;
  final String category;
  final String epc;
  const DeviceEntity({
    required this.uid,
    required this.serialCode,
    required this.label,
    required this.registryId,
    required this.category,
    required this.epc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    map['serial_code'] = Variable<String>(serialCode);
    map['label'] = Variable<String>(label);
    map['registry_id'] = Variable<String>(registryId);
    map['category'] = Variable<String>(category);
    map['epc'] = Variable<String>(epc);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      uid: Value(uid),
      serialCode: Value(serialCode),
      label: Value(label),
      registryId: Value(registryId),
      category: Value(category),
      epc: Value(epc),
    );
  }

  factory DeviceEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceEntity(
      uid: serializer.fromJson<String>(json['uid']),
      serialCode: serializer.fromJson<String>(json['serialCode']),
      label: serializer.fromJson<String>(json['label']),
      registryId: serializer.fromJson<String>(json['registryId']),
      category: serializer.fromJson<String>(json['category']),
      epc: serializer.fromJson<String>(json['epc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'serialCode': serializer.toJson<String>(serialCode),
      'label': serializer.toJson<String>(label),
      'registryId': serializer.toJson<String>(registryId),
      'category': serializer.toJson<String>(category),
      'epc': serializer.toJson<String>(epc),
    };
  }

  DeviceEntity copyWith({
    String? uid,
    String? serialCode,
    String? label,
    String? registryId,
    String? category,
    String? epc,
  }) => DeviceEntity(
    uid: uid ?? this.uid,
    serialCode: serialCode ?? this.serialCode,
    label: label ?? this.label,
    registryId: registryId ?? this.registryId,
    category: category ?? this.category,
    epc: epc ?? this.epc,
  );
  DeviceEntity copyWithCompanion(DevicesCompanion data) {
    return DeviceEntity(
      uid: data.uid.present ? data.uid.value : this.uid,
      serialCode: data.serialCode.present
          ? data.serialCode.value
          : this.serialCode,
      label: data.label.present ? data.label.value : this.label,
      registryId: data.registryId.present
          ? data.registryId.value
          : this.registryId,
      category: data.category.present ? data.category.value : this.category,
      epc: data.epc.present ? data.epc.value : this.epc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceEntity(')
          ..write('uid: $uid, ')
          ..write('serialCode: $serialCode, ')
          ..write('label: $label, ')
          ..write('registryId: $registryId, ')
          ..write('category: $category, ')
          ..write('epc: $epc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uid, serialCode, label, registryId, category, epc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceEntity &&
          other.uid == this.uid &&
          other.serialCode == this.serialCode &&
          other.label == this.label &&
          other.registryId == this.registryId &&
          other.category == this.category &&
          other.epc == this.epc);
}

class DevicesCompanion extends UpdateCompanion<DeviceEntity> {
  final Value<String> uid;
  final Value<String> serialCode;
  final Value<String> label;
  final Value<String> registryId;
  final Value<String> category;
  final Value<String> epc;
  final Value<int> rowid;
  const DevicesCompanion({
    this.uid = const Value.absent(),
    this.serialCode = const Value.absent(),
    this.label = const Value.absent(),
    this.registryId = const Value.absent(),
    this.category = const Value.absent(),
    this.epc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String uid,
    required String serialCode,
    required String label,
    required String registryId,
    required String category,
    required String epc,
    this.rowid = const Value.absent(),
  }) : uid = Value(uid),
       serialCode = Value(serialCode),
       label = Value(label),
       registryId = Value(registryId),
       category = Value(category),
       epc = Value(epc);
  static Insertable<DeviceEntity> custom({
    Expression<String>? uid,
    Expression<String>? serialCode,
    Expression<String>? label,
    Expression<String>? registryId,
    Expression<String>? category,
    Expression<String>? epc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (serialCode != null) 'serial_code': serialCode,
      if (label != null) 'label': label,
      if (registryId != null) 'registry_id': registryId,
      if (category != null) 'category': category,
      if (epc != null) 'epc': epc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith({
    Value<String>? uid,
    Value<String>? serialCode,
    Value<String>? label,
    Value<String>? registryId,
    Value<String>? category,
    Value<String>? epc,
    Value<int>? rowid,
  }) {
    return DevicesCompanion(
      uid: uid ?? this.uid,
      serialCode: serialCode ?? this.serialCode,
      label: label ?? this.label,
      registryId: registryId ?? this.registryId,
      category: category ?? this.category,
      epc: epc ?? this.epc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (serialCode.present) {
      map['serial_code'] = Variable<String>(serialCode.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (registryId.present) {
      map['registry_id'] = Variable<String>(registryId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
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
          ..write('uid: $uid, ')
          ..write('serialCode: $serialCode, ')
          ..write('label: $label, ')
          ..write('registryId: $registryId, ')
          ..write('category: $category, ')
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
      required String uid,
      required String serialCode,
      required String label,
      required String registryId,
      required String category,
      required String epc,
      Value<int> rowid,
    });
typedef $$DevicesTableUpdateCompanionBuilder =
    DevicesCompanion Function({
      Value<String> uid,
      Value<String> serialCode,
      Value<String> label,
      Value<String> registryId,
      Value<String> category,
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
  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serialCode => $composableBuilder(
    column: $table.serialCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registryId => $composableBuilder(
    column: $table.registryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
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
  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serialCode => $composableBuilder(
    column: $table.serialCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registryId => $composableBuilder(
    column: $table.registryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
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
  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get serialCode => $composableBuilder(
    column: $table.serialCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get registryId => $composableBuilder(
    column: $table.registryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

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
                Value<String> uid = const Value.absent(),
                Value<String> serialCode = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> registryId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> epc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion(
                uid: uid,
                serialCode: serialCode,
                label: label,
                registryId: registryId,
                category: category,
                epc: epc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uid,
                required String serialCode,
                required String label,
                required String registryId,
                required String category,
                required String epc,
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion.insert(
                uid: uid,
                serialCode: serialCode,
                label: label,
                registryId: registryId,
                category: category,
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
