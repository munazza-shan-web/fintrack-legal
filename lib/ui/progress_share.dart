part of 'save_goals_app.dart';

class ProgressSharePage extends StatefulWidget {
  final SavingsGoal goal;
  const ProgressSharePage(this.goal, {super.key});
  @override
  State<ProgressSharePage> createState() => _ProgressSharePageState();
}

class _ProgressSharePageState extends State<ProgressSharePage> {
  final cardKey = GlobalKey();
  bool includeName = false;
  bool busy = false;
  Future<void> share() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          cardKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (!mounted) return;
      final box = context.findRenderObject()! as RenderBox;
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(bytes!.buffer.asUint8List(), mimeType: 'image/png'),
          ],
          fileNameOverrides: ['savings-goals-progress.png'],
          text:
              'Small steps. Real progress. Saving Goals · ${AppBrand.website}',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      if (mounted) {
        await alert(
          context,
          t(context, 'Error'),
          t(context, 'Could not open sharing. Please try again.'),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext c) => PageShell(
    title: 'Share your progress',
    child: Column(
      children: [
        Text(
          t(c, 'A little win worth sharing.'),
          style: TextStyle(color: muted(c)),
        ),
        const SizedBox(height: 20),
        RepaintBoundary(
          key: cardKey,
          child: AchievementCard(goal: widget.goal, includeName: includeName),
        ),
        const SizedBox(height: 20),
        CupertinoListTile.notched(
          title: Text(t(c, 'Include goal name')),
          trailing: CupertinoSwitch(
            value: includeName,
            onChanged: (v) => setState(() => includeName = v),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          t(
            c,
            'Amounts, dates and notes are never included. You choose where to share.',
          ),
          style: TextStyle(color: muted(c), fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 24),
        PrimaryButton('Share progress card', onPressed: share, busy: busy),
      ],
    ),
  );
}

class AchievementCard extends StatelessWidget {
  final SavingsGoal goal;
  final bool includeName;
  const AchievementCard({
    super.key,
    required this.goal,
    this.includeName = false,
  });
  @override
  Widget build(BuildContext c) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(26),
    decoration: BoxDecoration(
      color: lime,
      borderRadius: BorderRadius.circular(30),
    ),
    child: DefaultTextStyle(
      style: const TextStyle(fontFamily: 'Manrope', color: forest),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'SAVING GOALS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 25),
          Center(child: SavingsSprout(progress: goal.progress, animate: false)),
          const SizedBox(height: 20),
          Text(
            '${(goal.progress * 100).round()}%',
            style: const TextStyle(
              fontSize: 76,
              fontWeight: FontWeight.w900,
              letterSpacing: -4,
            ),
          ),
          Text(
            t(c, goal.isCompleted ? 'I made it happen.' : 'Closer every day.'),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          if (includeName) ...[
            const SizedBox(height: 14),
            Text(
              goal.name,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 28),
          const Text(
            'Small steps. Real progress.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'SavingsGoals.site',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}

/// Original code-drawn companion; growth follows real savings progress.
class SavingsSprout extends StatefulWidget {
  final double progress;
  final bool animate;
  const SavingsSprout({super.key, required this.progress, this.animate = true});
  @override
  State<SavingsSprout> createState() => _SavingsSproutState();
}

class _SavingsSproutState extends State<SavingsSprout> {
  int taps = 0;
  @override
  Widget build(BuildContext c) => Semantics(
    label: t(c, 'Your growing savings companion'),
    button: widget.animate,
    child: GestureDetector(
      onTap: widget.animate
          ? () {
              HapticFeedback.selectionClick();
              setState(() => taps++);
            }
          : null,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(taps),
        tween: Tween(begin: widget.animate ? .88 : 1.0, end: 1),
        duration: !widget.animate || MediaQuery.disableAnimationsOf(c)
            ? Duration.zero
            : const Duration(milliseconds: 850),
        curve: Curves.elasticOut,
        builder: (_, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: CustomPaint(
          size: const Size(130, 130),
          painter: _SproutPainter(widget.progress),
        ),
      ),
    ),
  );
}

class _SproutPainter extends CustomPainter {
  final double progress;
  _SproutPainter(this.progress);
  @override
  void paint(Canvas c, Size s) {
    final paint = Paint()..isAntiAlias = true;
    paint.color = lime;
    final growth = progress.clamp(0.0, 1.0);
    paint
      ..color = forest
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    c.drawLine(const Offset(65, 81), Offset(65, 47 - growth * 13), paint);
    paint
      ..style = PaintingStyle.fill
      ..color = lime;
    final left = Path()
      ..moveTo(65, 61)
      ..cubicTo(31, 65, 29, 38 - growth * 8, 34, 35 - growth * 8)
      ..cubicTo(56, 34, 66, 45, 65, 61);
    c.drawPath(left, paint);
    paint.color = lime;
    final right = Path()
      ..moveTo(65, 49)
      ..cubicTo(66, 23 - growth * 9, 90, 23 - growth * 9, 99, 26)
      ..cubicTo(99, 47, 80, 58, 65, 49);
    c.drawPath(right, paint);
    paint.color = const Color(0xFFE7B3FF);
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(35, 76, 60, 42),
        const Radius.circular(16),
      ),
      paint,
    );
    paint.color = forest;
    c.drawCircle(const Offset(53, 92), 3, paint);
    c.drawCircle(const Offset(77, 92), 3, paint);
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    c.drawArc(const Rect.fromLTWH(57, 94, 16, 12), .1, 2.9, false, paint);
  }

  @override
  bool shouldRepaint(_SproutPainter old) => old.progress != progress;
}

class MomentumHeader extends StatelessWidget {
  final SavingInsights insights;
  final double progress;
  const MomentumHeader({
    super.key,
    required this.insights,
    required this.progress,
  });
  @override
  Widget build(BuildContext c) {
    final week = insights.week;
    return Row(
      children: [
        SizedBox(
          width: 66,
          height: 76,
          child: FittedBox(child: SavingsSprout(progress: progress)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t(c, 'Grow at your pace.'), style: headline(c, 17)),
              const SizedBox(height: 5),
              Text(
                insights.streak == 0
                    ? t(c, 'Every small start counts.')
                    : '${insights.streak} ${t(c, 'day saving streak')}',
                style: TextStyle(color: muted(c), fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(
                  7,
                  (i) => Expanded(
                    child: Center(
                      child: Semantics(
                        label:
                            '${dateLabel(DateTime.now().subtract(Duration(days: 6 - i)))}: ${t(c, week[i] ? 'Deposit' : 'No deposit')}',
                        child: Container(
                          width: 17,
                          height: 17,
                          decoration: BoxDecoration(
                            color: week[i]
                                ? accent.resolveFrom(c)
                                : CupertinoColors.systemFill.resolveFrom(c),
                            shape: BoxShape.circle,
                            border: i == 6
                                ? Border.all(
                                    color: accent.resolveFrom(c),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: week[i]
                              ? Icon(
                                  CupertinoIcons.checkmark,
                                  color:
                                      CupertinoTheme.brightnessOf(c) ==
                                          Brightness.dark
                                      ? forest
                                      : const Color(0xFFFFFFFF),
                                  size: 10,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
