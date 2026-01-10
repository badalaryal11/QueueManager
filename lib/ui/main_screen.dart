
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/queue_repository.dart';
import '../logic/queue_bloc.dart';
import '../logic/queue_state_event.dart';
import 'widgets/control_panel.dart';
import 'widgets/task_list_item.dart';
import 'widgets/system_resource_widget.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Manager'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SystemResourceWidget(),
          const ControlPanel(),
          Expanded(
            child: BlocBuilder<QueueBloc, QueueState>(
              builder: (context, state) {
                if (state is QueueLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is QueueLoaded) {
                 final tasks = state.tasks;
                 
                  if (tasks.isEmpty) {
                    return const Center(child: Text('No tasks. Add one!'));
                  }

                  return ReorderableListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      // Highlight the task if it is the one currently being processed
                      final isProcessing = task.id == state.processingTaskId;
                      return TaskListItem(
                        key: ValueKey(task.id),
                        task: task,
                        isProcessing: isProcessing,
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                       final task = tasks[oldIndex];
                       context.read<QueueBloc>().add(ReorderTask(task.id, oldIndex, newIndex));
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          const Divider(),
          const WriteCountDisplay(),
        ],
      ),
    );
  }
}

class WriteCountDisplay extends StatelessWidget {
  const WriteCountDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    // Access repository directly for the write count stream
    final repository = RepositoryProvider.of<QueueRepository>(context);
    
    return StreamBuilder<int>(
      stream: repository.writeCountStream,
      initialData: repository.currentWriteCount,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'DB Writes: ${snapshot.data ?? 0}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      },
    );
  }
}
