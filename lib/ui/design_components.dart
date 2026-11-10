part of 'save_goals_app.dart';

const lilac = Color(0xFFDCCCF5);
const peach = Color(0xFFF3BEA5);

class ActivitySummaryCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const ActivitySummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext c) => Container(
    decoration: BoxDecoration(
      color: panel(c),
      borderRadius: BorderRadius.circular(20),
    ),
    child: CupertinoButton(
      padding: const EdgeInsets.all(14),
      onPressed: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Icon(CupertinoIcons.chevron_forward, size: 11, color: muted(c)),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: headline(c, 21)),
          ),
          const SizedBox(height: 5),
          Text(
            t(c, label),
            maxLines: 2,
            style: TextStyle(color: muted(c), fontSize: 12, height: 1.3),
          ),
        ],
      ),
    ),
  );
}

class StreakCard extends StatelessWidget {
  final SavingInsights insights;
  final double progress;
  const StreakCard({super.key, required this.insights, required this.progress});
  @override
  Widget build(BuildContext c) => Container(
    key: const ValueKey('home-streak'),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: panel(c),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: lilac.withValues(alpha: .28)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.flame_fill,
                        color: peach,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        t(c, 'Saving streak'),
                        style: TextStyle(
                          color: muted(c),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${insights.streak} ${t(c, insights.streak == 1 ? 'day' : 'days')}',
                    style: headline(c, 30),
                  ),
                  Text(
                    t(
                      c,
                      insights.streak == 0
                          ? 'Your next small step starts a streak.'
                          : 'Small steps, building a habit.',
                    ),
                    style: TextStyle(color: muted(c), fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 72,
              height: 72,
              child: FittedBox(child: SavingsSprout(progress: progress)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(7, (i) {
            final date = insights.now.subtract(Duration(days: 6 - i));
            final recorded = insights.week[i];
            return Expanded(
              child: Semantics(
                label:
                    '${dateLabel(date)}: ${t(c, recorded ? 'Deposit' : 'No deposit')}',
                child: Column(
                  children: [
                    Container(
                      width: 27,
                      height: 27,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: recorded ? lime : canvas(c),
                        border: Border.all(
                          color: i == 6
                              ? lilac
                              : muted(c).withValues(alpha: .2),
                          width: i == 6 ? 1.5 : 1,
                        ),
                      ),
                      child: recorded
                          ? const Icon(
                              CupertinoIcons.checkmark,
                              color: forest,
                              size: 15,
                            )
                          : null,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      DateFormat('E').format(date).substring(0, 1),
                      style: TextStyle(color: muted(c), fontSize: 10),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    ),
  );
}

class SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const SettingsGroup({super.key, required this.children});
  @override
  Widget build(BuildContext c) => Container(
    decoration: BoxDecoration(
      color: panel(c),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: .5,
                color: muted(c).withValues(alpha: .2),
              ),
            ),
          children[i],
        ],
      ],
    ),
  );
}

class SettingsRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final Widget? control;
  final VoidCallback? onTap;
  const SettingsRow(
    this.label,
    this.icon, {
    super.key,
    this.value,
    this.control,
    this.onTap,
  });
  @override
  Widget build(BuildContext c) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: ink(c)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t(c, label),
              style: TextStyle(color: ink(c), fontSize: 14),
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: 8),
            Text(value!, style: TextStyle(color: ink(c), fontSize: 12)),
          ],
          if (control != null)
            Transform.scale(
              scale: .78,
              alignment: AlignmentDirectional.centerEnd,
              child: SizedBox(height: 28, child: control),
            ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Icon(CupertinoIcons.chevron_forward, size: 12, color: ink(c)),
          ],
        ],
      ),
    );
    return onTap == null
        ? content
        : CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onTap,
            child: content,
          );
  }
}

class SavingsSegments<T extends Object> extends StatelessWidget {
  final T? groupValue;
  final Map<T, Widget> children;
  final ValueChanged<T?> onValueChanged;
  const SavingsSegments({
    super.key,
    required this.groupValue,
    required this.children,
    required this.onValueChanged,
  });
  @override
  Widget build(BuildContext c) => CupertinoSlidingSegmentedControl<T>(
    groupValue: groupValue,
    thumbColor: lime,
    backgroundColor: panel(c),
    padding: const EdgeInsets.all(3),
    children: children.map(
      (key, child) => MapEntry(
        key,
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: key == groupValue ? forest : ink(c),
            ),
            child: child,
          ),
        ),
      ),
    ),
    onValueChanged: onValueChanged,
  );
}

