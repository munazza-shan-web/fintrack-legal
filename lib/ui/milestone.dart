part of 'save_goals_app.dart';

class MilestoneDialog extends StatelessWidget {
  final SavingsGoal goal;
  final int percent;
  const MilestoneDialog(this.goal, this.percent, {super.key});
  @override
  Widget build(BuildContext c) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: panel(c),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: muted(c).withValues(alpha: .25)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SavingsSprout(progress: goal.progress),
                Text('$percent%', style: headline(c, 58)),
                const SizedBox(height: 8),
                Text(
                  t(
                    c,
                    percent == 50
                        ? 'Halfway feels good.'
                        : 'A milestone worth celebrating',
                  ),
                  textAlign: TextAlign.center,
                  style: headline(c, 22),
                ),
                const SizedBox(height: 14),
                Text(
                  t(c, 'Every small step brought you here.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted(c), fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  'Share this win',
                  onPressed: () => Navigator.pop(c, true),
                ),
                const SizedBox(height: 12),
                OutlineButton(
                  'Keep saving',
                  CupertinoIcons.checkmark,
                  () => Navigator.pop(c, false),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
