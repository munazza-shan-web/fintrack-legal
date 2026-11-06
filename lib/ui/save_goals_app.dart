import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/savings_goal.dart';
import '../models/savings_plan.dart';
import '../models/saving_insights.dart';
import '../models/savings_transaction.dart';
import '../providers/app_settings.dart';
import '../utils/app_brand.dart';
import '../utils/app_localizations.dart';
import 'strings.dart';
import '../viewmodels/goals_viewmodel.dart';

part 'goals.dart';
part 'goal_forms.dart';
part 'activity.dart';
part 'settings.dart';
part 'progress_share.dart';

const lime = Color(0xFF9FE870);
const forest = Color(0xFF163300);
const accent = CupertinoDynamicColor.withBrightness(
  color: Color(0xFF2F671D),
  darkColor: lime,
);
Color ink(BuildContext c) => CupertinoColors.label.resolveFrom(c);
Color muted(BuildContext c) => CupertinoColors.secondaryLabel.resolveFrom(c);
Color panel(BuildContext c) =>
    CupertinoColors.secondarySystemGroupedBackground.resolveFrom(c);
Color canvas(BuildContext c) =>
    CupertinoColors.systemGroupedBackground.resolveFrom(c);
String t(BuildContext c, String s) {
  // The inherited scope updates existing tab routes as well as new pages.
  // Unlike a provider watch, it is also safe inside button callbacks.
  final code =
      c.dependOnInheritedWidgetOfExactType<_AppLanguage>()?.code ??
      c.read<AppSettings>().languageCode;
  return code == 'ur'
      ? (urduStrings[s] ?? AppLocalizations(code).translate(s))
      : s;
}

class _AppLanguage extends InheritedWidget {
  final String code;
  const _AppLanguage({required this.code, required super.child});
  @override
  bool updateShouldNotify(_AppLanguage oldWidget) => code != oldWidget.code;
}

String money(BuildContext c, double value) =>
    c.watch<AppSettings>().formatMoney(value);
String dateLabel(DateTime d) => DateFormat('d MMM yyyy').format(d);
TextStyle headline(BuildContext c, [double size = 24]) => TextStyle(
  color: ink(c),
  fontSize: size,
  fontWeight: FontWeight.w700,
  letterSpacing: -.6,
);

class SaveGoalsApp extends StatelessWidget {
  const SaveGoalsApp({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    return CupertinoApp(
      title: AppBrand.name,
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: settings.themeMode == ThemeMode.dark
            ? Brightness.dark
            : Brightness.light,
        primaryColor: accent,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
        textTheme: const CupertinoTextThemeData(
          primaryColor: accent,
          textStyle: TextStyle(
            fontFamily: 'SavingsSans',
            fontSize: 17,
            color: CupertinoColors.label,
          ),
          actionTextStyle: TextStyle(
            fontFamily: 'SavingsSans',
            fontSize: 17,
            color: accent,
          ),
          tabLabelTextStyle: TextStyle(
            fontFamily: 'SavingsSans',
            fontSize: 11,
            color: CupertinoColors.secondaryLabel,
          ),
          navTitleTextStyle: TextStyle(
            fontFamily: 'SavingsSans',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: CupertinoColors.label,
          ),
          navLargeTitleTextStyle: TextStyle(
            fontFamily: 'SavingsSans',
            color: CupertinoColors.label,
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.1,
          ),
        ),
      ),
      builder: (context, child) => _AppLanguage(
        code: settings.languageCode,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: const Color(0x00000000),
            statusBarIconBrightness: settings.themeMode == ThemeMode.dark
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: settings.themeMode == ThemeMode.dark
                ? Brightness.dark
                : Brightness.light,
            systemNavigationBarColor: const Color(0x00000000),
            systemNavigationBarIconBrightness:
                settings.themeMode == ThemeMode.dark
                ? Brightness.light
                : Brightness.dark,
            systemNavigationBarContrastEnforced: false,
          ),
          child: Directionality(
            textDirection: AppLocalizations(
              settings.languageCode,
            ).textDirection,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final tabs = CupertinoTabController();
  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettings>();
    return CupertinoTabScaffold(
      controller: tabs,
      tabBar: CupertinoTabBar(
        activeColor: accent.resolveFrom(context),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.house),
            activeIcon: const Icon(CupertinoIcons.house_fill),
            label: t(context, 'Home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.flag),
            activeIcon: const Icon(CupertinoIcons.flag_fill),
            label: t(context, 'Goals'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.chart_bar),
            activeIcon: const Icon(CupertinoIcons.chart_bar_fill),
            label: t(context, 'Activity'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.settings),
            label: t(context, 'Settings'),
          ),
        ],
      ),
      tabBuilder: (context, index) => CupertinoTabView(
        builder: (context) => switch (index) {
          0 => HomePage(onAllGoals: () => tabs.index = 1),
          1 => const GoalsPage(),
          2 => const ActivityPage(),
          _ => const SettingsPage(),
        },
      ),
    );
  }
}

