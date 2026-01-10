
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/queue_bloc.dart';
import '../../logic/queue_state_event.dart';

class SystemResourceWidget extends StatelessWidget {
  const SystemResourceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueueBloc, QueueState>(
      buildWhen: (previous, current) {
        if (current is QueueLoaded && previous is QueueLoaded) {
          return previous.cpuUsage != current.cpuUsage || 
                 previous.ramUsage != current.ramUsage ||
                 previous.isOverloaded != current.isOverloaded;
        }
        return true;
      },
      builder: (context, state) {
        if (state is QueueLoaded) {
          final cpu = state.cpuUsage;
          final ram = state.ramUsage;
          final temp = state.temperature;
          final isOverloaded = state.isOverloaded;

          Color color = Colors.green;
          if (isOverloaded) {
            color = Colors.red;
          } else if (cpu > 60.0 || ram > 60.0 || temp > 60.0) {
            color = Colors.orange;
          }

          return Card(
            elevation: 2,
            margin: const EdgeInsets.all(8.0),
            color: isOverloaded ? Colors.red.shade50 : null,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                        Icon(Icons.memory, color: color),
                        const SizedBox(width: 8),
                        Text('System Resources', style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildIndicator(context, 'CPU', cpu, color),
                  const SizedBox(height: 8),
                  _buildIndicator(context, 'RAM', ram, color),
                  const SizedBox(height: 8),
                  _buildTempIndicator(context, 'Temp', temp, color),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildIndicator(BuildContext context, String label, double value, Color color) {
      return Row(
        children: [
            SizedBox(width: 40, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
            Expanded(
                child: LinearProgressIndicator(
                    value: value / 100.0,
                    color: color,
                    backgroundColor: Colors.grey.shade200,
                ),
            ),
            const SizedBox(width: 12),
            SizedBox(
                width: 60, 
                child: Text('${value.toStringAsFixed(1)}%', textAlign: TextAlign.end),
            ),
        ],
      );
  }

  Widget _buildTempIndicator(BuildContext context, String label, double value, Color color) {
      // Temp usually ranges 30-100 C. Normalize 0-100 for bar? 
      // Or just show value. User wanted "CPU Temperature".
      return Row(
        children: [
            SizedBox(width: 40, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
            Expanded(
                child: LinearProgressIndicator(
                    value: (value).clamp(0.0, 100.0) / 100.0, 
                    color: color,
                    backgroundColor: Colors.grey.shade200,
                ),
            ),
            const SizedBox(width: 12),
            SizedBox(
                width: 60, 
                child: Text('${value.toStringAsFixed(1)}°C', textAlign: TextAlign.end),
            ),
        ],
      );
  }
}
