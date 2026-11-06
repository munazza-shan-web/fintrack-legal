enum TransactionType { deposit, withdrawal }

class SavingsTransaction {
  final int? id;
  final int goalId;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String? note;

  const SavingsTransaction({
    this.id,
    required this.goalId,
    required this.type,
    required this.amount,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'type': type.name,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory SavingsTransaction.fromMap(Map<String, dynamic> map) {
    return SavingsTransaction(
      id: map['id'] as int?,
      goalId: map['goal_id'] as int,
      type: TransactionType.values.firstWhere(
        (value) => value.name == map['type'],
      ),
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
    );
  }
}
