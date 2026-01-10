
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/queue_bloc.dart';
import '../../logic/queue_state_event.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueueBloc, QueueState>(
      builder: (context, state) {
        bool isPaused = false;
        if (state is QueueLoaded) {
          isPaused = state.isPaused;
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  context.read<QueueBloc>().add(ToggleQueueProcessing());
                },
                icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                label: Text(isPaused ? 'Resume' : 'Pause'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPaused ? Colors.green.shade100 : Colors.amber.shade100,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: () async {
                  final controller = TextEditingController();
                  final name = await showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('New Task'),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Enter task name',
                        ),
                        onSubmitted: (value) {
                             Navigator.pop(context, value);
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                             Navigator.pop(context, controller.text);
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  );

                  if (name != null && name.isNotEmpty) {
                    if (context.mounted) {
                        context.read<QueueBloc>().add(AddTask(name));
                    }
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Task'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<QueueBloc>().add(ClearCompleted());
                },
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Clear Done'),
              ),
               const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<QueueBloc>().add(RestartAll());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Restart All'),
              ),
            ],
          ),
        );
      },
    );
  }
}
