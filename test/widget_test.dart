import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fintrack/main.dart';
import 'package:fintrack/models/savings_goal.dart';
import 'package:fintrack/models/savings_transaction.dart';
import 'package:fintrack/providers/app_settings.dart';
import 'package:fintrack/viewmodels/goals_viewmodel.dart';

// Isolates UI interactions from platform SQLite, with the same notification flow.
class MemoryGoals extends GoalsViewModel {
  final List<SavingsGoal> records = [];
  final List<SavingsTransaction> entries = [];
  @override
  List<SavingsGoal> get goals => List.unmodifiable(records);
  @override
  List<SavingsTransaction> get transactions => List.unmodifiable(entries);
  @override
  double get totalSaved => records.fold(0, (a, g) => a + g.savedAmount);
  @override
  double get totalTarget => records.fold(0, (a, g) => a + g.targetAmount);
  @override
  double get totalRemaining => records.fold(0, (a, g) => a + g.remainingAmount);
  @override
  int get activeGoals => records.where((g) => !g.isCompleted).length;
  @override
  int get completedGoals => records.where((g) => g.isCompleted).length;
  @override
  double get overallProgress =>
      totalTarget == 0 ? 0 : (totalSaved / totalTarget).clamp(0, 1);
  @override
  SavingsGoal? getGoalById(int id) {
    for (final g in records) {
      if (g.id == id) return g;
    }
    return null;
  }

  @override
  Future<void> addGoal(SavingsGoal goal) async {
    records.add(goal.copyWith(id: records.length + 1));
    notifyListeners();
  }

  @override
  Future<void> updateGoal(SavingsGoal goal) async {
    records[records.indexWhere((g) => g.id == goal.id)] = goal;
    notifyListeners();
  }

  @override
  Future<void> deleteGoal(int id) async {
    records.removeWhere((g) => g.id == id);
    entries.removeWhere((tx) => tx.goalId == id);
    notifyListeners();
  }

  @override
  Future<void> addDeposit({
    required int goalId,
    required double amount,
    String? note,
    DateTime? date,
  }) async => _record(goalId, amount, false, note, date);
  @override
  Future<void> addWithdrawal({
    required int goalId,
    required double amount,
    String? note,
    DateTime? date,
  }) async => _record(goalId, amount, true, note, date);
  void _record(
    int id,
    double amount,
    bool withdrawal,
    String? note,
    DateTime? date,
  ) {
    final index = records.indexWhere((g) => g.id == id);
    records[index] = records[index].copyWith(
      savedAmount: records[index].savedAmount + (withdrawal ? -amount : amount),
    );
    entries.insert(
      0,
      SavingsTransaction(
        id: entries.length + 1,
        goalId: id,
        type: withdrawal ? TransactionType.withdrawal : TransactionType.deposit,
        amount: amount,
        date: date ?? DateTime.now(),
        note: note,
      ),
    );
    notifyListeners();
  }
}

