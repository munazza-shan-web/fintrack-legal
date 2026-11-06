part of 'save_goals_app.dart';

class TransactionTile extends StatelessWidget {
  final SavingsTransaction transaction;
  const TransactionTile(this.transaction, {super.key});
  @override
  Widget build(BuildContext c) {
    final goal = c.watch<GoalsViewModel>().getGoalById(transaction.goalId);
    final deposit = transaction.type == TransactionType.deposit;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  deposit
                      ? CupertinoIcons.arrow_down_left
                      : CupertinoIcons.arrow_up_right,
                  color: deposit
                      ? accent.resolveFrom(c)
                      : CupertinoColors.systemRed,
                  size: 21,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    goal?.name ?? t(c, 'Deleted goal'),
                    style: headline(c, 16),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${deposit ? '+' : '−'} ${money(c, transaction.amount)}',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: deposit
                          ? accent.resolveFrom(c)
                          : CupertinoColors.systemRed,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${t(c, deposit ? 'Deposit' : 'Withdraw')} · ${dateLabel(transaction.date)}',
              style: TextStyle(color: muted(c), fontSize: 12),
            ),
            if (transaction.note?.isNotEmpty ?? false) ...[
              const SizedBox(height: 6),
              Text(
                transaction.note!,
                style: TextStyle(color: muted(c), fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});
  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int filter = 0;
  String query = '';
  @override
  Widget build(BuildContext c) {
    final vm = c.watch<GoalsViewModel>();
    final transactions = vm.transactions.where((tx) {
      final matches =
          filter == 0 ||
          (filter == 1
              ? tx.type == TransactionType.deposit
              : tx.type == TransactionType.withdrawal);
      final text = '${vm.getGoalById(tx.goalId)?.name ?? ''} ${tx.note ?? ''}'
          .toLowerCase();
      return matches && text.contains(query.trim().toLowerCase());
    }).toList();
    final deposits = vm.transactions
        .where((tx) => tx.type == TransactionType.deposit)
        .fold<double>(0, (a, tx) => a + tx.amount);
    final withdrawals = vm.transactions
        .where((tx) => tx.type == TransactionType.withdrawal)
        .fold<double>(0, (a, tx) => a + tx.amount);
    return PageShell(
      title: 'Activity',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _Metric(
                  'Deposits',
                  money(c, deposits),
                  CupertinoIcons.arrow_down_left,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Metric(
                  'Withdrawals',
                  money(c, withdrawals),
                  CupertinoIcons.arrow_up_right,
                ),
              ),
            ],
          ),
          const Section('Last 6 months'),
          _SavingsChart(vm.transactions),
          const Section('Transactions'),
          CupertinoSearchTextField(
            placeholder: t(c, 'Search goals or notes'),
            onChanged: (value) => setState(() => query = value),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: filter,
              children: {
                0: Text(t(c, 'All')),
                1: Text(t(c, 'Deposits')),
                2: Text(t(c, 'Withdrawals')),
              },
              onValueChanged: (v) => setState(() => filter = v ?? 0),
            ),
          ),
          const SizedBox(height: 20),
          const DataStatus(),
          ...transactions.map((tx) => TransactionTile(tx)),
          if (transactions.isEmpty && !vm.isLoading && vm.error == null)
            EmptyState(
              'No activity here yet',
              'Your savings activity will appear here.',
            ),
        ],
      ),
    );
  }
}

class _SavingsChart extends StatelessWidget {
  final List<SavingsTransaction> transactions;
  const _SavingsChart(this.transactions);
  @override
  Widget build(BuildContext c) {
    final now = DateTime.now();
    final months = List.generate(
      6,
      (i) => DateTime(now.year, now.month - 5 + i),
    );
    final totals = months
        .map(
          (month) => transactions
              .where(
                (tx) =>
                    tx.type == TransactionType.deposit &&
                    tx.date.year == month.year &&
                    tx.date.month == month.month,
              )
              .fold<double>(0, (sum, tx) => sum + tx.amount),
        )
        .toList();
    final max = totals.fold<double>(0, (a, b) => a > b ? a : b);
    final hidden = c.watch<AppSettings>().hideBalances;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t(c, 'Deposits by month'),
            style: TextStyle(color: muted(c), fontSize: 13),
          ),
          const SizedBox(height: 20),
          if (hidden)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: Text(
                t(c, 'Balances hidden'),
                style: TextStyle(color: muted(c)),
              ),
            )
          else
            SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  6,
                  (i) => Expanded(
                    child: Semantics(
                      label:
                          '${DateFormat('MMM yyyy').format(months[i])}: ${money(c, totals[i])}',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: max == 0 ? 4 : 4 + 96 * totals[i] / max,
                              decoration: BoxDecoration(
                                color: max == 0
                                    ? CupertinoColors.systemFill.resolveFrom(c)
                                    : accent.resolveFrom(c),
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              DateFormat('MMM').format(months[i]),
                              style: TextStyle(color: muted(c), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (max == 0 && !hidden) ...[
            const SizedBox(height: 12),
            Text(
              t(c, 'Add savings to see your progress over time.'),
              style: TextStyle(color: muted(c), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
