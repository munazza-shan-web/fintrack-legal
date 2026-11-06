part of 'save_goals_app.dart';

class EntryField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool numeric;
  final int? maxLength;
  const EntryField(
    this.label,
    this.controller, {
    super.key,
    this.numeric = false,
    this.maxLength,
  });
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t(c, label),
          style: TextStyle(
            color: muted(c),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 9),
        CupertinoTextField(
          controller: controller,
          placeholder: t(c, label),
          maxLength: maxLength,
          keyboardType: numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          textInputAction: TextInputAction.next,
          padding: const EdgeInsets.all(18),
          style: TextStyle(color: ink(c), fontSize: 17),
          decoration: BoxDecoration(
            color: panel(c),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    ),
  );
}

DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);
Future<DateTime?> chooseDate(
  BuildContext c,
  DateTime initial, {
  bool pastOnly = false,
}) async {
  final now = DateTime.now();
  final minimum = pastOnly ? DateTime(2000) : day(now);
  final maximum = pastOnly ? day(now) : DateTime(2100, 12, 31);
  var value = day(initial);
  if (value.isBefore(minimum)) value = minimum;
  if (value.isAfter(maximum)) value = maximum;
  return showCupertinoModalPopup<DateTime>(
    context: c,
    builder: (sheet) => Container(
      color: panel(c),
      height: 330 + MediaQuery.paddingOf(sheet).bottom,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  onPressed: () => Navigator.pop(sheet),
                  child: Text(t(c, 'Cancel')),
                ),
                CupertinoButton(
                  onPressed: () => Navigator.pop(sheet, value),
                  child: Text(t(c, 'Done')),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: value,
                minimumDate: minimum,
                maximumDate: maximum,
                onDateTimeChanged: (date) => value = date,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

double? parseAmount(String value) {
  final parsed = double.tryParse(value.trim().replaceAll(',', ''));
  return parsed != null && parsed.isFinite && parsed > 0 ? parsed : null;
}

class GoalEditor extends StatefulWidget {
  final SavingsGoal? goal;
  const GoalEditor({super.key, this.goal});
  @override
  State<GoalEditor> createState() => _GoalEditorState();
}

class _GoalEditorState extends State<GoalEditor> {
  late final name = TextEditingController(text: widget.goal?.name);
  late final amount = TextEditingController(
    text: widget.goal?.targetAmount.toStringAsFixed(2),
  );
  late DateTime deadline =
      widget.goal?.deadline ??
      day(DateTime.now()).add(const Duration(days: 90));
  late String emoji = widget.goal?.emoji ?? '🎯';
  bool saving = false;
  String? error;
  @override
  void dispose() {
    name.dispose();
    amount.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (saving) return;
    FocusScope.of(context).unfocus();
    final target = parseAmount(amount.text);
    if (name.text.trim().isEmpty ||
        target == null ||
        day(deadline).isBefore(day(DateTime.now()))) {
      setState(
        () => error =
            'Enter a name, a positive amount, and a date from today onwards.',
      );
      return;
    }
    if (target < (widget.goal?.savedAmount ?? 0)) {
      setState(
        () => error = 'Target cannot be lower than the amount already saved.',
      );
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final vm = context.read<GoalsViewModel>();
    try {
      if (widget.goal == null) {
        await vm.addGoal(
          SavingsGoal(
            name: name.text.trim(),
            targetAmount: target,
            deadline: deadline,
            emoji: emoji,
            createdAt: DateTime.now(),
          ),
        );
      } else {
        await vm.updateGoal(
          widget.goal!.copyWith(
            name: name.text.trim(),
            targetAmount: target,
            deadline: deadline,
            emoji: emoji,
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          saving = false;
          error = 'Could not save your changes. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext c) => PageShell(
    title: widget.goal == null ? 'New goal' : 'Edit Goal',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t(c, 'Make it something worth saving for.'),
          style: TextStyle(color: muted(c), height: 1.4),
        ),
        const SizedBox(height: 22),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(c, 'Choose an emoji'),
                style: TextStyle(color: muted(c), fontSize: 13),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['🎯', '🌱', '🏡', '✈️', '📚', '🚗', '🎓', '🎁']
                    .map(
                      (value) => CupertinoButton(
                        padding: const EdgeInsets.all(9),
                        color: emoji == value ? lime : canvas(c),
                        borderRadius: BorderRadius.circular(14),
                        onPressed: () => setState(() => emoji = value),
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        EntryField('Goal name', name, maxLength: 80),
        EntryField('Target amount', amount, numeric: true),
        CupertinoListTile.notched(
          backgroundColor: panel(c),
          title: Text(t(c, 'Deadline')),
          subtitle: Text(dateLabel(deadline)),
          leading: const Icon(CupertinoIcons.calendar),
          trailing: const CupertinoListTileChevron(),
          onTap: () async {
            final selected = await chooseDate(c, deadline);
            if (selected != null && mounted) {
              setState(() => deadline = selected);
            }
          },
        ),
        const SizedBox(height: 16),
        Text(
          t(c, 'We’ll calculate a savings plan from your amount and deadline.'),
          style: TextStyle(color: muted(c), fontSize: 13, height: 1.4),
        ),
        if (error != null) ...[
          const SizedBox(height: 16),
          Text(
            t(c, error!),
            style: const TextStyle(color: CupertinoColors.systemRed),
          ),
        ],
        const SizedBox(height: 28),
        PrimaryButton('Save goal', onPressed: save, busy: saving),
      ],
    ),
  );
}

class TransactionEditor extends StatefulWidget {
  final int? goalId;
  final bool withdraw;
  const TransactionEditor({super.key, this.goalId, this.withdraw = false});
  @override
  State<TransactionEditor> createState() => _TransactionEditorState();
}

class _TransactionEditorState extends State<TransactionEditor> {
  final amount = TextEditingController();
  final note = TextEditingController();
  late int? goalId = widget.goalId;
  DateTime date = day(DateTime.now());
  bool saving = false;
  String? error;
  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (saving) return;
    FocusScope.of(context).unfocus();
    final vm = context.read<GoalsViewModel>();
    final goal = vm.getGoalById(goalId ?? -1);
    final value = parseAmount(amount.text);
    if (goal == null || value == null) {
      setState(() => error = 'Choose a goal and enter a positive amount.');
      return;
    }
    if (widget.withdraw && value > goal.savedAmount) {
      setState(() => error = 'Withdrawal cannot exceed the saved amount.');
      return;
    }
    final previous = SavingsPlan(goal).reachedMilestones;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      if (widget.withdraw) {
        await vm.addWithdrawal(
          goalId: goal.id!,
          amount: value,
          note: note.text.trim(),
          date: date,
        );
      } else {
        await vm.addDeposit(
          goalId: goal.id!,
          amount: value,
          note: note.text.trim(),
          date: date,
        );
      }
      final updated = vm.getGoalById(goal.id!);
      final reached = updated == null
          ? <int>[]
          : SavingsPlan(
              updated,
            ).reachedMilestones.where((p) => !previous.contains(p)).toList();
      if (!mounted) return;
      // Stop the spinner before awaiting a milestone dialog on top of the form.
      setState(() => saving = false);
      HapticFeedback.lightImpact();
      if (!widget.withdraw && reached.isNotEmpty) {
        await alert(
          context,
          t(context, 'A milestone worth celebrating'),
          '${goal.name} · ${reached.last}%\n${t(context, 'Every small step counts. Keep going!')}',
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          saving = false;
          error = 'Could not save your changes. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext c) {
    final vm = c.watch<GoalsViewModel>();
    final goal = vm.getGoalById(goalId ?? -1);
    return PageShell(
      title: widget.withdraw ? 'Withdraw' : 'Add savings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t(c, 'Record your savings. Your money stays with you.'),
            style: TextStyle(color: muted(c), height: 1.4),
          ),
          const SizedBox(height: 24),
          if (vm.goals.isEmpty)
            EmptyState(
              'Create a goal first',
              'A savings entry needs a goal.',
              onAdd: () => openPage(c, const GoalEditor()),
            )
          else ...[
            CupertinoListTile.notched(
              backgroundColor: panel(c),
              title: Text(goal?.name ?? t(c, 'Select savings goal')),
              leading: const Icon(CupertinoIcons.flag),
              trailing: const CupertinoListTileChevron(),
              onTap: () async {
                final choice = await showCupertinoModalPopup<int>(
                  context: c,
                  builder: (sheet) => CupertinoActionSheet(
                    title: Text(t(c, 'Select savings goal')),
                    actions: vm.goals
                        .map(
                          (g) => CupertinoActionSheetAction(
                            onPressed: () => Navigator.pop(sheet, g.id),
                            child: Text('${g.emoji} ${g.name}'),
                          ),
                        )
                        .toList(),
                    cancelButton: CupertinoActionSheetAction(
                      onPressed: () => Navigator.pop(sheet),
                      child: Text(t(c, 'Cancel')),
                    ),
                  ),
                );
                if (choice != null && mounted) setState(() => goalId = choice);
              },
            ),
            const SizedBox(height: 24),
            EntryField('Amount', amount, numeric: true),
            EntryField('Note (optional)', note, maxLength: 200),
            CupertinoListTile.notched(
              backgroundColor: panel(c),
              title: Text(t(c, 'Date')),
              subtitle: Text(dateLabel(date)),
              leading: const Icon(CupertinoIcons.calendar),
              trailing: const CupertinoListTileChevron(),
              onTap: () async {
                final selected = await chooseDate(c, date, pastOnly: true);
                if (selected != null && mounted) {
                  setState(() => date = selected);
                }
              },
            ),
            if (error != null) ...[
              const SizedBox(height: 16),
              Text(
                t(c, error!),
                style: const TextStyle(color: CupertinoColors.systemRed),
              ),
            ],
            const SizedBox(height: 28),
            PrimaryButton(
              widget.withdraw ? 'Confirm withdrawal' : 'Save deposit',
              onPressed: save,
              busy: saving,
            ),
          ],
        ],
      ),
    );
  }
}
