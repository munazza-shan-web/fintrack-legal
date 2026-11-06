import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/savings_goal.dart';
import 'models/savings_transaction.dart';
import 'viewmodels/goals_viewmodel.dart';
import 'providers/app_settings.dart';
import 'services/notification_service.dart';
import 'utils/app_localizations.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appSettings = AppSettings();
  await appSettings.loadSettings();
  try {
    await NotificationService.instance.initialize();
  } catch (_) {
    // Notification setup must not prevent the savings app from opening.
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GoalsViewModel()..loadData(),
        ),
        ChangeNotifierProvider<AppSettings>.value(value: appSettings),
      ],
      child: FinTrackApp(),
    ),
  );
}

// --------------------------------------------------
// FINTRACK COLORS
// --------------------------------------------------

Color bg = AppTheme.darkColors.background;
Color surface = AppTheme.darkColors.surface;
Color surface2 = AppTheme.darkColors.surface2;
Color neon = AppTheme.darkColors.accent;
Color muted = AppTheme.darkColors.muted;
Color white = AppTheme.darkColors.text;
Color red = AppTheme.darkColors.danger;

String tr(BuildContext context, String value) {
  final language = context.watch<AppSettings>().languageCode;
  if (language != 'ur') return AppLocalizations(language).translate(value);

  const urdu = <String, String>{
    'YOUR FUTURE STARTS HERE': 'آپ کا مستقبل یہیں سے شروع ہوتا ہے',
    'Savings overview': 'بچت کا جائزہ',
    'TOTAL SAVINGS': 'کل بچت',
    'Across all your savings goals': 'آپ کے تمام بچت کے اہداف',
    'OVERALL PROGRESS': 'مجموعی پیش رفت',
    'VIEW ALL': 'سب دیکھیں',
    'ACTIVE GOALS': 'فعال اہداف',
    'REMAINING': 'باقی رقم',
    'QUICK ACTIONS': 'فوری اقدامات',
    'YOUR SAVINGS GOALS': 'آپ کے بچت کے اہداف',
    'UPCOMING DEADLINES': 'قریب آنے والی آخری تاریخیں',
    'RECENT TRANSACTIONS': 'حالیہ لین دین',
    'TRANSACTION HISTORY': 'لین دین کی تفصیل',
    'TOTAL SAVED': 'کل جمع شدہ رقم',
    'TOTAL DEPOSITS': 'کل جمع رقم',
    'WITHDRAWALS': 'نکلوائی گئی رقوم',
    'Create Goal': 'ہدف بنائیں',
    'Deposit': 'رقم جمع کریں',
    'Withdraw': 'رقم نکالیں',
    'All': 'تمام',
    'Deposits': 'جمع شدہ رقوم',
    'Search by goal name or note...': 'ہدف کے نام یا نوٹ سے تلاش کریں...',
    'Enter a name, valid target and deadline.': 'نام، درست ہدف کی رقم اور آخری تاریخ درج کریں۔',
    'Target cannot be less than your current savings ': 'ہدف کی رقم موجودہ بچت سے کم نہیں ہو سکتی ',
    'No upcoming deadlines yet.': 'ابھی کوئی آنے والی آخری تاریخ نہیں',
    'Your deposits and withdrawals will appear here.': 'آپ کی جمع اور نکلوائی گئی رقوم یہاں نظر آئیں گی',
    'No savings goals yet': 'ابھی کوئی بچت کا ہدف نہیں',
    'Create your first goal and start saving.': 'اپنا پہلا ہدف بنائیں اور بچت شروع کریں',
    'SAVE WITH PURPOSE': 'مقصد کے ساتھ بچت کریں',
    'Delete Goal?': 'ہدف حذف کریں؟',
    'Are you sure you want to delete this goal? ': 'کیا آپ واقعی یہ ہدف حذف کرنا چاہتے ہیں؟ ',
    'Goal deleted successfully.': 'ہدف کامیابی سے حذف ہو گیا',
    'Choose an emoji': 'ایموجی منتخب کریں',
    'Goal name': 'ہدف کا نام',
    'Target amount': 'مطلوبہ رقم',
    'Deadline': 'آخری تاریخ',
    'Select a deadline': 'آخری تاریخ منتخب کریں',
    'Select savings goal': 'بچت کا ہدف منتخب کریں',
    'You need to create a savings goal first.': 'پہلے بچت کا ہدف بنائیں',
    'Amount': 'رقم',
    'Note (optional)': 'نوٹ (اختیاری)',
    'My Goals': 'میرے اہداف',
    'Keep moving towards your targets.': 'اپنے اہداف کی طرف بڑھتے رہیں',
    'Create New Goal': 'نیا ہدف بنائیں',
    'Savings Reports': 'بچت کی رپورٹس',
    'A look at your savings activity.': 'آپ کی بچت کی سرگرمی کا جائزہ',
    'No transactions recorded yet.': 'ابھی کوئی لین دین درج نہیں ہوا',
    'No matching transactions found.': 'کوئی متعلقہ لین دین نہیں ملا',
    'Your reports update automatically when savings transactions are recorded.': 'بچت کا لین دین درج ہونے پر رپورٹس خود بخود اپ ڈیٹ ہو جاتی ہیں',
    'Personalize your FinTrack experience.': 'FinTrack کو اپنی پسند کے مطابق بنائیں',
    'Select Currency': 'کرنسی منتخب کریں',
    'Pakistani Rupee': 'پاکستانی روپیہ',
    'US Dollar': 'امریکی ڈالر',
    'British Pound': 'برطانوی پاؤنڈ',
    'Euro': 'یورو',
  };
  return urdu[value] ?? AppLocalizations(language).translate(value);
}

