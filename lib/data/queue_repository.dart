import 'dart:async';
import 'package:drift/drift.dart';
import 'database.dart';

class QueueRepository {
  final AppDatabase _db;
  final _writeCountController = StreamController<int>.broadcast();
  int _writeCount = 0;

  QueueRepository(this._db);

  Stream<List<QueueTask>> watchAllTasks() {
    return (_db.select(_db.queueTasks)
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .watch();
  }

  Stream<int> get writeCountStream => _writeCountController.stream;
  int get currentWriteCount => _writeCount;

  Future<void> addTask(String title) async {
    _incrementWriteCount();
    
    // Get the current max sort order
    final query = _db.select(_db.queueTasks)
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder, mode: OrderingMode.desc)])
      ..limit(1);
    final lastTask = await query.getSingleOrNull();
    
    final newSortOrder = (lastTask?.sortOrder ?? 0.0) + 1000.0; // Large gap for future insertions

    await _db.into(_db.queueTasks).insert(
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
    // Note: The UI ReorderableListView calls onReorder with newIndex > oldIndex having an offset of +1 which is already handled by the widget? 
    // Usually Flutter's ReorderableListView needs: if (oldIndex < newIndex) newIndex -= 1;
    // But here we need the target positions in the LIST.
    
    // We need to fetch the current list to know surrounding items.
    // This read is cheap compared to writes.
    final tasks = await (_db.select(_db.queueTasks)
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final taskToMove = tasks[oldIndex];
    if (taskToMove.id != taskId) {
        // Fallback or error check, though indices should align if list is sync
    }

    // Determine new sort order
    double newSortOrder;
    
    if (newIndex == 0) {
      // Moving to top
      final first = tasks.first;
      newSortOrder = first.sortOrder / 2.0;
    } else if (newIndex >= tasks.length - 1) {
      // Moving to bottom
      final last = tasks.last;
      newSortOrder = last.sortOrder + 1000.0;
    } else {
      // Moving between two items
      // We want to insert AFTER newIndex-1 and BEFORE newIndex (which is now shifted because we removed the item semantically)
      // Actually, after the move effectively:
      // [A, B, C, D] -> Move D between A and B -> [A, D, B, C]
      // index of D became 1.
      // We look at item at index-1 (A) and index (B).
      
      final prevItem = tasks[newIndex - 1]; // item before our new position (excluding us)
      // Wait, if we move down: [A, B, C] -> Move A to end -> [B, C, A].
      // old=0, new=3 (in flutter callback). corrected new=2.
      // target is index 2.
      // tasks[2] was C.
      // But we are effectively inserting AFTER C is wrong?
      
      // Let's rely on the list snapshot *before* move for "surrounding" logic logic, but simpler:
      // Remove item from local list.
      tasks.removeAt(oldIndex);
      tasks.insert(newIndex, taskToMove);
      
      // Now check neighbors in the modified list
      final prev = newIndex > 0 ? tasks[newIndex - 1] : null;
      final next = newIndex < tasks.length - 1 ? tasks[newIndex + 1] : null;
      
      if (prev == null) {
        newSortOrder = (next!.sortOrder) / 2.0; 
      } else if (next == null) {
        newSortOrder = prev.sortOrder + 1000.0;
      } else {
        newSortOrder = (prev.sortOrder + next.sortOrder) / 2.0;
      }
    }

    _incrementWriteCount();
    await (_db.update(_db.queueTasks)..where((t) => t.id.equals(taskId))).write(
      QueueTasksCompanion(sortOrder: Value(newSortOrder)),
    );
  }

  void _incrementWriteCount() {
    _writeCount++;
    _writeCountController.add(_writeCount);
    print('Database Write Count: $_writeCount');
  }

  Future<void> deleteCompletedTasks() async {
    _incrementWriteCount();
    // Using .index because generated code typically expects the integer value for intEnum columns in where clauses
    await (_db.delete(_db.queueTasks)..where((t) => t.status.equals(TaskStatus.completed.index))).go();
  }
}
