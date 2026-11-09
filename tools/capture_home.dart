// Render the real app widgets for the website, with clearly labelled demo data.
// Run: flutter test tools/capture_home.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show showCupertinoDialog;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fintrack/main.dart';
import 'package:fintrack/models/savings_goal.dart';
import 'package:fintrack/models/savings_transaction.dart';
import 'package:fintrack/providers/app_settings.dart';
import 'package:fintrack/viewmodels/goals_viewmodel.dart';

class PreviewSettings extends AppSettings {
  @override
  bool get blackTheme => const bool.fromEnvironment('CAPTURE_BLACK');
  @override
  ThemeMode get themeMode => const bool.fromEnvironment('CAPTURE_DARK')
      ? ThemeMode.dark
      : ThemeMode.light;
}

class PreviewGoals extends GoalsViewModel {
  // Illustrative history reconciles to the goal balances: 45,000 in, 2,500 out.
  @override
  List<SavingsTransaction> get transactions {
    final now = DateTime.now();
    return [
      SavingsTransaction(
        goalId: 1,
        amount: 1000,
        type: TransactionType.deposit,
        date: now,
      ),
      SavingsTransaction(
        goalId: 1,
        amount: 2000,
        type: TransactionType.deposit,
        date: now.subtract(const Duration(days: 1)),
      ),
      SavingsTransaction(
        goalId: 1,
        amount: 2000,
        type: TransactionType.deposit,
        date: now.subtract(const Duration(days: 2)),
      ),
      SavingsTransaction(
        goalId: 1,
        amount: 2500,
        type: TransactionType.withdrawal,
        date: now.subtract(const Duration(days: 3)),
      ),
      SavingsTransaction(
        goalId: 2,
        amount: 2500,
        type: TransactionType.deposit,
        date: now.subtract(const Duration(days: 6)),
      ),
      SavingsTransaction(
        goalId: 2,
        amount: 7500,
        type: TransactionType.deposit,
        date: DateTime(now.year, now.month - 2, 10),
      ),
      SavingsTransaction(
        goalId: 1,
        amount: 30000,
        type: TransactionType.deposit,
        date: DateTime(now.year, now.month - 5, 5),
      ),
    ];
  }

  bool empty = false;
  void showEmpty() {
    empty = true;
    notifyListeners();
  }

  @override
  SavingsGoal? getGoalById(int id) {
    for (final goal in goals) {
      if (goal.id == id) return goal;
    }
    return null;
  }

