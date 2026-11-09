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
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != 'Amount')
          Text(
            t(c, label),
            style: TextStyle(
              color: muted(c),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (label != 'Amount') const SizedBox(height: 9),
        CupertinoTextField(
          key: ValueKey('entry-$label'),
          controller: controller,
          inputFormatters: numeric ? const [AmountInputFormatter()] : null,
          placeholder: label == 'Amount' ? '0' : t(c, label),
          prefix: label == 'Amount'
              ? Padding(
                  padding: const EdgeInsetsDirectional.only(start: 14),
                  child: Text(
                    c.watch<AppSettings>().currencySymbol,
                    style: headline(c, 30),
                  ),
                )
              : null,
          maxLength: maxLength,
          keyboardType: label == 'Amount'
              ? TextInputType.none
              : numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          textInputAction: TextInputAction.next,
          padding: const EdgeInsets.all(12),
          style: TextStyle(
            color: ink(c),
            fontSize: label == 'Amount' ? 30 : 16,
            fontWeight: numeric ? FontWeight.w700 : FontWeight.w400,
          ),
          decoration: BoxDecoration(
            color: canvas(c),
            border: Border.all(color: ink(c).withValues(alpha: .7)),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        if (numeric)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (c, value, _) {
              final words = amountInWords(value.text);
              return words.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          words,
                          key: ValueKey('amount-words-$label'),
                          style: TextStyle(
                            color: accent.resolveFrom(c),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
            },
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
    text: widget.goal == null
        ? null
        : groupAmount(widget.goal!.targetAmount.toStringAsFixed(2)),
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

  Future<void> delete() async {
    final goal = widget.goal;
    if (saving || goal?.id == null) return;
    FocusScope.of(context).unfocus();
    if (!await confirm(
      context,
      t(context, 'Delete Goal?'),
      t(context, 'This also deletes its transactions. This cannot be undone.'),
    )) {
      return;
    }
    if (!mounted) return;
    setState(() => saving = true);
    try {
      await context.read<GoalsViewModel>().deleteGoal(goal!.id!);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => saving = false);
      await alert(
        context,
        t(context, 'Error'),
        t(context, 'Could not save your changes. Please try again.'),
      );
    }
  }

  @override
  Widget build(BuildContext c) => PageShell(
    title: widget.goal == null ? 'New goal' : 'Edit Goal',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t(c, 'Make room for something that matters.'),
          style: TextStyle(color: muted(c), height: 1.4),
        ),
        const SizedBox(height: 22),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisExtent: 90,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: goalCategories.entries.map((entry) {
            final selected = emoji == entry.key;
            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => setState(() {
                if (name.text.isEmpty ||
                    goalCategories.values.any((v) => v.$1 == name.text)) {
                  name.text = entry.value.$1;
                }
                emoji = entry.key;
              }),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selected ? lilac : panel(c),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? lilac : muted(c).withValues(alpha: .2),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      entry.value.$2,
                      size: 26,
                      color: selected ? forest : ink(c),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t(c, entry.value.$1),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        color: selected ? forest : ink(c),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
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
        if (widget.goal != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              onPressed: saving ? null : delete,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.trash,
                    color: CupertinoColors.systemRed,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t(c, 'Delete Goal'),
                    style: const TextStyle(
                      color: CupertinoColors.systemRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        final share = await showCupertinoDialog<bool>(
          context: context,
          builder: (_) => MilestoneDialog(updated!, reached.last),
        );
        if (!mounted) return;
        if (share == true) {
          final navigator = Navigator.of(context, rootNavigator: true);
          navigator.pop();
          navigator.push(
            CupertinoPageRoute<void>(
              builder: (_) => ProgressSharePage(updated!),
            ),
          );
          return;
        }
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
            const SizedBox(height: 16),
            EntryField('Amount', amount, numeric: true),
            if (goal != null) ...[
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: amount,
                builder: (c, value, _) {
                  final entered = parseAmount(value.text) ?? 0;
                  final next =
                      goal.savedAmount + (widget.withdraw ? -entered : entered);
                  return Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${t(c, 'Currently saved')}: ${money(c, goal.savedAmount)}',
                          style: TextStyle(color: muted(c), fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${t(c, 'After this entry')}: ${money(c, next)}',
                          style: headline(c, 22),
                        ),
                        const SizedBox(height: 12),
                        ProgressTrack(next / goal.targetAmount),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
            SettingsGroup(
              children: [
                SettingsRow(
                  'Note (optional)',
                  CupertinoIcons.doc_text,
                  value: note.text.isEmpty
                      ? null
                      : note.text.length > 16
                      ? '${note.text.substring(0, 16)}…'
                      : note.text,
                  onTap: () async {
                    await showCupertinoDialog<void>(
                      context: c,
                      builder: (dialog) => CupertinoAlertDialog(
                        title: Text(t(c, 'Note (optional)')),
                        content: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: CupertinoTextField(
                            controller: note,
                            maxLength: 200,
                            autofocus: true,
                            placeholder: t(c, 'Note (optional)'),
                          ),
                        ),
                        actions: [
                          CupertinoDialogAction(
                            onPressed: () => Navigator.pop(dialog),
                            child: Text(t(c, 'Done')),
                          ),
                        ],
                      ),
                    );
                    if (mounted) setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 12),
            AmountKeypad(amount),
            const SizedBox(height: 16),
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
