import 'dart:async';
import 'dart:isolate';

enum WorkerCommand { start, pause, resume, terminate, processTask }
enum WorkerEvent { taskCompleted, ready, started, paused, resumed }

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
  bool _isStarted = false;

  Stream<MainMessage> get messages => _mainStreamController.stream;
  bool get isPaused => _isPaused;
  bool get isStarted => _isStarted;

  Future<void> start() async {
    if (_isolate != null) return; // Already started
    
    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_isolateEntry, receivePort.sendPort);
    
    receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        _sendPort?.send(WorkerMessage(WorkerCommand.start));
      } else if (message is MainMessage) {
        _mainStreamController.add(message);
        if (message.event == WorkerEvent.started) {
          _isStarted = true;
          _isPaused = false;
        }
      }
    });
  }

  void processTask(int taskId, String title) {
    if (_sendPort == null) {
        print('Error: Processor not started');
        return;
    }
    _sendPort!.send(WorkerMessage(WorkerCommand.processTask, {'id': taskId, 'title': title}));
  }

  void pause() {
    if (_isPaused) return;
    _isPaused = true;
    _sendPort?.send(WorkerMessage(WorkerCommand.pause));
  }

  void resume() {
    if (!_isPaused) return;
    _isPaused = false;
    _sendPort?.send(WorkerMessage(WorkerCommand.resume));
  }

  void terminate() {
    _sendPort?.send(WorkerMessage(WorkerCommand.terminate));
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
    _isStarted = false;
    // _mainStreamController.close(); // Do not close if we plan to restart?
    // Good practice: If terminating for good, close. If just stopping engine, maybe keep stream?
    // Let's keep stream open for simplicity in Bloc, or Bloc should handle re-subscription.
  }

  static void _isolateEntry(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    bool isPaused = false;

    receivePort.listen((dynamic message) async {
      if (message is WorkerMessage) {
        switch (message.command) {
          case WorkerCommand.start:
            print('Isolate: Started');
            sendPort.send(MainMessage(WorkerEvent.started));
            sendPort.send(MainMessage(WorkerEvent.ready));
            break;
          case WorkerCommand.pause:
            print('Isolate: Paused');
            isPaused = true;
            sendPort.send(MainMessage(WorkerEvent.paused));
            break;
          case WorkerCommand.resume:
            print('Isolate: Resumed');
            isPaused = false;
            sendPort.send(MainMessage(WorkerEvent.resumed));
            // Trigger a ready check or just wait for next task?
            // If we were blocked, the loop continues.
            break;
          case WorkerCommand.terminate:
            print('Isolate: Terminating');
            receivePort.close();
            break;
          case WorkerCommand.processTask:
            final data = message.payload as Map<String, dynamic>;
            final id = data['id'] as int;
            final title = data['title'] as String;
            
            // Wait if paused *before* starting
            while (isPaused) {
              await Future.delayed(Duration(milliseconds: 500));
            }

            print('Isolate: Processing task $id - $title');
            
            // Simulate heavy work (e.g. 2 seconds)
            // Break it down to check for pause?
            for (int i = 0; i < 20; i++) {
                while (isPaused) {
                    await Future.delayed(Duration(milliseconds: 500));
                }
                await Future.delayed(Duration(milliseconds: 100)); // 0.1s * 20 = 2s
            }
            
            print('Isolate: Task complete for $id');
            sendPort.send(MainMessage(WorkerEvent.taskCompleted, id));
            sendPort.send(MainMessage(WorkerEvent.ready));
            break;
        }
      }
    });
  }
}