void openPage(BuildContext c, Widget page) => Navigator.of(
  c,
  rootNavigator: true,
).push(CupertinoPageRoute<void>(builder: (_) => page));
Future<void> alert(BuildContext c, String title, String message) =>
    showCupertinoDialog<void>(
      context: c,
      builder: (dialog) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialog),
            child: Text(t(c, 'Done')),
          ),
        ],
      ),
    );
Future<bool> confirm(BuildContext c, String title, String message) async =>
    await showCupertinoDialog<bool>(
      context: c,
      builder: (dialog) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(t(c, 'Cancel')),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(t(c, 'Delete')),
          ),
        ],
      ),
    ) ??
    false;

class PageShell extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const PageShell({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });
  @override
  Widget build(BuildContext c) => CupertinoPageScaffold(
    backgroundColor: canvas(c),
    child: SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  if (Navigator.of(c).canPop())
                    CupertinoButton(
                      padding: const EdgeInsetsDirectional.only(end: 12),
                      onPressed: () => Navigator.pop(c),
                      child: Icon(
                        CupertinoIcons.back,
                        semanticLabel: t(c, 'Back'),
                      ),
                    ),
                  Expanded(child: Text(t(c, title), style: headline(c, 28))),
                  ?trailing,
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SafeArea(
              top: false,
              bottom: true,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class Panel extends StatelessWidget {
  final Widget child;
  final Color? color;
  const Panel({super.key, required this.child, this.color});
  @override
  Widget build(BuildContext c) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color ?? panel(c),
      borderRadius: BorderRadius.circular(24),
    ),
    child: child,
  );
}

class Section extends StatelessWidget {
  final String title;
  final Widget? action;
  const Section(this.title, {super.key, this.action});
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.only(top: 28, bottom: 12),
    child: Row(
      children: [
        Expanded(child: Text(t(c, title), style: headline(c, 21))),
        ?action,
      ],
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  const PrimaryButton(
    this.label, {
    super.key,
    this.onPressed,
    this.busy = false,
  });
  @override
  Widget build(BuildContext c) => SizedBox(
    width: double.infinity,
    child: CupertinoButton(
      color: lime,
      disabledColor: lime.withValues(alpha: .35),
      borderRadius: BorderRadius.circular(16),
      onPressed: busy ? null : onPressed,
      child: busy
          ? const CupertinoActivityIndicator()
          : Text(
              t(c, label),
              style: const TextStyle(
                color: forest,
                fontWeight: FontWeight.w700,
              ),
            ),
    ),
  );
}

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});
  @override
  Widget build(BuildContext c) => Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(AppBrand.icon, width: 48, height: 48),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppBrand.name, style: headline(c, 19)),
            Text(
              t(c, 'Small steps. Real progress.'),
              style: TextStyle(color: muted(c), fontSize: 13),
            ),
          ],
        ),
      ),
      CupertinoButton(
        padding: const EdgeInsets.all(10),
        onPressed: () => c.read<AppSettings>().setHideBalances(
          !c.read<AppSettings>().hideBalances,
        ),
        child: Icon(
          c.watch<AppSettings>().hideBalances
              ? CupertinoIcons.eye_slash
              : CupertinoIcons.eye,
          size: 22,
          semanticLabel: t(
            c,
            c.watch<AppSettings>().hideBalances
                ? 'Show balances'
                : 'Hide balances',
          ),
        ),
      ),
    ],
  );
}

class ProgressTrack extends StatelessWidget {
  final double value;
  final bool onGreen;
  const ProgressTrack(this.value, {super.key, this.onGreen = false});
  @override
  Widget build(BuildContext c) => Semantics(
    label: '${(value * 100).round()}%',
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: MediaQuery.disableAnimationsOf(c)
          ? Duration.zero
          : const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 8,
          color: onGreen
              ? forest.withValues(alpha: .14)
              : CupertinoColors.systemFill.resolveFrom(c),
          alignment: AlignmentDirectional.centerStart,
          child: FractionallySizedBox(
            widthFactor: v.clamp(0, 1),
            child: Container(color: onGreen ? forest : accent.resolveFrom(c)),
          ),
        ),
      ),
    ),
  );
}

