part of 'save_goals_app.dart';

Future<void> editGoalFromDetail(BuildContext c, SavingsGoal goal) async {
  final deleted = await Navigator.of(
    c,
    rootNavigator: true,
  ).push<bool>(CupertinoPageRoute(builder: (_) => GoalEditor(goal: goal)));
  if (deleted == true && c.mounted) Navigator.pop(c);
}

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});
  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  int filter = 1;
  @override
  Widget build(BuildContext c) {
    final vm = c.watch<GoalsViewModel>();
    final goals = vm.goals
        .where(
          (g) => filter == 0 || (filter == 1 ? !g.isCompleted : g.isCompleted),
        )
        .toList();
    return PageShell(
      title: 'Your goals',
      rootTab: true,
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
            child: SavingsSegments<int>(
              groupValue: filter,
              children: {1: Text(t(c, 'Active')), 2: Text(t(c, 'Completed'))},
              onValueChanged: (v) => setState(() => filter = v ?? 0),
            ),
          ),
          const SizedBox(height: 20),
          const DataStatus(),
          ...goals.map((g) => GoalTile(g)),
          if (goals.isNotEmpty) ...[
            const SizedBox(height: 28),
            const SizedBox(
              height: 110,
              width: 110,
              child: FittedBox(child: SavingsSprout(progress: .5)),
            ),
            const SizedBox(height: 8),
            Text(
              t(c, 'Every goal starts with one small step.'),
              textAlign: TextAlign.center,
              style: TextStyle(color: muted(c), fontSize: 14),
            ),
          ],
          if (goals.isEmpty && !vm.isLoading && vm.error == null)
            EmptyState(
              'Big plans start small.',
              filter == 2
                  ? 'Completed goals will appear here.'
                  : 'Create your first goal. We’ll help you find your pace.',
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
          Text(t(c, 'Your saving pace'), style: headline(c, 18)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SavingsSegments<int>(
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
              onPressed: () => editGoalFromDetail(c, widget.goal),
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
            const SizedBox(height: 5),
            Text(
              t(c, 'Suggested pace'),
              style: TextStyle(color: muted(c), fontSize: 11),
            ),
          ],
          const SizedBox(height: 24),
          MilestoneRail(widget.goal),
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
    final transactions = vm.transactions.where((tx) => tx.goalId == goal.id);
    return PageShell(
      title: goal.name,
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => editGoalFromDetail(c, goal),
        child: Text(t(c, 'Edit')),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GoalSummary(goal),
          const SizedBox(height: 12),
          PlanCard(goal),
          const SizedBox(height: 24),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: PrimaryButton(
                    'Add savings',
                    onPressed: () =>
                        openPage(c, TransactionEditor(goalId: goal.id)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlineButton(
                    'Withdrawal',
                    CupertinoIcons.minus_circle,
                    () => openPage(
                      c,
                      TransactionEditor(goalId: goal.id, withdraw: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlineButton(
            'Share your progress',
            CupertinoIcons.share,
            () => openPage(c, ProgressSharePage(goal)),
          ),
          const Section('Goal activity'),
          if (transactions.isEmpty)
            Text(
              t(c, 'Your savings activity will appear here.'),
              style: TextStyle(color: muted(c)),
            ),
          ...transactions.map((tx) => TransactionTile(tx)),
        ],
      ),
    );
  }
}

class _GoalRing extends CustomPainter {
  final double progress;
  final Color track, fill;
  _GoalRing(this.progress, this.track, this.fill);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(7);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawOval(rect, paint);
    paint.color = fill;
    canvas.drawArc(
      rect,
      -1.5708,
      6.283185 * progress.clamp(0, 1),
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_GoalRing old) =>
      old.progress != progress || old.track != track || old.fill != fill;
}
