part of 'save_goals_app.dart';

class GoalTile extends StatelessWidget {
  final SavingsGoal goal;
  const GoalTile(this.goal, {super.key});
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => openPage(c, GoalDetail(goal)),
      child: Panel(
        color: goal.progress >= .75
            ? CupertinoDynamicColor.resolve(
                const CupertinoDynamicColor.withBrightness(
                  color: Color(0xFFE2F3C9),
                  darkColor: Color(0xFF20351B),
                ),
                c,
              )
            : CupertinoDynamicColor.resolve(
                const CupertinoDynamicColor.withBrightness(
                  color: Color(0xFFEBE4F6),
                  darkColor: Color(0xFF2A2435),
                ),
                c,
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: canvas(c),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(goal.emoji, style: const TextStyle(fontSize: 25)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.name, style: headline(c, 17)),
                      const SizedBox(height: 4),
                      Text(
                        goal.isCompleted
                            ? t(c, 'Goal achieved')
                            : dateLabel(goal.deadline),
                        style: TextStyle(color: muted(c), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(CupertinoIcons.chevron_forward, color: muted(c), size: 15),
              ],
            ),
            const SizedBox(height: 18),
            ProgressTrack(goal.progress),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    money(c, goal.savedAmount),
                    style: TextStyle(
                      color: ink(c),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${(goal.progress * 100).round()}%',
                  style: TextStyle(
                    color: accent.resolveFrom(c),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});
  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  int filter = 0;
  @override
  Widget build(BuildContext c) {
    final vm = c.watch<GoalsViewModel>();
    final goals = vm.goals
        .where(
          (g) => filter == 0 || (filter == 1 ? !g.isCompleted : g.isCompleted),
        )
        .toList();
    return PageShell(
      title: 'Goals',
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => openPage(c, const GoalEditor()),
        child: Icon(
          CupertinoIcons.plus_circle_fill,
          semanticLabel: t(c, 'Create Goal'),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: filter,
              children: {
                0: Text(t(c, 'All')),
                1: Text(t(c, 'Active')),
                2: Text(t(c, 'Completed')),
              },
              onValueChanged: (v) => setState(() => filter = v ?? 0),
            ),
          ),
          const SizedBox(height: 20),
          const DataStatus(),
          ...goals.map((g) => GoalTile(g)),
          if (goals.isEmpty && !vm.isLoading && vm.error == null)
            EmptyState(
              'A goal for every chapter',
              filter == 2
                  ? 'Completed goals will appear here.'
                  : 'Give your next goal a name and a date.',
              onAdd: () => openPage(c, const GoalEditor()),
            ),
        ],
      ),
    );
  }
}

