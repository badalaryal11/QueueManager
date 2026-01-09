
import 'package:flutter/material.dart';
import '../../data/database.dart';

class TaskListItem extends StatelessWidget {
  final QueueTask task;
  final bool isProcessing;
  final VoidCallback? onTap;

  const TaskListItem({
    super.key,
    required this.task,
    this.isProcessing = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help;

    switch (task.status) {
      case TaskStatus.pending:
        statusColor = Colors.grey;
        statusIcon = Icons.hourglass_empty;
        break;
      case TaskStatus.running:
        statusColor = Colors.blue;
        statusIcon = Icons.play_circle_fill;
        break;
      case TaskStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case TaskStatus.paused:
        statusColor = Colors.orange;
        statusIcon = Icons.pause_circle_filled;
        break;
    }

    return Card(
      key: ValueKey(task.id),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: isProcessing ? 4 : 1,
      shape: RoundedRectangleBorder(
        side: isProcessing ? const BorderSide(color: Colors.blue, width: 2) : BorderSide.none,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Status: ${task.status.name.toUpperCase()}'),
        trailing: const Icon(Icons.drag_handle),
        onTap: onTap,
      ),
    );
  }
}
