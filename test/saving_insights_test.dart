import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/models/saving_insights.dart';
import 'package:fintrack/models/savings_transaction.dart';

SavingsTransaction entry(int day, {bool withdraw = false}) =>
    SavingsTransaction(
      goalId: 1,
      type: withdraw ? TransactionType.withdrawal : TransactionType.deposit,
      amount: 10,
      date: DateTime(2026, 11, day),
    );
void main() {
  test('Streak counts deposit dates once and allows yesterday', () {
    final insight = SavingInsights([
      entry(4),
      entry(5),
      entry(5),
      entry(6),
    ], now: DateTime(2026, 11, 7));
    expect(insight.streak, 3);
    expect(insight.week, [false, false, false, true, true, true, false]);
  });
  test('Future entries and withdrawals never create saving days', () {
    final insight = SavingInsights([
      entry(7, withdraw: true),
      entry(8),
    ], now: DateTime(2026, 11, 7));
    expect(insight.streak, 0);
    expect(insight.week.every((v) => !v), isTrue);
  });
  test('A missed day breaks the streak', () {
    expect(
      SavingInsights([entry(4), entry(5)], now: DateTime(2026, 11, 7)).streak,
      0,
    );
  });
}