// --------------------------------------------------
// APP
// --------------------------------------------------

class FinTrackApp extends StatelessWidget {
  FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final colors = settings.themeMode == ThemeMode.light
        ? AppTheme.lightColors
        : AppTheme.darkColors;

    // Keep the original palette-based design, but make its colors theme-aware.
    bg = colors.background;
    surface = colors.surface;
    surface2 = colors.surface2;
    neon = colors.accent;
    muted = colors.muted;
    white = colors.text;
    red = colors.danger;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinTrack',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      builder: (context, child) {
        return Directionality(
          textDirection: AppLocalizations(settings.languageCode).textDirection,
          child: child ?? SizedBox.shrink(),
        );
      },
      home: MainScreen(),
    );
  }
}

// --------------------------------------------------
// MAIN NAVIGATION
// --------------------------------------------------

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettings>();
    final List<Widget> pages = [
      DashboardPage(),
      GoalsPage(),
      ReportsPage(),
      SettingsPage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        height: 72,
        backgroundColor: surface,
        indicatorColor: neon.withValues(alpha: 0.13),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: neon),
            label: tr(context, 'Dashboard'),
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag_rounded, color: neon),
            label: tr(context, 'Goals'),
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded),
            selectedIcon: Icon(Icons.bar_chart_rounded, color: neon),
            label: tr(context, 'Reports'),
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded, color: neon),
            label: tr(context, 'Settings'),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// DASHBOARD
