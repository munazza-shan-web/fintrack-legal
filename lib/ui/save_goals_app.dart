import 'dart:async';
import 'dart:math' as math;
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
import '../utils/amount_input.dart';
import '../utils/app_localizations.dart';
import 'strings.dart';
import '../viewmodels/goals_viewmodel.dart';
import '../services/notification_service.dart';

part 'goals.dart';
part 'goal_forms.dart';
part 'activity.dart';
part 'settings.dart';
part 'progress_share.dart';
part 'paywall.dart';
part 'milestone.dart';
part 'design_components.dart';
part 'launch.dart';

const lime = Color(0xFF9FE870);
const forest = Color(0xFF163300);
const accent = CupertinoDynamicColor.withBrightness(
  color: Color(0xFF2F671D),
  darkColor: lime,
);
bool isDark(BuildContext c) =>
    CupertinoTheme.brightnessOf(c) == Brightness.dark;
Color ink(BuildContext c) =>
    isDark(c) ? const Color(0xFFF5F5EC) : const Color(0xFF182019);
Color muted(BuildContext c) =>
    isDark(c) ? const Color(0xFFA9B2A8) : const Color(0xFF626C61);
Color panel(BuildContext c) => isDark(c)
    ? (c.read<AppSettings>().blackTheme
          ? const Color(0xFF1C1C1E)
          : const Color(0xFF1C231D))
    : const Color(0xFFFFFFFF);
Color canvas(BuildContext c) => isDark(c)
    ? (c.read<AppSettings>().blackTheme
          ? const Color(0xFF000000)
          : const Color(0xFF101411))
    : const Color(0xFFF3F4EC);
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
  final bool showLaunchScreen;
  const SaveGoalsApp({super.key, this.showLaunchScreen = false});
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
        scaffoldBackgroundColor: settings.themeMode == ThemeMode.dark
            ? (settings.blackTheme
                  ? const Color(0xFF000000)
                  : const Color(0xFF101411))
            : const Color(0xFFF3F4EC),
        textTheme: const CupertinoTextThemeData(
          primaryColor: accent,
          textStyle: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 17,
            color: CupertinoColors.label,
          ),
          actionTextStyle: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 17,
            color: accent,
          ),
          tabLabelTextStyle: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11,
            color: CupertinoColors.secondaryLabel,
          ),
          navTitleTextStyle: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: CupertinoColors.label,
          ),
          navLargeTitleTextStyle: TextStyle(
            fontFamily: 'Manrope',
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
      home: showLaunchScreen ? const StartupGate() : const MainScreen(),
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
    final pages = [
      HomePage(onAllGoals: () => setState(() => tabs.index = 1)),
      const GoalsPage(),
      const ActivityPage(),
      const SettingsPage(),
    ];
    return CupertinoPageScaffold(
      backgroundColor: canvas(context),
      child: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(index: tabs.index, children: pages),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: FloatingNavigation(
                    index: tabs.index,
                    onSelected: (i) {
                      HapticFeedback.selectionClick();
                      setState(() => tabs.index = i);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
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
  final bool rootTab;
  const PageShell({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.rootTab = false,
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  if (!rootTab && Navigator.of(c).canPop())
                    CupertinoButton(
                      padding: const EdgeInsetsDirectional.only(end: 12),
                      onPressed: () => Navigator.pop(c),
                      child: Icon(
                        CupertinoIcons.back,
                        semanticLabel: t(c, 'Back'),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      t(c, title),
                      textAlign: !rootTab && Navigator.of(c).canPop()
                          ? TextAlign.center
                          : TextAlign.start,
                      style: headline(
                        c,
                        !rootTab && Navigator.of(c).canPop() ? 18 : 24,
                      ),
                    ),
                  ),
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
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      rootTab ? 120 : 24,
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      disabledColor: lime.withValues(alpha: .35),
      borderRadius: BorderRadius.circular(16),
      onPressed: busy ? null : onPressed,
      child: busy
          ? const CupertinoActivityIndicator()
          : Text(
              t(c, label),
              style: const TextStyle(
                color: forest,
                fontSize: 14,
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
  final Color? color;
  const ProgressTrack(
    this.value, {
    super.key,
    this.onGreen = false,
    this.color,
  });
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
            child: Container(
              color: color ?? (onGreen ? forest : accent.resolveFrom(c)),
            ),
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
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
    child: Column(
      children: [
        const SizedBox(
          width: 140,
          height: 140,
          child: FittedBox(child: SavingsSprout(progress: .1)),
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
  Widget build(BuildContext c) => HomeOverview(onAllGoals: onAllGoals);
}