Future<void> mount(
  WidgetTester tester,
  MemoryGoals vm, {
  double width = 390,
  ThemeMode theme = ThemeMode.light,
  String language = 'en',
}) async {
  SharedPreferences.setMockInitialValues({});
  final settings = AppSettings();
  await settings.setTheme(theme);
  await settings.setLanguage(language);
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<GoalsViewModel>.value(value: vm),
        ChangeNotifierProvider<AppSettings>.value(value: settings),
      ],
      child: const SaveGoalsApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> goTab(WidgetTester tester, IconData icon) async {
  await tester.tap(
    find
        .descendant(
          of: find.byType(CupertinoTabBar),
          matching: find.byIcon(icon),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

SavingsGoal example({double saved = 200}) => SavingsGoal(
  id: 1,
  name: 'My course',
  targetAmount: 1000,
  savedAmount: saved,
  deadline: DateTime.now().add(const Duration(days: 90)),
  createdAt: DateTime.now(),
);

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets(
      'Platform parity ${platform.name}',
      (tester) async {
        await mount(tester, MemoryGoals()..records.add(example()), width: 390);
        tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
        addTearDown(tester.view.resetPadding);
        await tester.pumpAndSettle();
        expect(
          tester.getTopLeft(find.text('Overview')).dy,
          greaterThanOrEqualTo(44),
        );
        expect(find.text('Savings Goals'), findsOneWidget);
        expect(find.byType(MomentumHeader), findsOneWidget);
        await goTab(tester, CupertinoIcons.flag);
        expect(find.byType(GoalTile), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant({platform}),
    );
  }
  testWidgets(
    'Share card excludes financial details and defaults to anonymous',
    (tester) async {
      final goal = example(saved: 600);
      final vm = MemoryGoals()..records.add(goal);
      await mount(tester, vm, width: 320);
      openPage(tester.element(find.byType(HomePage)), ProgressSharePage(goal));
      await tester.pumpAndSettle();
      final card = find.byType(AchievementCard);
      expect(
        find.descendant(of: card, matching: find.text('My course')),
        findsNothing,
      );
      expect(
        find.descendant(of: card, matching: find.textContaining('600')),
        findsNothing,
      );
      expect(
        find.descendant(of: card, matching: find.text('60%')),
        findsOneWidget,
      );
      await tester.ensureVisible(find.byType(CupertinoSwitch));
      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: card, matching: find.text('My course')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Safe area and status icons follow the selected theme', (
    tester,
  ) async {
    await mount(tester, MemoryGoals(), width: 320, theme: ThemeMode.dark);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetPadding);
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Overview')).dy,
      greaterThanOrEqualTo(44),
    );
    final regions = tester.widgetList<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
    );
    expect(
      regions.any((r) => r.value.statusBarIconBrightness == Brightness.light),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
  for (final width in [320.0, 390.0]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      for (final language in ['en', 'ur']) {
        testWidgets('Cupertino tabs ${width.toInt()} ${mode.name} $language', (
          tester,
        ) async {
          final vm = MemoryGoals()..records.add(example());
          await mount(
            tester,
            vm,
            width: width,
            theme: mode,
            language: language,
          );
          expect(find.byType(CupertinoApp), findsOneWidget);
          expect(tester.takeException(), isNull);
          for (final icon in [
            CupertinoIcons.flag,
            CupertinoIcons.chart_bar,
            CupertinoIcons.settings,
          ]) {
            await goTab(tester, icon);
            expect(tester.takeException(), isNull);
          }
          expect(find.text('AILANGA SCHOOL PROJECT'), findsOneWidget);
          final context = tester.element(find.byType(CupertinoTabBar));
          expect(
            CupertinoTheme.of(context).brightness,
            mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
          );
        });
      }
    }
  }
  testWidgets('Create goal and validate invalid amounts', (tester) async {
    final vm = MemoryGoals();
    await mount(tester, vm);
    await tester.tap(find.byIcon(CupertinoIcons.plus).first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(CupertinoTextField, 'Goal name'),
      'New laptop',
    );
    await tester.enterText(
      find.widgetWithText(CupertinoTextField, 'Target amount'),
      'NaN',
    );
    final save = find.text('Save goal');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(vm.goals, isEmpty);
    expect(
      find.text(
        'Enter a name, a positive amount, and a date from today onwards.',
      ),
      findsOneWidget,
    );
    await tester.enterText(
      find.widgetWithText(CupertinoTextField, 'Target amount'),
      '2500',
    );
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(vm.goals.single.name, 'New laptop');
    expect(vm.goals.single.targetAmount, 2500);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Deposit crosses milestone and withdrawal validates balance', (
    tester,
  ) async {
    final vm = MemoryGoals()..records.add(example());
    await mount(tester, vm);
    // Open the actual detail route without depending on the home scroll position.
    final context = tester.element(find.byType(HomePage));
    openPage(context, GoalDetail(vm.goals.first));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Add savings'));
    await tester.tap(find.text('Add savings'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(CupertinoTextField, 'Amount'),
      '100',
    );
    await tester.ensureVisible(find.text('Save deposit'));
    await tester.tap(find.text('Save deposit'));
    await tester.pumpAndSettle();
    expect(find.text('A milestone worth celebrating'), findsOneWidget);
    expect(vm.goals.single.savedAmount, 300);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Record a withdrawal'));
    await tester.tap(find.text('Record a withdrawal'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(CupertinoTextField, 'Amount'),
      '500',
    );
    await tester.ensureVisible(find.text('Confirm withdrawal'));
    await tester.tap(find.text('Confirm withdrawal'));
    await tester.pumpAndSettle();
    expect(
      find.text('Withdrawal cannot exceed the saved amount.'),
      findsOneWidget,
    );
    expect(vm.goals.single.savedAmount, 300);
    await tester.enterText(
      find.widgetWithText(CupertinoTextField, 'Amount'),
      '100',
    );
    await tester.ensureVisible(find.text('Confirm withdrawal'));
    await tester.tap(find.text('Confirm withdrawal'));
    await tester.pumpAndSettle();
    expect(vm.goals.single.savedAmount, 200);
    expect(vm.transactions.length, 2);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Appearance selection updates immediately', (tester) async {
    await mount(tester, MemoryGoals());
    await goTab(tester, CupertinoIcons.settings);
    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(
      CupertinoTheme.of(
        tester.element(find.byType(CupertinoTabBar)),
      ).brightness,
      Brightness.dark,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('Language changes update previously opened tabs', (tester) async {
    await mount(tester, MemoryGoals());
    await goTab(tester, CupertinoIcons.flag);
    await goTab(tester, CupertinoIcons.settings);
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اردو'));
    await tester.pumpAndSettle();
    expect(find.text('سرگرمی'), findsOneWidget);
    await goTab(tester, CupertinoIcons.flag);
    expect(find.text('فعال'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Existing savings cannot be lost by lowering a target', (
    tester,
  ) async {
    final vm = MemoryGoals()..records.add(example(saved: 600));
    await mount(tester, vm, width: 320);
    openPage(
      tester.element(find.byType(HomePage)),
      GoalEditor(goal: vm.goals.first),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(CupertinoTextField, 'Target amount'),
      '500',
    );
    await tester.ensureVisible(find.text('Save goal'));
    await tester.tap(find.text('Save goal'));
    await tester.pumpAndSettle();
    expect(
      find.text('Target cannot be lower than the amount already saved.'),
      findsOneWidget,
    );
    expect(vm.goals.single.targetAmount, 1000);
    expect(tester.takeException(), isNull);
  });
}
