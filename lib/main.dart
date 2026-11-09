import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_settings.dart';
import 'viewmodels/goals_viewmodel.dart';
import 'ui/save_goals_app.dart';
export 'ui/save_goals_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final settings = AppSettings();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GoalsViewModel()),
        ChangeNotifierProvider<AppSettings>.value(value: settings),
      ],
      child: const SaveGoalsApp(showLaunchScreen: true),
    ),
  );
}
