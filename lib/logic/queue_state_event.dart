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

class TemperatureUpdated extends QueueEvent {
  final double temperature;
  const TemperatureUpdated(this.temperature);
  @override
  List<Object> get props => [temperature];
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
  final double temperature;
  final bool isPaused;
  final bool isOverheated;
  final int processingTaskId; // ID of task currently being processed

  const QueueLoaded({
    this.tasks = const [],
    this.temperature = 0.0,
    this.isPaused = false,
    this.isOverheated = false,
    this.processingTaskId = -1,
  });

  QueueLoaded copyWith({
    List<QueueTask>? tasks,
    double? temperature,
    bool? isPaused,
    bool? isOverheated,
    int? processingTaskId,
  }) {
    return QueueLoaded(
      tasks: tasks ?? this.tasks,
      temperature: temperature ?? this.temperature,
      isPaused: isPaused ?? this.isPaused,
      isOverheated: isOverheated ?? this.isOverheated,
      processingTaskId: processingTaskId ?? this.processingTaskId,
    );
  }

  @override
  List<Object> get props => [tasks, temperature, isPaused, isOverheated, processingTaskId];
}
