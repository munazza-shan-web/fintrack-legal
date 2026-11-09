part of 'save_goals_app.dart';

class TransactionTile extends StatelessWidget {
  final SavingsTransaction transaction;
  const TransactionTile(this.transaction, {super.key});
  @override
  Widget build(BuildContext c) {
    final goal = c.watch<GoalsViewModel>().getGoalById(transaction.goalId);
    final deposit = transaction.type == TransactionType.deposit;
    final color = (goal?.id ?? 1).isOdd ? lilac : peach;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: muted(c).withValues(alpha: .15)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              goal == null ? CupertinoIcons.flag : goalIcon(goal),
              color: forest,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal?.name ?? t(c, 'Deleted goal'),
                  style: headline(c, 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${t(c, deposit ? 'Deposit' : 'Withdraw')} · ${dateLabel(transaction.date)}',
                  style: TextStyle(color: muted(c), fontSize: 11),
                ),
                if (transaction.note?.isNotEmpty ?? false)
                  Text(
                    transaction.note!,
                    style: TextStyle(color: muted(c), fontSize: 11),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '${deposit ? '+' : '−'} ${money(c, transaction.amount)}',
              textAlign: TextAlign.end,
              style: TextStyle(
                color: deposit ? accent.resolveFrom(c) : peach,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
        .where(
          (tx) =>
              tx.type == TransactionType.deposit &&
              tx.date.year == DateTime.now().year &&
              tx.date.month == DateTime.now().month,
        )
        .fold<double>(0, (a, tx) => a + tx.amount);
    final withdrawals = vm.transactions
        .where(
          (tx) =>
              tx.type == TransactionType.withdrawal &&
              tx.date.year == DateTime.now().year &&
              tx.date.month == DateTime.now().month,
        )
        .fold<double>(0, (a, tx) => a + tx.amount);
    return PageShell(
      title: 'Your activity',
      rootTab: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ActivitySummaryCard(
                    key: const ValueKey('monthly-deposits'),
                    label: 'Saved this month',
                    value: money(c, deposits),
                    icon: CupertinoIcons.arrow_down,
                    color: accent.resolveFrom(c),
                    onTap: () => setState(() => filter = 1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ActivitySummaryCard(
                    key: const ValueKey('monthly-withdrawals'),
                    label: 'Withdrawn this month',
                    value: money(c, withdrawals),
                    icon: CupertinoIcons.arrow_up,
                    color: peach,
                    onTap: () => setState(() => filter = 2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SavingsChart(vm.transactions),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SavingsSegments<int>(
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
          CupertinoSearchTextField(
            placeholder: t(c, 'Search goals or notes'),
            onChanged: (value) => setState(() => query = value),
          ),
          const SizedBox(height: 16),
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
