import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_settings.dart';
import 'services/notification_service.dart';
import 'viewmodels/goals_viewmodel.dart';
import 'ui/save_goals_app.dart';
export 'ui/save_goals_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final settings = AppSettings();
  await settings.loadSettings();
  try {
    await NotificationService.instance.initialize();
  } catch (_) {
    // Reminders are optional; their setup must never block access to savings.
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GoalsViewModel()..loadData()),
        ChangeNotifierProvider<AppSettings>.value(value: settings),
      ],
      child: const SaveGoalsApp(),
    ),
  );
}
