import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/models/savings_goal.dart';
import 'package:fintrack/models/savings_plan.dart';

SavingsGoal goal({double saved = 0, DateTime? deadline}) => SavingsGoal(
  name: 'Course',
  targetAmount: 1000,
  savedAmount: saved,
  deadline: deadline ?? DateTime(2027, 1, 10),
  createdAt: DateTime(2027, 1, 1),
);
void main() {
  test('Plans use remaining amount and inclusive calendar days', () {
    final plan = SavingsPlan(
      goal(saved: 200),
      now: DateTime(2027, 1, 1, 23, 59),
    );
    expect(plan.daysLeft, 10);
    expect(plan.daily, 80);
    expect(plan.weekly, 400);
    expect(plan.monthly, 800);
  });
  test('The deadline is still a saving day', () {
    final plan = SavingsPlan(
      goal(saved: 200),
      now: DateTime(2027, 1, 10, 23, 59),
    );
    expect(plan.daysLeft, 1);
    expect(plan.daily, 800);
  });
  test('Overdue goals have no misleading suggested amount', () {
    final plan = SavingsPlan(goal(), now: DateTime(2027, 1, 11));
    expect(plan.needsNewDeadline, isTrue);
    expect(plan.daily, isNull);
    expect(plan.weekly, isNull);
  });
  test('Completed and overfunded goals need no more savings', () {
    for (final saved in [1000.0, 1500.0]) {
      final plan = SavingsPlan(goal(saved: saved), now: DateTime(2027, 2, 1));
      expect(plan.needsNewDeadline, isFalse);
      expect(plan.daily, 0);
      expect(plan.nextMilestone, isNull);
      expect(plan.reachedMilestones, [25, 50, 75, 100]);
    }
  });
  test('Milestones follow current balance, including withdrawals', () {
    expect(SavingsPlan(goal(saved: 249)).reachedMilestones, isEmpty);
    expect(SavingsPlan(goal(saved: 250)).reachedMilestones, [25]);
    final plan = SavingsPlan(goal(saved: 700));
    expect(plan.reachedMilestones, [25, 50]);
    expect(plan.nextMilestone, 75);
    expect(plan.amountToNextMilestone, 50);
    expect(SavingsPlan(goal(saved: 200)).nextMilestone, 25);
  });
  test('Month-end dates and leap days count correctly', () {
    expect(
      SavingsPlan(
        goal(deadline: DateTime(2028, 3, 1)),
        now: DateTime(2028, 2, 28),
      ).daysLeft,
      3,
    );
  });
  test('Existing stored goals round-trip without migration', () {
    final original = goal(saved: 275).copyWith(id: 42, emoji: '📚');
    final restored = SavingsGoal.fromMap(original.toMap());
    expect(restored.toMap(), original.toMap());
    expect(SavingsPlan(restored).reachedMilestones, [25]);
  });
}
