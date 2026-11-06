import 'savings_transaction.dart';

/// Derived from recorded deposits, never from opening the app or invented data.
class SavingInsights {
  final Iterable<SavingsTransaction> transactions;
  final DateTime now;
  SavingInsights(this.transactions, {DateTime? now})
    : now = now ?? DateTime.now();
  static DateTime calendarDay(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day);
  Set<DateTime> get days => transactions
      .where(
        (t) =>
            t.type == TransactionType.deposit &&
            t.amount > 0 &&
            !calendarDay(t.date).isAfter(calendarDay(now)),
      )
      .map((t) => calendarDay(t.date))
      .toSet();
  int get streak {
    final recorded = days;
    var cursor = calendarDay(now);
    if (!recorded.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var result = 0;
    while (recorded.contains(cursor)) {
      result++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return result;
  }

  List<bool> get week => List.generate(
    7,
    (i) => days.contains(calendarDay(now).subtract(Duration(days: 6 - i))),
  );
}
