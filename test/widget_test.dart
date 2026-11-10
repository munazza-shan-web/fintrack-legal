import 'dart:async';
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

class DeferredGoals extends MemoryGoals {
  final ready = Completer<void>();
  @override
  Future<void> loadData() => ready.future;
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
  await tester.tap(find.byIcon(icon).last);
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
  setUpAll(() async {
    final font = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/fonts/manrope.ttf'));
    await font.load();
  });
  testWidgets(
    'Delete is below Save in Edit and confirmation returns to the goals root',
    (tester) async {
      final vm = MemoryGoals()..records.add(example());
      vm.entries.add(
        SavingsTransaction(
          goalId: 1,
          amount: 200,
          type: TransactionType.deposit,
          date: DateTime.now(),
        ),
      );
      await mount(tester, vm);
      openPage(
        tester.element(find.byType(HomePage)),
        GoalDetail(vm.goals.first),
      );
      await tester.pumpAndSettle();
      expect(find.text('Delete Goal'), findsNothing);
      final add = find.text('Add savings');
      final withdraw = find.text('Withdrawal');
      expect(
        tester.getCenter(add).dy,
        closeTo(tester.getCenter(withdraw).dy, 3),
      );
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Delete Goal'));
      expect(
        tester.getTopLeft(find.text('Delete Goal')).dy,
        greaterThan(tester.getTopLeft(find.text('Save goal')).dy),
      );
      await tester.tap(find.text('Delete Goal'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(vm.records, hasLength(1));
      expect(vm.entries, hasLength(1));
      await tester.tap(find.text('Delete Goal'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(vm.records, isEmpty);
      expect(vm.entries, isEmpty);
      expect(find.byType(GoalEditor), findsNothing);
      expect(find.byType(GoalDetail), findsNothing);
      expect(find.byType(MainScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'B navigation shows only the active label and retains all accessible tabs',
    (tester) async {
      await mount(tester, MemoryGoals(), width: 320);
      final bar = find.byType(FloatingNavigation);
      expect(
        find.descendant(of: bar, matching: find.byType(Text)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: bar, matching: find.text('Home')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Settings'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.leaf_arrow_circlepath), findsNothing);
      await tester.tap(find.byKey(const ValueKey('tab-3')));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: bar, matching: find.text('Settings')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: bar, matching: find.text('Home')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Splash waits for real initialization then leaves without a fixed delay',
    (tester) async {
      final vm = DeferredGoals();
      await mount(tester, vm);
      openPage(tester.element(find.byType(HomePage)), const StartupGate());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(LaunchScreen), findsOneWidget);
      expect(find.bySemanticsLabel('Loading your goals'), findsOneWidget);
      vm.ready.complete();
      await tester.pumpAndSettle();
      expect(find.byType(LaunchScreen), findsNothing);
      expect(find.byType(MainScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Splash respects reduced motion', (tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: LaunchScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LaunchDots), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Target amount groups digits and explains the magnitude live', (
    tester,
  ) async {
    final vm = MemoryGoals();
    await mount(tester, vm);
    openPage(tester.element(find.byType(HomePage)), const GoalEditor());
    await tester.pumpAndSettle();
    final field = find.byKey(const ValueKey('entry-Target amount'));
    await tester.enterText(field, '100000');
    await tester.pumpAndSettle();
    expect(
      tester.widget<CupertinoTextField>(field).controller!.text,
      '100,000',
    );
    expect(find.text('One hundred thousand (1 lakh)'), findsOneWidget);
    expect(vm.records, isEmpty);
    await tester.enterText(field, '10000');
    await tester.pumpAndSettle();
    expect(find.text('Ten thousand'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Floating navigation, prominent real streak and matching activity cards',
    (tester) async {
      final vm = MemoryGoals()..records.add(example());
      for (var i = 0; i < 3; i++) {
        vm.entries.add(
          SavingsTransaction(
            goalId: 1,
            amount: 10,
            type: TransactionType.deposit,
            date: DateTime.now().subtract(Duration(days: i)),
          ),
        );
      }
      await mount(tester, vm, width: 320);
      expect(find.text('3 days'), findsOneWidget);
      expect(find.byKey(const ValueKey('home-streak')), findsOneWidget);
      final nav = find.byKey(const ValueKey('floating-navigation'));
      expect(tester.getRect(nav).left, greaterThan(0));
      expect(tester.getRect(nav).bottom, lessThan(844));
      expect(find.byType(BackdropFilter), findsOneWidget);
      for (final icon in [
        CupertinoIcons.flag,
        CupertinoIcons.chart_bar,
        CupertinoIcons.settings,
      ]) {
        await goTab(tester, icon);
        expect(find.byIcon(CupertinoIcons.back), findsNothing);
      }
      await goTab(tester, CupertinoIcons.chart_bar);
      final saved = find.byKey(const ValueKey('monthly-deposits'));
      final withdrawn = find.byKey(const ValueKey('monthly-withdrawals'));
      expect(tester.getSize(saved), tester.getSize(withdrawn));
      await tester.tap(withdrawn);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SavingsSegments<int>>(find.byType(SavingsSegments<int>))
            .groupValue,
        2,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Black appearance persists and uses a black canvas', (
    tester,
  ) async {
    await mount(tester, MemoryGoals());
    final c = tester.element(find.byType(HomePage));
    await c.read<AppSettings>().setAppearance('black');
    await tester.pumpAndSettle();
    expect(
      canvas(tester.element(find.byType(HomePage))),
      const Color(0xFF000000),
    );
    final loaded = AppSettings();
    await loaded.loadSettings();
    expect(loaded.appearanceLabel, 'Black');
    expect(loaded.themeMode, ThemeMode.dark);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Keypad previews the balance and leaves records unchanged before saving',
    (tester) async {
      final vm = MemoryGoals()..records.add(example());
      await mount(tester, vm);
      openPage(
        tester.element(find.byType(HomePage)),
        const TransactionEditor(goalId: 1),
      );
      await tester.pumpAndSettle();
      for (final key in ['1', '0', '0']) {
        final keyButton = find.descendant(
          of: find.byType(AmountKeypad),
          matching: find.text(key),
        );
        await tester.ensureVisible(keyButton);
        await tester.tap(keyButton);
        await tester.pumpAndSettle();
      }
      final field = tester.widget<CupertinoTextField>(
        find.byKey(const ValueKey('entry-Amount')),
      );
      expect(field.controller!.text, '100');
      expect(find.text('After this entry: \$ 300'), findsOneWidget);
      expect(vm.goals.single.savedAmount, 200);
      await tester.tap(find.byIcon(CupertinoIcons.delete_left));
      await tester.pumpAndSettle();
      expect(field.controller!.text, '10');
      expect(vm.entries, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
  for (final width in [320.0, 390.0]) {
    testWidgets('Free app paywall preview is inert and localized at $width', (
      tester,
    ) async {
      await mount(tester, MemoryGoals(), width: width, theme: ThemeMode.dark);
      expect(find.byType(PaywallPreview), findsNothing);
      openPage(tester.element(find.byType(HomePage)), const PaywallPreview());
      await tester.pumpAndSettle();
      expect(find.text('Restore purchases'), findsOneWidget);
      expect(find.textContaining('\$29.99 / year'), findsOneWidget);
      await tester.tap(find.text('UK · GBP'));
      await tester.pumpAndSettle();
      expect(find.textContaining('£24.99 / year'), findsOneWidget);
      await tester.ensureVisible(find.text('Start 7-day free trial'));
      await tester.tap(find.text('Start 7-day free trial'));
      await tester.pumpAndSettle();
      expect(find.text('Preview only'), findsOneWidget);
      await tester.tap(find.text('Done').last);
      await tester.pumpAndSettle();
      expect(find.byType(PaywallPreview), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets(
      'Platform parity ${platform.name}',
      (tester) async {
        await mount(tester, MemoryGoals()..records.add(example()), width: 390);
        tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
        addTearDown(tester.view.resetPadding);
        await tester.pumpAndSettle();
        expect(
          tester.getTopLeft(find.text('Make progress, your way.')).dy,
          greaterThanOrEqualTo(44),
        );
        expect(find.text('Saving Goals'), findsOneWidget);
        expect(find.byType(SavingsSprout), findsOneWidget);
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
      tester.getTopLeft(find.text('Make progress, your way.')).dy,
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
          final context = tester.element(find.byType(MainScreen));
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
    await tester.enterText(find.byKey(const ValueKey('entry-Amount')), '100');
    await tester.ensureVisible(find.text('Save deposit'));
    await tester.tap(find.text('Save deposit'));
    await tester.pumpAndSettle();
    expect(find.text('A milestone worth celebrating'), findsOneWidget);
    expect(vm.goals.single.savedAmount, 300);
    await tester.tap(find.text('Keep saving'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Withdrawal'));
    await tester.tap(find.text('Withdrawal'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('entry-Amount')), '500');
    await tester.ensureVisible(find.text('Confirm withdrawal'));
    await tester.tap(find.text('Confirm withdrawal'));
    await tester.pumpAndSettle();
    expect(
      find.text('Withdrawal cannot exceed the saved amount.'),
      findsOneWidget,
    );
    expect(vm.goals.single.savedAmount, 300);
    await tester.enterText(find.byKey(const ValueKey('entry-Amount')), '100');
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
      CupertinoTheme.of(tester.element(find.byType(MainScreen))).brightness,
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
    expect(find.bySemanticsLabel('سرگرمی'), findsOneWidget);
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
