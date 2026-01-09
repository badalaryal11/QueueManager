
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/queue_bloc.dart';
import '../../logic/queue_state_event.dart';

class TemperatureWidget extends StatelessWidget {
  const TemperatureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueueBloc, QueueState>(
      buildWhen: (previous, current) {
        if (current is QueueLoaded && previous is QueueLoaded) {
          return previous.temperature != current.temperature || 
                 previous.isOverheated != current.isOverheated;
        }
        return true;
      },
      builder: (context, state) {
        if (state is QueueLoaded) {
          final temp = state.temperature;
          final isOverheated = state.isOverheated;

          Color color = Colors.green;
          if (temp > 80.0) {
            color = Colors.red;
          } else if (temp > 60.0) {
            color = Colors.orange;
          }

          return Card(
            elevation: 2,
            margin: const EdgeInsets.all(8.0),
            color: isOverheated ? Colors.red.shade50 : null,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CPU Temperature', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(
                        '${temp.toStringAsFixed(1)} °C',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.thermostat,
                    size: 40,
                    color: color,
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
