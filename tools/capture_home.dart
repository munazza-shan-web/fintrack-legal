// Render the real app widgets for the website, with clearly labelled demo data.
// Run: flutter test tools/capture_home.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fintrack/main.dart';
import 'package:fintrack/models/savings_goal.dart';
import 'package:fintrack/providers/app_settings.dart';
import 'package:fintrack/viewmodels/goals_viewmodel.dart';

class PreviewSettings extends AppSettings {
  @override
  ThemeMode get themeMode => const bool.fromEnvironment('CAPTURE_DARK')
      ? ThemeMode.dark
      : ThemeMode.light;
}

class PreviewGoals extends GoalsViewModel {
  @override
  List<SavingsGoal> get goals => [
    SavingsGoal(
      id: 1,
      name: 'Emergency fund',
      targetAmount: 50000,
      savedAmount: 32500,
      deadline: DateTime(2027, 6, 1),
      createdAt: DateTime(2026, 10, 1),
      emoji: '🌱',
    ),
    SavingsGoal(
      id: 2,
      name: 'Learning & books',
      targetAmount: 25000,
      savedAmount: 10000,
      deadline: DateTime(2027, 8, 1),
      createdAt: DateTime(2026, 10, 1),
      emoji: '📚',
    ),
  ];
  @override
  double get totalSaved => 42500;
  @override
  double get totalTarget => 75000;
  @override
  double get totalRemaining => 32500;
  @override
  int get activeGoals => 2;
  @override
  double get overallProgress => totalSaved / totalTarget;
}

void main() {
  testWidgets('Capture actual home widgets for landing page', (tester) async {
    final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? r'C:\flutter';
    await tester.runAsync(() async {
      for (final family in [
        'Roboto',
        'CupertinoSystemText',
        'CupertinoSystemDisplay',
      ]) {
        final fonts = FontLoader(family);
        for (final weight in ['regular', 'medium', 'bold', 'black']) {
          fonts.addFont(
            File(
              '$flutterRoot/bin/cache/artifacts/material_fonts/roboto-$weight.ttf',
            ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
          );
        }
        await fonts.load();
      }
      final cupertino = FontLoader('packages/cupertino_icons/CupertinoIcons');
      cupertino.addFont(
        rootBundle.load('packages/cupertino_icons/assets/CupertinoIcons.ttf'),
      );
      await cupertino.load();
      final icons = FontLoader('MaterialIcons');
      icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey();
    final settings = PreviewSettings();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<GoalsViewModel>(
              create: (_) => PreviewGoals(),
            ),
            ChangeNotifierProvider<AppSettings>.value(value: settings),
          ],
          child: const SaveGoalsApp(),
        ),
      ),
    );
    await tester.runAsync(
      () => precacheImage(
        const AssetImage('assets/branding/save_goals_icon.png'),
        tester.element(find.byType(AppHeader)),
      ),
    );
    await tester.pumpAndSettle();
    if (const bool.fromEnvironment('CAPTURE_GOAL')) {
      final context = tester.element(find.byType(HomePage));
      openPage(context, GoalDetail(context.read<GoalsViewModel>().goals.first));
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final output = File(
        const String.fromEnvironment(
          'CAPTURE_OUTPUT',
          defaultValue: 'assets/screenshots/home-screen.png',
        ),
      );
      await output.parent.create(recursive: true);
      await output.writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  });
}
