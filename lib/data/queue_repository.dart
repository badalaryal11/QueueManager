import 'dart:async';
import 'dart:developer' as developer;
import 'package:drift/drift.dart';
import 'database.dart';

class QueueRepository {
  final AppDatabase _db;
  final _writeCountController = StreamController<int>.broadcast();
  int _writeCount = 0;

  QueueRepository(this._db);

  Stream<List<QueueTask>> watchAllTasks() {
    return (_db.select(
      _db.queueTasks,
    )..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).watch();
  }

  Stream<int> get writeCountStream => _writeCountController.stream;
  int get currentWriteCount => _writeCount;

  Future<void> addTask(String title) async {
    _incrementWriteCount();

    // Get the current max sort order
    final query = _db.select(_db.queueTasks)
      ..orderBy([
        (t) => OrderingTerm(expression: t.sortOrder, mode: OrderingMode.desc),
      ])
      ..limit(1);
    final lastTask = await query.getSingleOrNull();

    final newSortOrder =
        (lastTask?.sortOrder ?? 0.0) +
        1000.0; // Large gap for future insertions

    await _db
        .into(_db.queueTasks)
        .insert(
          QueueTasksCompanion.insert(
            title: title,
            status: TaskStatus.pending,
            sortOrder: newSortOrder,
          ),
        );
  }

  Future<void> updateTaskStatus(int id, TaskStatus status) async {
    _incrementWriteCount();
    await (_db.update(_db.queueTasks)..where((t) => t.id.equals(id))).write(
      QueueTasksCompanion(status: Value(status)),
    );
  }

  // Optimized reordering: O(1) mostly, update only one row
  Future<void> reorderTask(int taskId, int oldIndex, int newIndex) async {
    // Flutter's ReorderableListView adjustment
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Fetch current list to determine neighbors
    final tasks = await (_db.select(
      _db.queueTasks,
    )..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).get();

    if (oldIndex < 0 ||
        oldIndex >= tasks.length ||
        newIndex < 0 ||
        newIndex >= tasks.length) {
      return; // Out of bounds
    }

    final taskToMove = tasks[oldIndex];

    // Simulate the move locally to find neighbors (neighbors in the Target List)
    tasks.removeAt(oldIndex);
    tasks.insert(newIndex, taskToMove);

    double newSortOrder;

    if (newIndex == 0) {
      // First item
      final next = tasks.length > 1 ? tasks[1] : null; // tasks[0] is us
      newSortOrder = (next?.sortOrder ?? 1000.0) / 2.0;
    } else if (newIndex == tasks.length - 1) {
      // Last item
      final prev = tasks[newIndex - 1];
      newSortOrder = prev.sortOrder + 1000.0;
    } else {
      // Middle
      final prev = tasks[newIndex - 1];
      final next = tasks[newIndex + 1];
      newSortOrder = (prev.sortOrder + next.sortOrder) / 2.0;
    }

    _incrementWriteCount();
    await (_db.update(_db.queueTasks)..where((t) => t.id.equals(taskId))).write(
      QueueTasksCompanion(sortOrder: Value(newSortOrder)),
    );
  }

  void _incrementWriteCount() {
    _writeCount++;
    _writeCountController.add(_writeCount);
    developer.log(
      'Database Write Count: $_writeCount',
      name: 'QueueRepository',
    );
  }

  Future<void> deleteCompletedTasks() async {
    _incrementWriteCount();
    // Using .index because generated code typically expects the integer value for intEnum columns in where clauses
    await (_db.delete(
      _db.queueTasks,
    )..where((t) => t.status.equals(TaskStatus.completed.index))).go();
  }
}
