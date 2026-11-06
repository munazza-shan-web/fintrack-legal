class SavingsGoal {
  final int? id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime deadline;
  final String emoji;
  final DateTime createdAt;

  const SavingsGoal({
    this.id,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0,
    required this.deadline,
    this.emoji = '🎯',
    required this.createdAt,
  });

  double get progress {
    if (targetAmount <= 0) return 0;
    return (savedAmount / targetAmount).clamp(0.0, 1.0);
  }

  double get remainingAmount {
    return (targetAmount - savedAmount).clamp(0.0, double.infinity);
  }

  bool get isCompleted => savedAmount >= targetAmount;

  bool get isOverdue => !isCompleted && deadline.isBefore(DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'saved_amount': savedAmount,
      'deadline': deadline.toIso8601String(),
      'emoji': emoji,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'] as int?,
      name: map['name'] as String,
      targetAmount: (map['target_amount'] as num).toDouble(),
      savedAmount: (map['saved_amount'] as num).toDouble(),
      deadline: DateTime.parse(map['deadline'] as String),
      emoji: map['emoji'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  SavingsGoal copyWith({
    int? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? deadline,
    String? emoji,
    DateTime? createdAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      deadline: deadline ?? this.deadline,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
