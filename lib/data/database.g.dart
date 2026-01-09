// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $QueueTasksTable extends QueueTasks
    with TableInfo<$QueueTasksTable, QueueTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TaskStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TaskStatus>($QueueTasksTable.$converterstatus);
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<double> sortOrder = GeneratedColumn<double>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, status, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueueTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      status: $QueueTasksTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $QueueTasksTable createAlias(String alias) {
    return $QueueTasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TaskStatus, int, int> $converterstatus =
      const EnumIndexConverter<TaskStatus>(TaskStatus.values);
}

class QueueTask extends DataClass implements Insertable<QueueTask> {
  final int id;
  final String title;
  final TaskStatus status;
  final double sortOrder;
  const QueueTask({
    required this.id,
    required this.title,
    required this.status,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    {
      map['status'] = Variable<int>(
        $QueueTasksTable.$converterstatus.toSql(status),
      );
    }
    map['sort_order'] = Variable<double>(sortOrder);
    return map;
  }

  QueueTasksCompanion toCompanion(bool nullToAbsent) {
    return QueueTasksCompanion(
      id: Value(id),
      title: Value(title),
      status: Value(status),
      sortOrder: Value(sortOrder),
    );
  }

  factory QueueTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueTask(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      status: $QueueTasksTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      sortOrder: serializer.fromJson<double>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'status': serializer.toJson<int>(
        $QueueTasksTable.$converterstatus.toJson(status),
      ),
      'sortOrder': serializer.toJson<double>(sortOrder),
    };
  }

  QueueTask copyWith({
    int? id,
    String? title,
    TaskStatus? status,
    double? sortOrder,
  }) => QueueTask(
    id: id ?? this.id,
    title: title ?? this.title,
    status: status ?? this.status,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  QueueTask copyWithCompanion(QueueTasksCompanion data) {
    return QueueTask(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueTask(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, status, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueTask &&
          other.id == this.id &&
          other.title == this.title &&
          other.status == this.status &&
          other.sortOrder == this.sortOrder);
}

class QueueTasksCompanion extends UpdateCompanion<QueueTask> {
  final Value<int> id;
  final Value<String> title;
  final Value<TaskStatus> status;
  final Value<double> sortOrder;
  const QueueTasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  QueueTasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required TaskStatus status,
    required double sortOrder,
  }) : title = Value(title),
       status = Value(status),
       sortOrder = Value(sortOrder);
  static Insertable<QueueTask> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? status,
    Expression<double>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  QueueTasksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<TaskStatus>? status,
    Value<double>? sortOrder,
  }) {
    return QueueTasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $QueueTasksTable.$converterstatus.toSql(status.value),
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<double>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueTasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $QueueTasksTable queueTasks = $QueueTasksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [queueTasks];
}

typedef $$QueueTasksTableCreateCompanionBuilder =
    QueueTasksCompanion Function({
      Value<int> id,
      required String title,
      required TaskStatus status,
      required double sortOrder,
    });
typedef $$QueueTasksTableUpdateCompanionBuilder =
    QueueTasksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<TaskStatus> status,
      Value<double> sortOrder,
    });

class $$QueueTasksTableFilterComposer
    extends Composer<_$AppDatabase, $QueueTasksTable> {
  $$QueueTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TaskStatus, TaskStatus, int> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QueueTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueTasksTable> {
  $$QueueTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QueueTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueTasksTable> {
  $$QueueTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$QueueTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueueTasksTable,
          QueueTask,
          $$QueueTasksTableFilterComposer,
          $$QueueTasksTableOrderingComposer,
          $$QueueTasksTableAnnotationComposer,
          $$QueueTasksTableCreateCompanionBuilder,
          $$QueueTasksTableUpdateCompanionBuilder,
          (
            QueueTask,
            BaseReferences<_$AppDatabase, $QueueTasksTable, QueueTask>,
          ),
          QueueTask,
          PrefetchHooks Function()
        > {
  $$QueueTasksTableTableManager(_$AppDatabase db, $QueueTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<TaskStatus> status = const Value.absent(),
                Value<double> sortOrder = const Value.absent(),
              }) => QueueTasksCompanion(
                id: id,
                title: title,
                status: status,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required TaskStatus status,
                required double sortOrder,
              }) => QueueTasksCompanion.insert(
                id: id,
                title: title,
                status: status,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QueueTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueueTasksTable,
      QueueTask,
      $$QueueTasksTableFilterComposer,
      $$QueueTasksTableOrderingComposer,
      $$QueueTasksTableAnnotationComposer,
      $$QueueTasksTableCreateCompanionBuilder,
      $$QueueTasksTableUpdateCompanionBuilder,
      (QueueTask, BaseReferences<_$AppDatabase, $QueueTasksTable, QueueTask>),
      QueueTask,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$QueueTasksTableTableManager get queueTasks =>
      $$QueueTasksTableTableManager(_db, _db.queueTasks);
}
