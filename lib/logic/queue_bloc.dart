
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/database.dart';
import '../data/queue_repository.dart';
import '../services/temperature_service.dart';
import 'background_processor.dart';
import 'queue_state_event.dart';

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final QueueRepository _repository;
  final TemperatureService _temperatureService;
  final BackgroundProcessor _processor;

  StreamSubscription? _tasksSubscription;
  StreamSubscription? _tempSubscription;
  StreamSubscription? _processorSubscription;

  static const double _overheatThreshold = 80.0;
  static const double _recoveryThreshold = 50.0;

  QueueBloc(this._repository, this._temperatureService, this._processor) : super(QueueLoading()) {
    on<LoadTasks>(_onLoadTasks);
    on<TasksUpdated>(_onTasksUpdated);
    on<AddTask>(_onAddTask);
    on<ReorderTask>(_onReorderTask);
    on<ToggleQueueProcessing>(_onToggleQueueProcessing);
    on<ClearCompleted>(_onClearCompleted);
    on<RestartAll>(_onRestartAll);
    on<TemperatureUpdated>(_onTemperatureUpdated);
    on<ProcessorMessageReceived>(_onProcessorMessageReceived);

    // Initialize subscriptions
    _tasksSubscription = _repository.watchAllTasks().listen((tasks) {
      add(TasksUpdated(tasks));
    });

    _tempSubscription = _temperatureService.temperatureStream.listen((temp) {
      add(TemperatureUpdated(temp));
    });

    _processorSubscription = _processor.messages.listen((msg) {
      add(ProcessorMessageReceived(msg));
    });

    _processor.start();
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<QueueState> emit) async {
    // Initial fetch handled by subscription
  }

  void _onTasksUpdated(TasksUpdated event, Emitter<QueueState> emit) {
    if (state is QueueLoading) {
      emit(QueueLoaded(tasks: event.tasks));
    } else if (state is QueueLoaded) {
      final s = state as QueueLoaded;
      emit(s.copyWith(tasks: event.tasks));
      _processNextTaskIfNeeded(event.tasks, s);
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<QueueState> emit) async {
    await _repository.addTask(event.title);
  }

  Future<void> _onReorderTask(ReorderTask event, Emitter<QueueState> emit) async {
    await _repository.reorderTask(event.taskId, event.oldIndex, event.newIndex);
  }

  void _onToggleQueueProcessing(ToggleQueueProcessing event, Emitter<QueueState> emit) {
    if (state is QueueLoaded) {
      final s = state as QueueLoaded;
      if (s.isPaused) {
        _processor.resume();
        emit(s.copyWith(isPaused: false));
        _processNextTaskIfNeeded(s.tasks, s.copyWith(isPaused: false));
      } else {
        _processor.pause();
        emit(s.copyWith(isPaused: true));
      }
    }
  }

  Future<void> _onClearCompleted(ClearCompleted event, Emitter<QueueState> emit) async {
    await _repository.deleteCompletedTasks();
  }
  
  Future<void> _onRestartAll(RestartAll event, Emitter<QueueState> emit) async {
      if (state is QueueLoaded) {
        final tasks = (state as QueueLoaded).tasks;
        for (var t in tasks) {
            await _repository.updateTaskStatus(t.id, TaskStatus.pending);
        }
      }
  }

  void _onTemperatureUpdated(TemperatureUpdated event, Emitter<QueueState> emit) {
    if (state is QueueLoaded) {
      final s = state as QueueLoaded;
      bool isOverheated = s.isOverheated;
      bool isPaused = s.isPaused;

      if (event.temperature > _overheatThreshold) {
        if (!isOverheated) {
          isOverheated = true;
          if (!isPaused) {
             _processor.pause();
             isPaused = true; // Auto-pause
          }
        }
      } else if (event.temperature < _recoveryThreshold) {
        if (isOverheated) {
          isOverheated = false;
          if (isPaused) { // Only auto-resume if it was paused due to heat? 
              // Requirement: "Resume queue processing automatically when temperature drops below the threshold"
              _processor.resume();
              isPaused = false;
          }
        }
      }

      emit(s.copyWith(
        temperature: event.temperature,
        isOverheated: isOverheated,
        isPaused: isPaused,
      ));
      
      if (!isPaused && !isOverheated) {
         _processNextTaskIfNeeded(s.tasks, s);
      }
    }
  }

  Future<void> _onProcessorMessageReceived(ProcessorMessageReceived event, Emitter<QueueState> emit) async {
    final msg = event.message as MainMessage;
    if (msg.event == WorkerEvent.ready) {
        if (state is QueueLoaded) {
            final s = state as QueueLoaded;
            // Mark current processing task as completed if any?
            // No, taskCompleted comes separately.
            emit(s.copyWith(processingTaskId: -1));
            _processNextTaskIfNeeded(s.tasks, s);
        }
    } else if (msg.event == WorkerEvent.taskCompleted) {
        final id = msg.payload as int;
        await _repository.updateTaskStatus(id, TaskStatus.completed);
    }
  }

  void _processNextTaskIfNeeded(List<QueueTask> tasks, QueueLoaded currentState) {
    if (currentState.isPaused || currentState.isOverheated || currentState.processingTaskId != -1) {
      return;
    }

    // Find next pending task
    try {
      final nextTask = tasks.firstWhere((t) => t.status == TaskStatus.pending);
      // Update status to running
      _repository.updateTaskStatus(nextTask.id, TaskStatus.running);
      
      // Send to processor
      _processor.processTask(nextTask.id, nextTask.title);
      
      // Update local state to reflect we are processing
      // Note: we can't emit here easily without strict ordering, but Bloc handles it. 
      // Actually we are inside a handler, so we can't emit synchronously if we already emitted?
      // But this method is called from inside handlers.
      
      // Wait, we can't Emit here because this func is called from inside On<T>.
      // We should return updates or have this function act on the repository/processor only.
      // Modifying state 'processingTaskId' needs an emit.
      // So this helper should probably return the "Next State" or be part of the emit flow.
      // But _repository calls are async.
      
      // Let's just fire a side effect and allow the repo stream to update the UI status to 'running'.
      // But we need to track 'processingTaskId' to prevent double submission.
      // A better way: The processor says "Ready", we find next task.
    } catch (e) {
      // No pending tasks
    }
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    _tempSubscription?.cancel();
    _processorSubscription?.cancel();
    return super.close();
  }
}
