import 'savings_goal.dart';

/// Calendar-day plan. The deadline itself is a saving day; overdue goals have
/// no suggested pace until their deadline is updated. No currency conversion.
class SavingsPlan {
  final SavingsGoal goal;
  final DateTime today;
  SavingsPlan(this.goal, {DateTime? now}) : today = now ?? DateTime.now();

  int get daysLeft {
    final end = DateTime.utc(
      goal.deadline.year,
      goal.deadline.month,
      goal.deadline.day,
    );
    final start = DateTime.utc(today.year, today.month, today.day);
    return (end.difference(start).inDays + 1).clamp(0, 1000000);
  }

  bool get needsNewDeadline => !goal.isCompleted && daysLeft == 0;
  double? amountPer(int days) {
    assert(days > 0);
    if (goal.isCompleted) return 0;
    if (needsNewDeadline) return null;
    return goal.remainingAmount / (daysLeft / days).ceil();
  }

  double? get daily => amountPer(1);
  double? get weekly => amountPer(7);
  double? get monthly => amountPer(30);
  List<int> get reachedMilestones => [
    25,
    50,
    75,
    100,
  ].where((percent) => goal.progress * 100 >= percent).toList();
  int? get nextMilestone {
    for (final percent in [25, 50, 75, 100]) {
      if (goal.progress * 100 < percent) return percent;
    }
    return null;
  }

  double get amountToNextMilestone => nextMilestone == null
      ? 0
      : (goal.targetAmount * nextMilestone! / 100 - goal.savedAmount).clamp(
          0,
          double.infinity,
        );
}
