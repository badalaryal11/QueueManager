import 'package:equatable/equatable.dart';
import '../data/database.dart';

abstract class QueueEvent extends Equatable {
  const QueueEvent();
}

class LoadTasks extends QueueEvent {
  @override
  List<Object> get props => [];
}

class TasksUpdated extends QueueEvent {
  final List<QueueTask> tasks;
  const TasksUpdated(this.tasks);
  @override
  List<Object> get props => [tasks];
}

class AddTask extends QueueEvent {
  final String title;
  const AddTask(this.title);
  @override
  List<Object> get props => [title];
}

class ReorderTask extends QueueEvent {
  final int taskId;
  final int oldIndex;
  final int newIndex;
  const ReorderTask(this.taskId, this.oldIndex, this.newIndex);
  @override
  List<Object> get props => [taskId, oldIndex, newIndex];
}

class ToggleQueueProcessing extends QueueEvent {
  @override
  List<Object> get props => [];
}

class ClearCompleted extends QueueEvent {
  @override
  List<Object> get props => [];
}

class RestartAll extends QueueEvent {
  @override
  List<Object> get props => [];
}


class SystemResourcesUpdated extends QueueEvent {
  final double cpuUsage;
  final double ramUsage;
  const SystemResourcesUpdated(this.cpuUsage, this.ramUsage);
  @override
  List<Object> get props => [cpuUsage, ramUsage];
}

class ProcessorMessageReceived extends QueueEvent {
  final dynamic message;
  const ProcessorMessageReceived(this.message);
  @override
  List<Object> get props => [message ?? ''];
}

abstract class QueueState extends Equatable {
  const QueueState();
}

class QueueLoading extends QueueState {
  @override
  List<Object> get props => [];
}

class QueueLoaded extends QueueState {
  final List<QueueTask> tasks;
  final double cpuUsage;
  final double ramUsage;
  final bool isPaused;
  final bool isOverloaded;
  final int processingTaskId; // ID of task currently being processed

  const QueueLoaded({
    this.tasks = const [],
    this.cpuUsage = 0.0,
    this.ramUsage = 0.0,
    this.isPaused = false,
    this.isOverloaded = false,
    this.processingTaskId = -1,
  });

  QueueLoaded copyWith({
    List<QueueTask>? tasks,
    double? cpuUsage,
    double? ramUsage,
    bool? isPaused,
    bool? isOverloaded,
    int? processingTaskId,
  }) {
    return QueueLoaded(
      tasks: tasks ?? this.tasks,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      ramUsage: ramUsage ?? this.ramUsage,
      isPaused: isPaused ?? this.isPaused,
      isOverloaded: isOverloaded ?? this.isOverloaded,
      processingTaskId: processingTaskId ?? this.processingTaskId,
    );
  }

  @override
  List<Object> get props => [tasks, cpuUsage, ramUsage, isPaused, isOverloaded, processingTaskId];
}
