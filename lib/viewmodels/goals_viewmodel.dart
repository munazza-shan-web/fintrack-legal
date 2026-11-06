import 'package:flutter/foundation.dart';

import '../models/savings_goal.dart';
import '../models/savings_transaction.dart';
import '../services/database_service.dart';

class GoalsViewModel extends ChangeNotifier {
  final DatabaseService _database = DatabaseService.instance;

  List<SavingsGoal> _goals = [];
  List<SavingsTransaction> _transactions = [];

  bool _isLoading = false;
  String? _error;

  List<SavingsGoal> get goals => List.unmodifiable(_goals);
  List<SavingsTransaction> get transactions => List.unmodifiable(_transactions);

  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalSaved =>
      _goals.fold(0, (total, goal) => total + goal.savedAmount);

  double get totalTarget =>
      _goals.fold(0, (total, goal) => total + goal.targetAmount);

  double get totalRemaining =>
      _goals.fold(0, (total, goal) => total + goal.remainingAmount);

  int get activeGoals => _goals.where((goal) => !goal.isCompleted).length;

  int get completedGoals => _goals.where((goal) => goal.isCompleted).length;

  double get overallProgress {
    if (totalTarget <= 0) return 0;
    return (totalSaved / totalTarget).clamp(0.0, 1.0);
  }

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _goals = await _database.getGoals();
      _transactions = await _database.getTransactions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGoal(SavingsGoal goal) async {
    try {
      await _database.addGoal(goal);
      await loadData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateGoal(SavingsGoal goal) async {
    try {
      await _database.updateGoal(goal);
      await loadData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteGoal(int goalId) async {
    try {
      await _database.deleteGoal(goalId);
      await loadData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addDeposit({
    required int goalId,
    required double amount,
    String? note,
    DateTime? date,
  }) async {
    await _addTransaction(
      goalId: goalId,
      type: TransactionType.deposit,
      amount: amount,
      note: note,
      date: date,
    );
  }

  Future<void> addWithdrawal({
    required int goalId,
    required double amount,
    String? note,
    DateTime? date,
  }) async {
    await _addTransaction(
      goalId: goalId,
      type: TransactionType.withdrawal,
      amount: amount,
      note: note,
      date: date,
    );
  }

  Future<void> _addTransaction({
    required int goalId,
    required TransactionType type,
    required double amount,
    String? note,
    DateTime? date,
  }) async {
    try {
      await _database.addTransaction(
        goalId: goalId,
        type: type,
        amount: amount,
        note: note,
        date: date,
      );

      await loadData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    try {
      await _database.deleteTransaction(transactionId);
      await loadData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  SavingsGoal? getGoalById(int id) {
    for (final goal in _goals) {
      if (goal.id == id) return goal;
    }
    return null;
  }
}
