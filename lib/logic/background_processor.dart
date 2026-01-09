import 'dart:async';
import 'dart:isolate';

enum WorkerCommand { start, pause, resume, terminate, processTask }
enum WorkerEvent { taskCompleted, ready }

class WorkerMessage {
  final WorkerCommand command;
  final dynamic payload;
  WorkerMessage(this.command, [this.payload]);
}

class MainMessage {
  final WorkerEvent event;
  final dynamic payload;
  MainMessage(this.event, [this.payload]);
}

class BackgroundProcessor {
  Isolate? _isolate;
  SendPort? _sendPort;
  final StreamController<MainMessage> _mainStreamController = StreamController.broadcast();
  bool _isPaused = false;

  Stream<MainMessage> get messages => _mainStreamController.stream;
  bool get isPaused => _isPaused;

  Future<void> start() async {
    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_isolateEntry, receivePort.sendPort);
    
    receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        _sendPort?.send(WorkerMessage(WorkerCommand.start));
      } else if (message is MainMessage) {
        _mainStreamController.add(message);
      }
    });
  }

  void processTask(int taskId, String title) {
    if (_sendPort == null) return;
    _sendPort!.send(WorkerMessage(WorkerCommand.processTask, {'id': taskId, 'title': title}));
  }

  void pause() {
    _isPaused = true;
    _sendPort?.send(WorkerMessage(WorkerCommand.pause));
  }

  void resume() {
    _isPaused = false;
    _sendPort?.send(WorkerMessage(WorkerCommand.resume));
  }

  void terminate() {
    _sendPort?.send(WorkerMessage(WorkerCommand.terminate));
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
    _mainStreamController.close();
  }

  static void _isolateEntry(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    bool isPaused = false;

    // We can simulate a queue inside the isolate if we want, 
    // or just process what we are given immediately.
    // Requirement: "Process tasks one by one".
    // If we receive a task while processing, we should probably queue it or reject it? 
    // The Main Isolate should probably control the flow: Send Task -> Wait for Completion -> Send Next.
    
    receivePort.listen((dynamic message) async {
      if (message is WorkerMessage) {
        switch (message.command) {
          case WorkerCommand.start:
            print('Isolate: Started');
            sendPort.send(MainMessage(WorkerEvent.ready));
            break;
          case WorkerCommand.pause:
            print('Isolate: Paused');
            isPaused = true;
            break;
          case WorkerCommand.resume:
            print('Isolate: Resumed');
            isPaused = false;
            break;
          case WorkerCommand.terminate:
            print('Isolate: Terminating');
            receivePort.close();
            break;
          case WorkerCommand.processTask:
            final data = message.payload as Map<String, dynamic>;
            final id = data['id'] as int;
            final title = data['title'] as String;
            
            // Wait if paused
            while (isPaused) {
              await Future.delayed(Duration(milliseconds: 500));
            }

            print('Isolate: Processing task $id - $title');
            
            // Simulate work
            await Future.delayed(Duration(seconds: 3));
            
            // Check paused again before finishing? 
            // Usually valid to finish ongoing task.
            
            print('Isolate: Type check complete for $id');
            sendPort.send(MainMessage(WorkerEvent.taskCompleted, id));
            sendPort.send(MainMessage(WorkerEvent.ready));
            break;
        }
      }
    });
  }
}
