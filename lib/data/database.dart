import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

enum TaskStatus {
  pending,
  running,
  completed,
  paused,
}

class QueueTasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get status => intEnum<TaskStatus>()();
  RealColumn get sortOrder => real()();
}

@DriftDatabase(tables: [QueueTasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'queue_manager_db');
  }
}