class AmountKeypad extends StatelessWidget {
  final TextEditingController controller;
  const AmountKeypad(this.controller, {super.key});
  @override
  Widget build(BuildContext c) => GridView.count(
    crossAxisCount: 3,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 6,
    crossAxisSpacing: 6,
    childAspectRatio: 2.8,
    children: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', '⌫']
        .map(
          (key) => CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              FocusScope.of(c).unfocus();
              var text = controller.text.replaceAll(',', '');
              if (key == '⌫') {
                if (text.isNotEmpty) text = text.substring(0, text.length - 1);
              } else if (text.length < 12 &&
                  !(key == '.' && text.contains('.'))) {
                text += key;
              }
              controller.value = const AmountInputFormatter().formatEditUpdate(
                controller.value,
                TextEditingValue(
                  text: text,
                  selection: TextSelection.collapsed(offset: text.length),
                ),
              );
              HapticFeedback.selectionClick();
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark(c)
                    ? const Color(0xFF343A35)
                    : const Color(0xFFE2E5DC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: key == '⌫'
                  ? Icon(CupertinoIcons.delete_left, color: ink(c), size: 23)
                  : Text(
                      key,
                      style: TextStyle(
                        color: ink(c),
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        )
        .toList(),
  );
}

const goalCategories = <String, (String, IconData)>{
  '🌱': ('Emergency fund', CupertinoIcons.shield),
  '💻': ('Laptop', CupertinoIcons.device_laptop),
  '✈️': ('Travel', CupertinoIcons.airplane),
  '📚': ('Education', CupertinoIcons.book),
  '🏡': ('Home', CupertinoIcons.house),
  '🎯': ('Other', CupertinoIcons.gift),
};
IconData goalIcon(SavingsGoal goal) =>
    goalCategories[goal.emoji]?.$2 ?? CupertinoIcons.flag;

class GoalSummary extends StatelessWidget {
  final SavingsGoal goal;
  const GoalSummary(this.goal, {super.key});
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Row(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GoalRing(
                      goal.progress,
                      muted(c).withValues(alpha: .25),
                      lilac,
                    ),
                  ),
                ),
                Text(
                  '${(goal.progress * 100).round()}%',
                  style: headline(c, 32),
                ),
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: SizedBox(
                    width: 65,
                    height: 65,
                    child: FittedBox(child: SavingsSprout(progress: .65)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${money(c, goal.savedAmount)}\n${t(c, 'saved')}',
                style: headline(c, 21),
              ),
              const SizedBox(height: 5),
              Text(
                '${t(c, 'of')} ${money(c, goal.targetAmount)}',
                style: TextStyle(color: muted(c), fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    CupertinoIcons.square_stack_3d_up,
                    size: 20,
                    color: ink(c),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${money(c, goal.remainingAmount)}\n${t(c, 'remaining')}',
                      style: TextStyle(color: ink(c), fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(CupertinoIcons.calendar, size: 20, color: ink(c)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${t(c, 'Due')} ${dateLabel(goal.deadline)}',
                      style: TextStyle(color: ink(c), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class MilestoneRail extends StatelessWidget {
  final SavingsGoal goal;
  const MilestoneRail(this.goal, {super.key});
  @override
  Widget build(BuildContext c) => Row(
    children: [25, 50, 75, 100].map((percent) {
      final reached = goal.progress * 100 >= percent;
      return Expanded(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Container(height: 1, color: muted(c))),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: reached ? lime : panel(c),
                    border: Border.all(
                      color: reached ? lime : ink(c),
                      width: 1.5,
                    ),
                  ),
                  child: reached
                      ? const Icon(
                          CupertinoIcons.checkmark,
                          color: forest,
                          size: 13,
                        )
                      : null,
                ),
                Expanded(child: Container(height: 1, color: muted(c))),
              ],
            ),
            const SizedBox(height: 8),
            Text('$percent%', style: TextStyle(color: ink(c), fontSize: 11)),
          ],
        ),
      );
    }).toList(),
  );
}

class OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const OutlineButton(this.label, this.icon, this.onPressed, {super.key});
  @override
  Widget build(BuildContext c) => CupertinoButton(
    padding: EdgeInsets.zero,
    onPressed: onPressed,
    child: Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 46),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: ink(c).withValues(alpha: .8)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: ink(c)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              t(c, label),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ink(c),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class HomeOverview extends StatelessWidget {
  final VoidCallback onAllGoals;
  const HomeOverview({super.key, required this.onAllGoals});
  @override
  Widget build(BuildContext c) {
    final vm = c.watch<GoalsViewModel>();
    final settings = c.watch<AppSettings>();
    final insights = SavingInsights(vm.transactions);
    return CupertinoPageScaffold(
      backgroundColor: canvas(c),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Saving Goals', style: headline(c, 17)),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () =>
                            settings.setHideBalances(!settings.hideBalances),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: panel(c),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            settings.hideBalances
                                ? CupertinoIcons.eye_slash
                                : CupertinoIcons.eye,
                            size: 20,
                            color: ink(c),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t(c, 'Make progress, your way.'),
                    style: headline(c, 25).copyWith(height: 1.12),
                  ),
                  const SizedBox(height: 12),
                  StreakCard(insights: insights, progress: vm.overallProgress),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: lime,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total saved',
                          style: TextStyle(
                            color: forest,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            money(c, vm.totalSaved),
                            style: const TextStyle(
                              color: forest,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ProgressTrack(vm.overallProgress, onGreen: true),
                        const SizedBox(height: 8),
                        Text(
                          '${(vm.overallProgress * 100).round()}% ${t(c, 'of')} ${money(c, vm.totalTarget)}',
                          style: const TextStyle(
                            color: forest,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _HomeMetric(
                          CupertinoIcons.scope,
                          '${vm.activeGoals}',
                          'active goals',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HomeMetric(
                          CupertinoIcons.square_stack_3d_up,
                          money(c, vm.totalRemaining),
                          'to go',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          'Add savings',
                          onPressed: () =>
                              openPage(c, const TransactionEditor()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlineButton(
                          'New goal',
                          CupertinoIcons.plus,
                          () => openPage(c, const GoalEditor()),
                        ),
                      ),
                    ],
                  ),
                  const DataStatus(),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t(c, 'Your goals'),
                            style: headline(c, 20),
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: onAllGoals,
                          child: Text(
                            t(c, 'See all'),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (vm.goals.isEmpty && !vm.isLoading && vm.error == null)
                    EmptyState(
                      'Your next chapter starts here',
                      'Create a goal, choose a date, and take the first small step.',
                      onAdd: () => openPage(c, const GoalEditor()),
                    ),
                  ...vm.goals
                      .take(3)
                      .map((goal) => GoalTile(goal, compact: true)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeMetric extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _HomeMetric(this.icon, this.value, this.label);
  @override
  Widget build(BuildContext c) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: panel(c),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Icon(icon, color: ink(c), size: 21),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value, style: headline(c, 14)),
              ),
              Text(
                t(c, label),
                style: TextStyle(color: muted(c), fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class GoalTile extends StatelessWidget {
  final SavingsGoal goal;
  final bool compact;
  const GoalTile(this.goal, {super.key, this.compact = false});
  @override
  Widget build(BuildContext c) {
    final color = (goal.id ?? 1).isOdd ? lilac : peach;
    final icon = goalIcon(goal);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => openPage(c, GoalDetail(goal)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 12 : 16),
          decoration: BoxDecoration(
            color: panel(c),
            borderRadius: BorderRadius.circular(compact ? 18 : 24),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: compact ? 40 : 46,
                height: compact ? 40 : 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 24, color: forest),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: headline(c, compact ? 14 : 16),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${(goal.progress * 100).round()}%',
                          style: TextStyle(
                            color: ink(c),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      compact
                          ? '${money(c, goal.savedAmount)} ${t(c, 'of')} ${money(c, goal.targetAmount)}'
                          : '${t(c, 'Due')} ${dateLabel(goal.deadline)}',
                      style: TextStyle(color: muted(c), fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    ProgressTrack(goal.progress, color: color),
                    if (!compact) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${money(c, goal.savedAmount)} ${t(c, 'saved')}',
                              style: TextStyle(color: ink(c), fontSize: 11),
                            ),
                          ),
                          Text(
                            '${t(c, 'of')} ${money(c, goal.targetAmount)}',
                            style: TextStyle(color: muted(c), fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