  @override
  List<SavingsGoal> get goals => empty
      ? []
      : [
          SavingsGoal(
            id: 1,
            name: 'Emergency fund',
            targetAmount: 50000,
            savedAmount: 32500,
            deadline: DateTime(2027, 6, 1),
            createdAt: DateTime(2026, 1, 1),
            emoji: '🌱',
          ),
          SavingsGoal(
            id: 2,
            name: 'Learning & books',
            targetAmount: 25000,
            savedAmount: 10000,
            deadline: DateTime(2027, 8, 1),
            createdAt: DateTime(2026, 1, 1),
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
        'SavingsSans',
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
      final manrope = FontLoader('Manrope');
      manrope.addFont(rootBundle.load('assets/fonts/manrope.ttf'));
      await manrope.load();
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
        tester.element(find.byType(HomePage)),
      ),
    );
    await tester.pumpAndSettle();
    if (const bool.fromEnvironment('CAPTURE_ALL')) {
      Future<void> saveFrame(String name) async {
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: name);
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          const directory = String.fromEnvironment(
            'CAPTURE_DIRECTORY',
            defaultValue: 'output/redesign-1.3',
          );
          final file = File('$directory/$name.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      final c = tester.element(find.byType(HomePage));
      final vm = c.read<GoalsViewModel>();
      await saveFrame('home');
      for (var i = 1; i < 4; i++) {
        await tester.tap(find.byKey(ValueKey('tab-$i')));
        await saveFrame(['home', 'goals', 'activity', 'settings'][i]);
      }
      await tester.tap(find.byKey(const ValueKey('tab-0')));
      await tester.pumpAndSettle();
      for (final entry in <String, Widget>{
        'goal': GoalDetail(vm.goals.first),
        'edit-goal': GoalEditor(goal: vm.goals.first),
        'entry': const TransactionEditor(goalId: 1),
        'withdraw': const TransactionEditor(goalId: 1, withdraw: true),
        'new-goal': const GoalEditor(),
        'share': ProgressSharePage(vm.goals.first),
        'paywall': const PaywallPreview(),
      }.entries) {
        openPage(c, entry.value);
        await tester.pumpAndSettle();
        if (entry.key == 'entry' || entry.key == 'withdraw') {
          await tester.enterText(
            find.byKey(const ValueKey('entry-Amount')),
            entry.key == 'entry' ? '500' : '1000',
          );
          FocusManager.instance.primaryFocus?.unfocus();
        } else if (entry.key == 'edit-goal') {
          await tester.ensureVisible(find.text('Delete Goal'));
        } else if (entry.key == 'new-goal') {
          await tester.enterText(
            find.byKey(const ValueKey('entry-Goal name')),
            'New laptop',
          );
          await tester.enterText(
            find.byKey(const ValueKey('entry-Target amount')),
            '100000',
          );
          FocusManager.instance.primaryFocus?.unfocus();
        }
        await saveFrame(entry.key);
        Navigator.of(c, rootNavigator: true).pop();
        await tester.pumpAndSettle();
      }
      final future = showCupertinoDialog<void>(
        context: c,
        builder: (_) => MilestoneDialog(vm.goals.first, 50),
      );
      await saveFrame('milestone');
      Navigator.of(c, rootNavigator: true).pop();
      await future;
      await tester.pumpAndSettle();
      (vm as PreviewGoals).showEmpty();
      await tester.tap(find.byKey(const ValueKey('tab-1')));
      await saveFrame('empty-goals');
      return;
    }
    if (const bool.fromEnvironment('CAPTURE_SPLASH')) {
      final c = tester.element(find.byType(HomePage));
      openPage(
        c,
        MediaQuery(
          data: MediaQuery.of(c).copyWith(disableAnimations: true),
          child: const LaunchScreen(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => precacheImage(
          const AssetImage('assets/branding/sprout_lockup.png'),
          tester.element(find.byType(LaunchScreen)),
        ),
      );
      await tester.pumpAndSettle();
    }
    const screen = String.fromEnvironment('CAPTURE_SCREEN');
    if (screen == 'goals' || screen == 'activity' || screen == 'settings') {
      await tester.tap(
        find.byKey(
          ValueKey(
            screen == 'goals'
                ? 'tab-1'
                : screen == 'activity'
                ? 'tab-2'
                : 'tab-3',
          ),
        ),
      );
      await tester.pumpAndSettle();
    }
    if (screen == 'entry' || screen == 'new-goal') {
      openPage(
        tester.element(find.byType(HomePage)),
        screen == 'entry'
            ? const TransactionEditor(goalId: 1)
            : const GoalEditor(),
      );
      await tester.pumpAndSettle();
      if (screen == 'entry') {
        await tester.enterText(
          find.byKey(const ValueKey('entry-Amount')),
          '500',
        );
        await tester.pumpAndSettle();
      }
    }
    if (const bool.fromEnvironment('CAPTURE_PAYWALL')) {
      openPage(tester.element(find.byType(HomePage)), const PaywallPreview());
      await tester.pumpAndSettle();
    }
    if (const bool.fromEnvironment('CAPTURE_SHARE')) {
      final context = tester.element(find.byType(HomePage));
      openPage(
        context,
        ProgressSharePage(context.read<GoalsViewModel>().goals.first),
      );
      await tester.pumpAndSettle();
    }
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
