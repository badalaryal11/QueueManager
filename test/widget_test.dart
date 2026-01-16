import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queue_manager/data/database.dart';
import 'package:queue_manager/data/queue_repository.dart';
import 'package:queue_manager/logic/background_processor.dart';
import 'package:queue_manager/main.dart';
import 'package:queue_manager/services/system_resource_service.dart';

// Fake implementations for testing
class FakeQueueRepository implements QueueRepository {
  final _controller = StreamController<List<QueueTask>>.broadcast();
  final _writeCountController = StreamController<int>.broadcast();

  @override
  Stream<List<QueueTask>> watchAllTasks() {
    return _controller.stream;
  }

  @override
  Stream<int> get writeCountStream => _writeCountController.stream;

  @override
  int get currentWriteCount => 0;

  @override
  Future<void> addTask(String title) async {}

  @override
  Future<void> updateTaskStatus(int id, TaskStatus status) async {}

  @override
  Future<void> reorderTask(int taskId, int oldIndex, int newIndex) async {}

  @override
  Future<void> deleteCompletedTasks() async {}
}

class FakeSystemResourceService implements SystemResourceService {
  @override
  Stream<SystemResources> get resourceStream => Stream.value(
    SystemResources(cpuUsage: 10.0, ramUsage: 20.0, temperature: 40.0),
  );
}

class FakeBackgroundProcessor implements BackgroundProcessor {
  @override
  Stream<MainMessage> get messages => const Stream.empty();

  @override
  bool get isPaused => false;

  @override
  bool get isStarted => false;

  @override
  Future<void> start() async {}

  @override
  void processTask(int taskId, String title) {}

  @override
  void pause() {}

  @override
  void resume() {}

  @override
  void terminate() {}
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MyApp(
        repository: FakeQueueRepository(),
        resourceService: FakeSystemResourceService(),
        processor: FakeBackgroundProcessor(),
      ),
    );

    // Verify that the title is present
    expect(find.text('Queue Manager'), findsOneWidget);

    // Verify we are not incorrectly showing the counter test stuff
    expect(find.text('0'), findsNothing);
    expect(
      find.byIcon(Icons.add),
      findsNothing,
    ); // Add button might exist but let's check basic sanity
  });
}