// --------------------------------------------------

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalsViewModel>(
      builder: (context, vm, child) {
        final goals = vm.goals;

        final upcomingGoals = goals
            .where((goal) => !goal.isCompleted)
            .toList()
          ..sort(
            (a, b) => a.deadline.compareTo(b.deadline),
          );

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(),
              SizedBox(height: 30),

              Text(
                tr(context, 'YOUR FUTURE STARTS HERE'),
                style: TextStyle(
                  color: neon,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              SizedBox(height: 7),

              Text(
                tr(context, 'Savings overview'),
                style: TextStyle(
                  color: white,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(height: 20),

              // TOTAL SAVINGS CARD

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF263B29),
                      Color(0xFF111713),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: neon.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: neon,
                          size: 20,
                        ),
                        SizedBox(width: 9),
                        Text(
                          tr(context, 'TOTAL SAVINGS'),
                          style: TextStyle(
                            color: muted,
                            fontSize: 10,
                            letterSpacing: 1.3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 15),

                    Text(
                      context.watch<AppSettings>().formatMoney(vm.totalSaved),
                      style: TextStyle(
                        color: white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    SizedBox(height: 7),

                    Text(
                      tr(context, 'Across all your savings goals'),
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),

                    SizedBox(height: 23),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr(context, 'OVERALL PROGRESS'),
                          style: TextStyle(
                            color: muted,
                            fontSize: 9,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '${(vm.overallProgress * 100).round()}%',
                          style: TextStyle(
                            color: neon,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 9),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: vm.overallProgress,
                        minHeight: 9,
                        backgroundColor: surface2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(neon),
                      ),
                    ),

                    SizedBox(height: 12),

                    Text(
                      'Target: ${context.watch<AppSettings>().formatMoney(vm.totalTarget)}',
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 18),

              // STATISTICS

              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.flag_outlined,
                      title: 'ACTIVE GOALS',
                      value: '${vm.activeGoals}',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.savings_outlined,
                      title: 'REMAINING',
                      value:
                          context.watch<AppSettings>().formatMoney(vm.totalRemaining),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 28),

              // QUICK ACTIONS

              SectionHeading(title: 'QUICK ACTIONS'),
              SizedBox(height: 13),

              Row(
                children: [
                  Expanded(
                    child: QuickAction(
                      icon: Icons.add_circle_outline,
                      title: 'Create Goal',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateGoalPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: QuickAction(
                      icon: Icons.arrow_downward_rounded,
                      title: 'Deposit',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransactionPage(
                              type: TransactionType.deposit,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: QuickAction(
                      icon: Icons.arrow_upward_rounded,
                      title: 'Withdraw',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransactionPage(
                              type: TransactionType.withdrawal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 28),

              // SAVINGS GOALS

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SectionHeading(
                    title: 'YOUR SAVINGS GOALS',
                  ),
                  TextButton(
                    onPressed: () {
                      showMessage(context, 'All goals');
                    },
                    child: Text(
                      tr(context, 'VIEW ALL'),
                      style: TextStyle(
                        color: neon,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 7),

              if (vm.isLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: neon),
                  ),
                )
              else if (vm.error != null)
                Text(
                  'Could not load goals: ${vm.error}',
                  style: TextStyle(
                    color: red,
                    fontSize: 12,
                  ),
                )
              else if (goals.isEmpty)
                EmptyGoalsMessage()
              else
                ...goals.take(3).map(
                  (goal) => GoalCard(goal: goal),
                ),

              SizedBox(height: 20),

              // UPCOMING DEADLINES

              SectionHeading(title: 'UPCOMING DEADLINES'),
              SizedBox(height: 13),

              if (upcomingGoals.isEmpty)
                Text(
                  tr(context, 'No upcoming deadlines yet.'),
                  style: TextStyle(color: muted, fontSize: 11),
                )
              else
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: surface2.withValues(alpha: 0.75)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: neon,
                        size: 27,
                      ),
                      SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${upcomingGoals.first.emoji} ${upcomingGoals.first.name}',
                              style: TextStyle(
                                color: white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Target deadline: ${formatDate(upcomingGoals.first.deadline)}',
                              style: TextStyle(
                                color: muted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 28),

              // RECENT TRANSACTIONS

              SectionHeading(title: 'RECENT TRANSACTIONS'),
              SizedBox(height: 13),

              if (vm.transactions.isEmpty)
                Text(
                  tr(context, 'Your deposits and withdrawals will appear here.'),
                  style: TextStyle(color: muted, fontSize: 11),
                )
              else
                ...vm.transactions.take(3).map((transaction) {
                  final goal = vm.getGoalById(transaction.goalId);

                  return DatabaseTransactionCard(
                    transaction: transaction,
                    goalName: goal?.name ?? 'Deleted goal',
                    emoji: goal?.emoji ?? '🎯',
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

// --------------------------------------------------
// EMPTY GOALS MESSAGE
// --------------------------------------------------

class EmptyGoalsMessage extends StatelessWidget {
  EmptyGoalsMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: surface2.withValues(alpha: 0.75)),
      ),
      child: Column(
        children: [
          Icon(Icons.savings_outlined, color: neon, size: 32),
          SizedBox(height: 10),
          Text(
            tr(context, 'No savings goals yet'),
            style: TextStyle(
              color: white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            tr(context, 'Create your first goal and start saving.'),
            style: TextStyle(color: muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// APP HEADER
// --------------------------------------------------

class AppHeader extends StatelessWidget {
  AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 43,
          width: 43,
          decoration: BoxDecoration(
            color: neon,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.savings_rounded,
            color: bg,
            size: 25,
          ),
        ),
        SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr(context, 'FINTRACK'),
              style: TextStyle(
                color: white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            Text(
              tr(context, 'SAVE WITH PURPOSE'),
              style: TextStyle(
                color: muted,
                fontSize: 8,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// --------------------------------------------------
// STAT CARD
// --------------------------------------------------

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: surface2.withValues(alpha: 0.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: neon, size: 21),
          SizedBox(height: 13),
          Text(
            value,
            style: TextStyle(
              color: white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            tr(context, title),
            style: TextStyle(
              color: muted,
              fontSize: 8,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// SECTION HEADING
// --------------------------------------------------

class SectionHeading extends StatelessWidget {
  final String title;

  SectionHeading({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      tr(context, title),
      style: TextStyle(
        color: white,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }
}

// --------------------------------------------------
// QUICK ACTION
// --------------------------------------------------

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  QuickAction({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 4,
        ),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: surface2.withValues(alpha: 0.75)),
        ),
        child: Column(
          children: [
            Icon(icon, color: neon, size: 23),
            SizedBox(height: 8),
            Text(
              tr(context, title),
              style: TextStyle(
                color: white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// GOAL CARD
// --------------------------------------------------

class GoalCard extends StatelessWidget {
  final SavingsGoal goal;

  GoalCard({super.key, required this.goal});

  Future<void> _deleteGoal(BuildContext context) async {
    if (goal.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: surface,
          title: Text(
            tr(context, 'Delete Goal?'),
            style: TextStyle(color: white),
          ),
          content: Text(
            tr(
              context,
              'Are you sure you want to delete this goal? '
              'Its associated transaction history will also be deleted. '
              'This action cannot be undone.',
            ),
            style: TextStyle(color: muted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                tr(context, 'Cancel'),
                style: TextStyle(color: muted),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                tr(context, 'Delete'),
                style: TextStyle(color: red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<GoalsViewModel>().deleteGoal(goal.id!);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr(context, 'Goal deleted successfully.')),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete goal: $e'),
          backgroundColor: red,
        ),
      );
    }
  }

  void _editGoal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateGoalPage(goal: goal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettings>();
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: surface2.withValues(alpha: 0.75)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 45,
                width: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: surface2,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  goal.emoji,
                  style: TextStyle(fontSize: 23),
                ),
              ),
              SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: TextStyle(
                        color: white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Due ${formatDate(goal.deadline)}',
                      style: TextStyle(
                        color: muted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '${(goal.progress * 100).round()}%',
                style: TextStyle(
                  color: neon,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(width: 4),

              PopupMenuButton<String>(
                color: surface2,
                icon: Icon(
                  Icons.more_vert,
                  color: muted,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _editGoal(context);
                  } else if (value == 'delete') {
                    _deleteGoal(context);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          color: neon,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Text(
                          tr(context, 'Edit Goal'),
                          style: TextStyle(color: white),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: red,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Text(
                          tr(context, 'Delete Goal'),
                          style: TextStyle(color: red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 17),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 7,
              backgroundColor: surface2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(neon),
            ),
          ),

          SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saved: ${appSettings.formatMoney(goal.savedAmount)}',
                style: TextStyle(
                  color: white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Target: ${appSettings.formatMoney(goal.targetAmount)}',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${appSettings.formatMoney(goal.remainingAmount)} remaining',
              style: TextStyle(
                color: neon,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// DATABASE TRANSACTION CARD
// --------------------------------------------------

class DatabaseTransactionCard extends StatelessWidget {
  final SavingsTransaction transaction;
  final String goalName;
  final String emoji;

  DatabaseTransactionCard({
    super.key,
    required this.transaction,
    required this.goalName,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettings>();
    final isDeposit =
        transaction.type == TransactionType.deposit;

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            height: 43,
            width: 43,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              emoji,
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$goalName ${isDeposit ? 'deposit' : 'withdrawal'}',
                  style: TextStyle(
                    color: white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  formatDate(transaction.date),
                  style: TextStyle(
                    color: muted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isDeposit ? '+' : '-'} ${appSettings.formatMoney(transaction.amount)}',
            style: TextStyle(
              color: isDeposit ? neon : red,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// CREATE GOAL PAGE
// --------------------------------------------------

class CreateGoalPage extends StatefulWidget {
  final SavingsGoal? goal;

  CreateGoalPage({
    super.key,
    this.goal,
  });

  @override
  State<CreateGoalPage> createState() => _CreateGoalPageState();
}

class _CreateGoalPageState extends State<CreateGoalPage> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController targetController =
      TextEditingController();

  DateTime? deadline;
  String selectedEmoji = '🎯';
  bool isSaving = false;

  bool get isEditing => widget.goal != null;

  final List<String> emojis = [
    '🎯',
    '✈️',
    '🏠',
    '💻',
    '🚗',
    '🎓',
    '💍',
    '💰',
  ];

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final goal = widget.goal!;

      nameController.text = goal.name;
      targetController.text =
          goal.targetAmount.toStringAsFixed(0);

      deadline = goal.deadline;
      selectedEmoji = goal.emoji;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    targetController.dispose();
    super.dispose();
  }

  Future<void> chooseDeadline() async {
    final now = DateTime.now();

    final initialDate = deadline != null &&
            deadline!.isAfter(now)
        ? deadline!
        : now.add(Duration(days: 30));

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime.now().add(
        Duration(days: 3650),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: neon,
              surface: surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      setState(() {
        deadline = selected;
      });
    }
  }

  Future<void> saveGoal() async {
    final name = nameController.text.trim();

    final target = double.tryParse(
      targetController.text.trim(),
    );

    if (name.isEmpty ||
        target == null ||
        !target.isFinite ||
        target <= 0 ||
        deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(context, 'Enter a name, valid target and deadline.'),
          ),
        ),
      );
      return;
    }

    // Prevent setting a target below the amount
    // the user has already saved.
    if (isEditing &&
        target < widget.goal!.savedAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${tr(context, 'Target cannot be less than your current savings ')}'
            '(${context.read<AppSettings>().formatMoney(widget.goal!.savedAmount)}).',
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final vm = context.read<GoalsViewModel>();

    try {
      if (isEditing) {
        final updatedGoal = SavingsGoal(
          id: widget.goal!.id,
          name: name,
          targetAmount: target,
          savedAmount: widget.goal!.savedAmount,
          deadline: deadline!,
          emoji: selectedEmoji,
          createdAt: widget.goal!.createdAt,
        );

        await vm.updateGoal(updatedGoal);
      } else {
        final newGoal = SavingsGoal(
          name: name,
          targetAmount: target,
          savedAmount: 0,
          deadline: deadline!,
          emoji: selectedEmoji,
          createdAt: DateTime.now(),
        );

        await vm.addGoal(newGoal);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Goal updated successfully!'
                : 'Savings goal created successfully!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save goal: $e'),
          backgroundColor: red,
        ),
      );

      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: white,
        title: Text(
          isEditing ? 'Edit Savings Goal' : 'Create Savings Goal',
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing
                  ? 'Update your savings goal'
                  : 'What are you saving for?',
              style: TextStyle(
                color: white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 22),

            Text(
              tr(context, 'Choose an emoji'),
              style: TextStyle(color: muted),
            ),

            SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: emojis.map((emoji) {
                final selected = selectedEmoji == emoji;

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedEmoji = emoji;
                    });
                  },
                  child: Container(
                    height: 48,
                    width: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? neon.withValues(alpha: 0.15)
                          : surface,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: selected ? neon : surface2.withValues(alpha: 0.75),
                      ),
                    ),
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: 23),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 25),

            Text(
              tr(context, 'Goal name'),
              style: TextStyle(color: muted),
            ),

            SizedBox(height: 9),

            TextField(
              controller: nameController,
              style: TextStyle(color: white),
              decoration: inputDecoration('e.g. New laptop'),
            ),

            SizedBox(height: 20),

            Text(
              tr(context, 'Target amount'),
              style: TextStyle(color: muted),
            ),

            SizedBox(height: 9),

            TextField(
              controller: targetController,
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(color: white),
              decoration: inputDecoration('Enter target amount'),
            ),

            SizedBox(height: 20),

            Text(
              tr(context, 'Deadline'),
              style: TextStyle(color: muted),
            ),

            SizedBox(height: 9),

            InkWell(
              onTap: chooseDeadline,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: surface2),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: neon,
                    ),
                    SizedBox(width: 12),
                    Text(
                      deadline == null
                          ? 'Select a deadline'
                          : formatDate(deadline!),
                      style: TextStyle(color: white),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: neon,
                  foregroundColor: Theme.of(context).brightness == Brightness.dark ? bg : Colors.white,
                ),
                onPressed: isSaving ? null : saveGoal,
                child: isSaving
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: bg,
                        ),
                      )
                    : Text(
                        isEditing ? 'Save Changes' : 'Create Goal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// --------------------------------------------------
// DEPOSIT AND WITHDRAW PAGE
// --------------------------------------------------

class TransactionPage extends StatefulWidget {
  final TransactionType type;

  TransactionPage({
    super.key,
    required this.type,
  });

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController amountController =
      TextEditingController();

  final TextEditingController noteController =
      TextEditingController();

  int? selectedGoalId;
  bool isSaving = false;

  bool get isDeposit =>
      widget.type == TransactionType.deposit;

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null || !amount.isFinite || amount <= 0) {
      return;
    }

    if (selectedGoalId == null) return;

    setState(() {
      isSaving = true;
    });

    final vm = context.read<GoalsViewModel>();

    try {
      if (isDeposit) {
        await vm.addDeposit(
          goalId: selectedGoalId!,
          amount: amount,
          note: noteController.text.trim().isEmpty
              ? null
              : noteController.text.trim(),
        );
      } else {
        await vm.addWithdrawal(
          goalId: selectedGoalId!,
          amount: amount,
          note: noteController.text.trim().isEmpty
              ? null
              : noteController.text.trim(),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isDeposit
                ? 'Deposit saved successfully!'
                : 'Withdrawal saved successfully!',
          ),
          backgroundColor: surface2,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: red,
        ),
      );

      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalsViewModel>(
      builder: (context, vm, child) {
        final goals = vm.goals
            .where((goal) => goal.id != null)
            .toList();

        final selectedGoal = goals.where(
          (goal) => goal.id == selectedGoalId,
        );

        final validSelectedId =
            selectedGoal.isEmpty ? null : selectedGoalId;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: bg,
            foregroundColor: white,
            title: Text(
              isDeposit ? 'Deposit Money' : 'Withdraw Money',
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDeposit
                            ? neon.withValues(alpha: 0.3)
                            : red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isDeposit
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: isDeposit ? neon : red,
                          size: 35,
                        ),
                        SizedBox(height: 12),
                        Text(
                          isDeposit
                              ? 'Add money to your goal'
                              : 'Withdraw from your goal',
                          style: TextStyle(
                            color: white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          isDeposit
                              ? 'Every deposit brings you closer to your target.'
                              : 'Your withdrawal will reduce your saved balance.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 25),

                  Text(
                    tr(context, 'Select savings goal'),
                    style: TextStyle(color: muted),
                  ),

                  SizedBox(height: 9),

                  if (goals.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        tr(context, 'You need to create a savings goal first.'),
                        style: TextStyle(color: muted),
                      ),
                    )
                  else
                    DropdownButtonFormField<int>(
                      initialValue: validSelectedId,
                      dropdownColor: surface,
                      style: TextStyle(color: white),
                      decoration: inputDecoration('Choose a goal'),
                      items: goals.map((goal) {
                        return DropdownMenuItem<int>(
                          value: goal.id!,
                          child: Text(
                            '${goal.emoji} ${goal.name}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGoalId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a savings goal.';
                        }
                        return null;
                      },
                    ),

                  if (validSelectedId != null) ...[
                    SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        final goal = goals.firstWhere(
                          (item) => item.id == validSelectedId,
                        );

                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: surface2,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Text(
                            'Currently saved: ${context.watch<AppSettings>().formatMoney(goal.savedAmount)}',
                            style: TextStyle(
                              color: neon,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  SizedBox(height: 22),

                  Text(
                    tr(context, 'Amount'),
                    style: TextStyle(color: muted),
                  ),

                  SizedBox(height: 9),

                  TextFormField(
                    controller: amountController,
                    keyboardType:
                        TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(
                      color: white,
                      fontSize: 18,
                    ),
                    decoration: inputDecoration('Enter amount'),
                    validator: (value) {
                      final amount = double.tryParse(
                        value?.trim() ?? '',
                      );

                      if (amount == null ||
                          !amount.isFinite ||
                          amount <= 0) {
                        return 'Enter a valid amount greater than zero.';
                      }

                      return null;
                    },
                  ),

                  SizedBox(height: 22),

                  Text(
                    tr(context, 'Note (optional)'),
                    style: TextStyle(color: muted),
                  ),

                  SizedBox(height: 9),

                  TextFormField(
                    controller: noteController,
                    maxLines: 3,
                    style: TextStyle(color: white),
                    decoration: inputDecoration(
                      'Add a note about this transaction',
                    ),
                  ),

                  SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: isSaving || goals.isEmpty
                          ? null
                          : saveTransaction,
                      style: FilledButton.styleFrom(
                        backgroundColor: isDeposit ? neon : red,
                        foregroundColor: Theme.of(context).brightness == Brightness.dark ? bg : Colors.white,
                      ),
                      child: isSaving
                          ? SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: bg,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isDeposit
                                  ? 'Confirm Deposit'
                                  : 'Confirm Withdrawal',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// --------------------------------------------------
// INPUT DECORATION
// --------------------------------------------------

InputDecoration inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: muted),
    filled: true,
    fillColor: surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: surface2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: neon),
    ),
  );
}

// --------------------------------------------------
// GOALS PAGE
// --------------------------------------------------

class GoalsPage extends StatelessWidget {
  GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalsViewModel>(
      builder: (context, vm, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr(context, 'My Goals'),
                style: TextStyle(
                  color: white,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 7),
              Text(
                tr(context, 'Keep moving towards your targets.'),
                style: TextStyle(color: muted, fontSize: 12),
              ),
              SizedBox(height: 20),

              if (vm.isLoading)
                Center(
                  child: CircularProgressIndicator(color: neon),
                )
              else if (vm.error != null)
                Text(
                  'Could not load goals: ${vm.error}',
                  style: TextStyle(color: red),
                )
              else if (vm.goals.isEmpty)
                EmptyGoalsMessage()
              else
                ...vm.goals.map(
                  (goal) => GoalCard(goal: goal),
                ),

              SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateGoalPage(),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: neon,
                    foregroundColor: Theme.of(context).brightness == Brightness.dark ? bg : Colors.white,
                    padding: EdgeInsets.all(15),
                  ),
                  icon: Icon(Icons.add),
                  label: Text(tr(context, 'Create New Goal')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --------------------------------------------------
// REPORTS PAGE
// --------------------------------------------------


class ReportsPage extends StatefulWidget {
  ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String selectedFilter = 'All';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalsViewModel>(
      builder: (context, vm, child) {
        final deposits = vm.transactions
            .where(
              (transaction) =>
                  transaction.type == TransactionType.deposit,
            )
            .fold<double>(
              0,
              (total, transaction) => total + transaction.amount,
            );

        final withdrawals = vm.transactions
            .where(
              (transaction) =>
                  transaction.type == TransactionType.withdrawal,
            )
            .fold<double>(
              0,
              (total, transaction) => total + transaction.amount,
            );

        final filteredTransactions = vm.transactions.where((transaction) {
          final goal = vm.getGoalById(transaction.goalId);

          final matchesFilter = selectedFilter == 'All' ||
              (selectedFilter == 'Deposits' &&
                  transaction.type == TransactionType.deposit) ||
              (selectedFilter == 'Withdrawals' &&
                  transaction.type == TransactionType.withdrawal);

          final goalName = (goal?.name ?? 'Deleted goal').toLowerCase();
          final note = (transaction.note ?? '').toLowerCase();
          final query = searchQuery.toLowerCase();

          final matchesSearch =
              goalName.contains(query) || note.contains(query);

          return matchesFilter && matchesSearch;
        }).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr(context, 'Savings Reports'),
                style: TextStyle(
                  color: white,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                tr(context, 'A look at your savings activity.'),
                style: TextStyle(color: muted, fontSize: 12),
              ),

              SizedBox(height: 25),

              StatCard(
                icon: Icons.savings_outlined,
                title: 'TOTAL SAVED',
                value: context.watch<AppSettings>().formatMoney(vm.totalSaved),
              ),

              SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.arrow_downward_rounded,
                      title: 'TOTAL DEPOSITS',
                      value: context.watch<AppSettings>().formatMoney(deposits),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.arrow_upward_rounded,
                      title: 'WITHDRAWALS',
                      value: context.watch<AppSettings>().formatMoney(withdrawals),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 25),

              SectionHeading(title: 'TRANSACTION HISTORY'),
              SizedBox(height: 13),

              // Search transactions
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.trim();
                  });
                },
                style: TextStyle(
                  color: white,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by goal name or note...',
                  hintStyle: TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: neon,
                  ),
                  filled: true,
                  fillColor: surface,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 15),

              // Transaction filters
              Wrap(
                spacing: 8,
                children: ['All', 'Deposits', 'Withdrawals'].map((filter) {
                  final isSelected = selectedFilter == filter;

                  return FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    selectedColor: neon,
                    backgroundColor: surface,
                    checkmarkColor: bg,
                    labelStyle: TextStyle(
                      color: isSelected ? bg : white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 15),

              if (vm.isLoading)
                Center(
                  child: CircularProgressIndicator(color: neon),
                )
              else if (vm.transactions.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      tr(context, 'No transactions recorded yet.'),
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ),
                )
              else if (filteredTransactions.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      tr(context, 'No matching transactions found.'),
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ),
                )
              else ...[
                Text(
                  '${filteredTransactions.length} transaction(s) found',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 12),

                ...filteredTransactions.map((transaction) {
                  final goal = vm.getGoalById(transaction.goalId);

                  return DatabaseTransactionCard(
                    transaction: transaction,
                    goalName: goal?.name ?? 'Deleted goal',
                    emoji: goal?.emoji ?? '🎯',
                  );
                }),
              ],

              SizedBox(height: 20),

              Text(
                tr(context, 'Your reports update automatically when savings transactions are recorded.'),
                style: TextStyle(color: muted, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }
}


// --------------------------------------------------
// SETTINGS PAGE
// --------------------------------------------------

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  Future<void> _chooseCurrency(BuildContext context) async {
    final settings = context.read<AppSettings>();
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(tr(dialogContext, 'Select Currency')),
        children: [
          _ChoiceItem(value: 'PKR', title: 'Pakistani Rupee'),
          _ChoiceItem(value: 'USD', title: 'US Dollar'),
          _ChoiceItem(value: 'GBP', title: 'British Pound'),
          _ChoiceItem(value: 'EUR', title: 'Euro'),
        ],
      ),
    );
    if (selected != null) await settings.setCurrency(selected);
  }

  Future<void> _chooseLanguage(BuildContext context) async {
    final settings = context.read<AppSettings>();
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(tr(dialogContext, 'Select Language')),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'en'),
            child: Text(tr(dialogContext, 'English')),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'ur'),
            child: Text(tr(dialogContext, 'Urdu')),
          ),
        ],
      ),
    );
    if (selected != null) await settings.setLanguage(selected);
  }

  Future<void> _chooseAppearance(BuildContext context) async {
    final settings = context.read<AppSettings>();
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(tr(dialogContext, 'Select Appearance')),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, ThemeMode.dark),
            child: Row(
              children: [
                Icon(Icons.dark_mode_outlined),
                SizedBox(width: 12),
                Text(tr(dialogContext, 'Dark')),
                if (settings.themeMode == ThemeMode.dark) ...[
                  Spacer(),
                  Icon(Icons.check, color: neon),
                ],
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, ThemeMode.light),
            child: Row(
              children: [
                Icon(Icons.light_mode_outlined),
                SizedBox(width: 12),
                Text(tr(dialogContext, 'Light')),
                if (settings.themeMode == ThemeMode.light) ...[
                  Spacer(),
                  Icon(Icons.check, color: neon),
                ],
              ],
            ),
          ),
        ],
      ),
    );
    if (selected != null) await settings.setTheme(selected);
  }

  Future<void> _showReminderSettings(BuildContext context) async {
    final settings = context.read<AppSettings>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tr(dialogContext, 'Daily Reminder')),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr(context, 'Enable Reminders')),
                value: settings.remindersEnabled,
                onChanged: (enabled) async {
                  try {
                    await settings.setRemindersEnabled(enabled);
                    setDialogState(() {});
                  } catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${tr(context, 'Notifications permission is required')}: $error',
                        ),
                        backgroundColor: red,
                      ),
                    );
                    setDialogState(() {});
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                enabled: settings.remindersEnabled,
                leading: Icon(Icons.access_time),
                title: Text(tr(context, 'Reminder Time')),
                subtitle: Text(settings.reminderTimeLabel),
                onTap: !settings.remindersEnabled
                    ? null
                    : () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: settings.reminderHour,
                            minute: settings.reminderMinute,
                          ),
                        );
                        if (picked == null) return;
                        try {
                          await settings.setReminderTime(
                            picked.hour,
                            picked.minute,
                          );
                          setDialogState(() {});
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.toString())),
                          );
                        }
                      },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(tr(dialogContext, 'Done')),
          ),
        ],
      ),
    );
  }
Future<void> _openLegalPage(
  BuildContext context,
  String url,
) async {
  try {
    final uri = Uri.parse(url);
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the page. Please try again.'),
        ),
      );
    }
  } catch (_) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open the page. Please try again.'),
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final language = AppLocalizations(settings.languageCode);
    final currencyNames = {
      'PKR': '${language.translate('Pakistani Rupee')} (PKR)',
      'USD': '${language.translate('US Dollar')} (USD)',
      'GBP': '${language.translate('British Pound')} (GBP)',
      'EUR': '${language.translate('Euro')} (EUR)',
    };

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.translate('Settings'),
            style: TextStyle(
              color: white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            tr(context, 'Personalize your FinTrack experience.'),
            style: TextStyle(color: muted, fontSize: 12),
          ),
          SizedBox(height: 25),
          SettingsTile(
            icon: Icons.currency_exchange,
            title: language.translate('Currency'),
            subtitle: currencyNames[settings.currencyCode] ?? settings.currencyCode,
            onTap: () => _chooseCurrency(context),
          ),
          SettingsTile(
            icon: Icons.language,
            title: language.translate('Language'),
            subtitle: settings.languageCode == 'ur' ? 'اردو' : 'English',
            onTap: () => _chooseLanguage(context),
          ),
          SettingsTile(
            icon: Icons.notifications_outlined,
            title: language.translate('Reminders'),
            subtitle: settings.remindersEnabled
                ? '${language.translate('Enabled')} • ${settings.reminderTimeLabel}'
                : language.translate('Savings reminders'),
            onTap: () => _showReminderSettings(context),
          ),
          SettingsTile(
            icon: settings.themeMode == ThemeMode.dark
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined,
            title: language.translate('Appearance'),
            subtitle: language.translate(
              settings.themeMode == ThemeMode.dark ? 'Dark theme' : 'Light theme',
            ),
            onTap: () => _chooseAppearance(context),
          ),
          
          SettingsTile(
            icon: Icons.lock_outline,
            title: language.translate('Privacy'),
            subtitle: language.translate(
              settings.hideBalances ? 'Show balances' : 'Hide balances',
            ),
            onTap: () => settings.setHideBalances(!settings.hideBalances),
            trailing: Switch(
              value: settings.hideBalances,
              onChanged: settings.setHideBalances,
            ),
          ),
          SettingsTile(
            icon: Icons.policy_outlined,
            title: language.translate('Privacy Policy'),
            subtitle: language.translate('Read how your data is handled'),
            onTap: () => _openLegalPage(
              context,
              'https://munazza-shan-web.github.io/fintrack-legal/privacy-policy.html',
            ),
          ),
          SettingsTile(
            icon: Icons.description_outlined,
            title: language.translate('Terms & Conditions'),
            subtitle: language.translate('Read the terms of using FinTrack'),
            onTap: () => _openLegalPage(
              context,
              'https://munazza-shan-web.github.io/fintrack-legal/terms-and-conditions.html',
            ),
          ),
          SizedBox(height: 8),
          Text(
            language.translate('Your data stays on your device'),
            style: TextStyle(color: muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// CURRENCY CHOICE ITEM
// --------------------------------------------------
class _ChoiceItem extends StatelessWidget {
  final String value;
  final String title;

  const _ChoiceItem({required this.value, required this.title});

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(context, value),
      child: Text('${tr(context, title)} ($value)'),
    );
  }
}

// --------------------------------------------------
// SETTINGS TILE
// --------------------------------------------------

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: neon, size: 22),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(color: muted, fontSize: 10),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!
            else Icon(Icons.arrow_forward_ios_rounded, color: muted, size: 14),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// MESSAGE HELPER
// --------------------------------------------------

void showMessage(BuildContext context, String title) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(title), backgroundColor: surface2),
  );
}

// --------------------------------------------------
// DATE FORMATTER
// --------------------------------------------------

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month/${date.year}';
}