class DataStatus extends StatelessWidget {
  const DataStatus({super.key});
  @override
  Widget build(BuildContext c) {
    final vm = c.watch<GoalsViewModel>();
    if (vm.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CupertinoActivityIndicator()),
      );
    }
    if (vm.error == null) return const SizedBox.shrink();
    return Panel(
      child: Column(
        children: [
          Text(t(c, 'Could not load your savings.')),
          CupertinoButton(
            onPressed: vm.loadData,
            child: Text(t(c, 'Try again')),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String title, subtitle;
  final VoidCallback? onAdd;
  const EmptyState(this.title, this.subtitle, {super.key, this.onAdd});
  @override
  Widget build(BuildContext c) => Panel(
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: lime.withValues(alpha: .2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            CupertinoIcons.flag,
            color: accent.resolveFrom(c),
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(t(c, title), textAlign: TextAlign.center, style: headline(c, 20)),
        const SizedBox(height: 8),
        Text(
          t(c, subtitle),
          textAlign: TextAlign.center,
          style: TextStyle(color: muted(c), height: 1.45),
        ),
        if (onAdd != null) ...[
          const SizedBox(height: 20),
          PrimaryButton('Create Goal', onPressed: onAdd),
        ],
      ],
    ),
  );
}

class HomePage extends StatelessWidget {
  final VoidCallback onAllGoals;
  const HomePage({super.key, required this.onAllGoals});
  @override
  Widget build(BuildContext c) {
    final vm = c.watch<GoalsViewModel>();
    final upcoming = vm.goals.where((g) => !g.isCompleted).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
    return PageShell(
      title: 'Overview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppHeader(),
          const SizedBox(height: 18),
          MomentumHeader(
            insights: SavingInsights(vm.transactions),
            progress: vm.overallProgress,
          ),
          const SizedBox(height: 18),
          Panel(
            color: lime,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(c, 'Total saved'),
                  style: const TextStyle(
                    color: forest,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 9),
                SizedBox(
                  height: 50,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      money(c, vm.totalSaved),
                      style: const TextStyle(
                        color: forest,
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                ProgressTrack(vm.overallProgress, onGreen: true),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${(vm.overallProgress * 100).round()}% ${t(c, 'of your target')}',
                        style: const TextStyle(color: forest, fontSize: 13),
                      ),
                    ),
                    Text(
                      '${vm.activeGoals} ${t(c, 'active')}',
                      style: const TextStyle(color: forest, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  'Remaining',
                  money(c, vm.totalRemaining),
                  CupertinoIcons.arrow_up_right,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Metric(
                  'Completed',
                  '${vm.completedGoals}',
                  CupertinoIcons.checkmark_seal,
                ),
              ),
            ],
          ),
          const Section('Make a little progress'),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  'Create Goal',
                  CupertinoIcons.plus,
                  () => openPage(c, const GoalEditor()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  'Deposit',
                  CupertinoIcons.add_circled,
                  () => openPage(c, const TransactionEditor()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  'Withdraw',
                  CupertinoIcons.minus_circled,
                  () => openPage(c, const TransactionEditor(withdraw: true)),
                ),
              ),
            ],
          ),
          const DataStatus(),
          Section(
            'Your goals',
            action: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onAllGoals,
              child: Text(t(c, 'See all')),
            ),
          ),
          if (vm.goals.isEmpty && !vm.isLoading && vm.error == null)
            EmptyState(
              'Your next chapter starts here',
              'Create a goal, choose a date, and take the first small step.',
              onAdd: () => openPage(c, const GoalEditor()),
            ),
          ...vm.goals.take(3).map((g) => GoalTile(g)),
          if (upcoming.isNotEmpty) ...[
            const Section('Your savings plan'),
            PlanCard(upcoming.first),
          ],
          if (vm.transactions.isNotEmpty) ...[
            const Section('Recent activity'),
            ...vm.transactions.take(3).map((tx) => TransactionTile(tx)),
          ],
          const SizedBox(height: 24),
          Text(
            t(c, '100% free. Every goal. Every feature.'),
            style: TextStyle(color: muted(c), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _Metric(this.label, this.value, this.icon);
  @override
  Widget build(BuildContext c) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: accent.resolveFrom(c), size: 22),
        const SizedBox(height: 14),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value, style: headline(c, 22)),
        ),
        const SizedBox(height: 5),
        Text(t(c, label), style: TextStyle(color: muted(c), fontSize: 13)),
      ],
    ),
  );
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _QuickAction(this.label, this.icon, this.onTap);
  @override
  Widget build(BuildContext c) => CupertinoButton(
    padding: EdgeInsets.zero,
    onPressed: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: panel(c),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, size: 25),
          const SizedBox(height: 9),
          Text(
            t(c, label),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ink(c),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