class PlanCard extends StatefulWidget {
  final SavingsGoal goal;
  const PlanCard(this.goal, {super.key});
  @override
  State<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {
  int cadence = 0;
  @override
  Widget build(BuildContext c) {
    final plan = SavingsPlan(widget.goal);
    final amount = [plan.daily, plan.weekly, plan.monthly][cadence];
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.goal.name, style: headline(c, 18)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: cadence,
              children: {
                0: Text(t(c, 'Daily')),
                1: Text(t(c, 'Weekly')),
                2: Text(t(c, 'Monthly')),
              },
              onValueChanged: (v) => setState(() => cadence = v ?? 0),
            ),
          ),
          const SizedBox(height: 20),
          if (plan.needsNewDeadline) ...[
            Text(
              t(c, 'Let’s give your plan a new date.'),
              style: headline(c, 18),
            ),
            const SizedBox(height: 8),
            Text(
              t(c, 'Update the deadline to see a suggested saving amount.'),
              style: TextStyle(color: muted(c), fontSize: 14),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => openPage(c, GoalEditor(goal: widget.goal)),
              child: Text(t(c, 'Edit Goal')),
            ),
          ] else ...[
            Text(money(c, amount ?? 0), style: headline(c, 30)),
            const SizedBox(height: 6),
            Text(
              t(
                c,
                widget.goal.isCompleted
                    ? 'You made it. Well done!'
                    : ['per day', 'per week', 'per 30-day period'][cadence],
              ),
              style: TextStyle(color: muted(c), fontSize: 14),
            ),
            if (!widget.goal.isCompleted) ...[
              const SizedBox(height: 12),
              Text(
                '${plan.daysLeft} ${t(c, 'saving days left, including the deadline.')}',
                style: TextStyle(color: muted(c), fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 6),
              Text(
                t(c, 'A suggested pace, not an automatic transfer.'),
                style: TextStyle(color: muted(c), fontSize: 12),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class GoalDetail extends StatelessWidget {
  final SavingsGoal initial;
  const GoalDetail(this.initial, {super.key});
  @override
  Widget build(BuildContext c) {
    final vm = c.watch<GoalsViewModel>();
    final goal = vm.getGoalById(initial.id ?? -1) ?? initial;
    final plan = SavingsPlan(goal);
    final transactions = vm.transactions.where((tx) => tx.goalId == goal.id);
    return PageShell(
      title: goal.name,
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => openPage(c, GoalEditor(goal: goal)),
        child: Text(t(c, 'Edit')),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.emoji, style: const TextStyle(fontSize: 42)),
                const SizedBox(height: 20),
                Text(money(c, goal.savedAmount), style: headline(c, 34)),
                const SizedBox(height: 6),
                Text(
                  '${t(c, 'Target')}: ${money(c, goal.targetAmount)}',
                  style: TextStyle(color: muted(c)),
                ),
                const SizedBox(height: 22),
                ProgressTrack(goal.progress),
                const SizedBox(height: 14),
                Text(
                  '${(goal.progress * 100).round()}% · ${dateLabel(goal.deadline)}',
                  style: TextStyle(color: muted(c), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            'Add savings',
            onPressed: () => openPage(c, TransactionEditor(goalId: goal.id)),
          ),
          Center(
            child: CupertinoButton(
              onPressed: () => openPage(
                c,
                TransactionEditor(goalId: goal.id, withdraw: true),
              ),
              child: Text(t(c, 'Record a withdrawal')),
            ),
          ),
          const Section('Your savings plan'),
          PlanCard(goal),
          const Section('Milestones'),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [25, 50, 75, 100].map((percent) {
                    final reached = plan.reachedMilestones.contains(percent);
                    return Semantics(
                      label:
                          '$percent% ${t(c, reached ? 'Reached' : 'Not reached')}',
                      child: Container(
                        width: 64,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: reached ? lime : canvas(c),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              reached
                                  ? CupertinoIcons.checkmark_seal_fill
                                  : CupertinoIcons.flag,
                              color: reached ? forest : muted(c),
                              size: 25,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$percent%',
                              style: TextStyle(
                                color: reached ? forest : muted(c),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Text(
                  plan.nextMilestone == null
                      ? t(c, 'Goal achieved. Enjoy this moment.')
                      : '${money(c, plan.amountToNextMilestone)} ${t(c, 'to your next milestone')} (${plan.nextMilestone}%).',
                  style: TextStyle(color: muted(c), fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  t(c, 'Milestones reflect your current balance.'),
                  style: TextStyle(color: muted(c), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            'Share your progress',
            onPressed: () => openPage(c, ProgressSharePage(goal)),
          ),
          const Section('Goal activity'),
          if (transactions.isEmpty)
            Text(
              t(c, 'Your savings activity will appear here.'),
              style: TextStyle(color: muted(c)),
            ),
          ...transactions.map((tx) => TransactionTile(tx)),
          const SizedBox(height: 24),
          CupertinoButton(
            onPressed: () async {
              if (!await confirm(
                c,
                t(c, 'Delete Goal?'),
                t(
                  c,
                  'This also deletes its transactions. This cannot be undone.',
                ),
              )) {
                return;
              }
              if (!c.mounted) return;
              try {
                await c.read<GoalsViewModel>().deleteGoal(goal.id!);
                if (c.mounted) Navigator.pop(c);
              } catch (e) {
                if (c.mounted) {
                  await alert(
                    c,
                    t(c, 'Error'),
                    t(c, 'Could not save your changes. Please try again.'),
                  );
                }
              }
            },
            child: Text(
              t(c, 'Delete Goal'),
              style: const TextStyle(color: CupertinoColors.systemRed),
            ),
          ),
        ],
      ),
    );
  }
}
