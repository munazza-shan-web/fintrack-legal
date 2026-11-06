import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/savings_goal.dart';
import '../models/savings_transaction.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'fintrack.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE savings_goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            target_amount REAL NOT NULL,
            saved_amount REAL NOT NULL DEFAULT 0,
            deadline TEXT NOT NULL,
            emoji TEXT NOT NULL DEFAULT '🎯',
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE savings_transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            goal_id INTEGER NOT NULL,
            type TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            note TEXT,
            FOREIGN KEY (goal_id)
              REFERENCES savings_goals (id)
              ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // -----------------------------
  // SAVINGS GOALS
  // -----------------------------

  Future<int> addGoal(SavingsGoal goal) async {
    final db = await database;

    final goalMap = goal.toMap();
    goalMap.remove('id');

    return db.insert('savings_goals', goalMap);
  }

  Future<List<SavingsGoal>> getGoals() async {
    final db = await database;

    final results = await db.query('savings_goals', orderBy: 'created_at DESC');

    return results.map(SavingsGoal.fromMap).toList();
  }

  Future<SavingsGoal?> getGoalById(int id) async {
    final db = await database;

    final results = await db.query(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;

    return SavingsGoal.fromMap(results.first);
  }

  Future<int> updateGoal(SavingsGoal goal) async {
    if (goal.id == null) {
      throw ArgumentError('Goal ID is required for updating.');
    }

    final db = await database;

    final goalMap = goal.toMap();
    goalMap.remove('id');

    return db.update(
      'savings_goals',
      goalMap,
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;

    return db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
  }

  // -----------------------------
  // DEPOSITS AND WITHDRAWALS
  // -----------------------------

  Future<int> addTransaction({
    required int goalId,
    required TransactionType type,
    required double amount,
    String? note,
    DateTime? date,
  }) async {
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError('Amount must be a valid number greater than zero.');
    }

    final db = await database;

    return db.transaction((txn) async {
      final goalResults = await txn.query(
        'savings_goals',
        columns: ['saved_amount'],
        where: 'id = ?',
        whereArgs: [goalId],
        limit: 1,
      );

      if (goalResults.isEmpty) {
        throw Exception('Savings goal not found.');
      }

      final currentSaved = (goalResults.first['saved_amount'] as num)
          .toDouble();

      late double updatedSaved;

      if (type == TransactionType.deposit) {
        updatedSaved = currentSaved + amount;
      } else if (type == TransactionType.withdrawal) {
        if (amount > currentSaved) {
          throw Exception('Withdrawal cannot exceed the saved amount.');
        }

        updatedSaved = currentSaved - amount;
      } else {
        throw ArgumentError('Invalid transaction type.');
      }

      await txn.update(
        'savings_goals',
        {'saved_amount': updatedSaved},
        where: 'id = ?',
        whereArgs: [goalId],
      );

      final savingsTransaction = SavingsTransaction(
        goalId: goalId,
        type: type,
        amount: amount,
        date: date ?? DateTime.now(),
        note: note,
      );

      final transactionMap = savingsTransaction.toMap();
      transactionMap.remove('id');

      return txn.insert('savings_transactions', transactionMap);
    });
  }

  Future<List<SavingsTransaction>> getTransactions() async {
    final db = await database;

    final results = await db.query(
      'savings_transactions',
      orderBy: 'date DESC',
    );

    return results.map(SavingsTransaction.fromMap).toList();
  }

  Future<List<SavingsTransaction>> getTransactionsForGoal(int goalId) async {
    final db = await database;

    final results = await db.query(
      'savings_transactions',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'date DESC',
    );

    return results.map(SavingsTransaction.fromMap).toList();
  }

  Future<int> deleteTransaction(int transactionId) async {
    final db = await database;

    return db.transaction((txn) async {
      final results = await txn.query(
        'savings_transactions',
        where: 'id = ?',
        whereArgs: [transactionId],
        limit: 1,
      );

      if (results.isEmpty) return 0;

      final savingsTransaction = SavingsTransaction.fromMap(results.first);

      final goalResults = await txn.query(
        'savings_goals',
        columns: ['saved_amount'],
        where: 'id = ?',
        whereArgs: [savingsTransaction.goalId],
        limit: 1,
      );

      if (goalResults.isEmpty) {
        throw Exception('Savings goal not found.');
      }

      final currentSaved = (goalResults.first['saved_amount'] as num)
          .toDouble();

      late double updatedSaved;

      if (savingsTransaction.type == TransactionType.deposit) {
        if (savingsTransaction.amount > currentSaved) {
          throw Exception(
            'This deposit cannot be deleted because some of its '
            'money has already been withdrawn.',
          );
        }

        updatedSaved = currentSaved - savingsTransaction.amount;
      } else {
        updatedSaved = currentSaved + savingsTransaction.amount;
      }

      await txn.update(
        'savings_goals',
        {'saved_amount': updatedSaved},
        where: 'id = ?',
        whereArgs: [savingsTransaction.goalId],
      );

      return txn.delete(
        'savings_transactions',
        where: 'id = ?',
        whereArgs: [transactionId],
      );
    });
  }

  // -----------------------------
  // DATABASE MAINTENANCE
  // -----------------------------

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
