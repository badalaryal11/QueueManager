
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/database.dart';
import 'data/queue_repository.dart';
import 'logic/background_processor.dart';
import 'logic/queue_bloc.dart';
import 'logic/queue_state_event.dart';
import 'services/temperature_service.dart';
import 'ui/main_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final database = AppDatabase();
  final repository = QueueRepository(database);
  final temperatureService = TemperatureService();
  final processor = BackgroundProcessor();

  runApp(MyApp(
    repository: repository,
    temperatureService: temperatureService,
    processor: processor,
  ));
}

class MyApp extends StatelessWidget {
  final QueueRepository repository;
  final TemperatureService temperatureService;
  final BackgroundProcessor processor;

  const MyApp({
    super.key,
    required this.repository,
    required this.temperatureService,
    required this.processor,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: repository),
      ],
      child: BlocProvider(
        create: (context) => QueueBloc(repository, temperatureService, processor)
          ..add(LoadTasks()), // Initial load
        child: MaterialApp(
          title: 'Queue Manager',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            textTheme: GoogleFonts.interTextTheme(),
          ),
          home: const MainScreen(),
        ),
      ),
    );
  }
}
