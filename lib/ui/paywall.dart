part of 'save_goals_app.dart';

/// Visual preview only. There is deliberately no billing or entitlement gate.
class PaywallPreview extends StatefulWidget {
  const PaywallPreview({super.key});
  @override
  State<PaywallPreview> createState() => _PaywallPreviewState();
}

class _PaywallPreviewState extends State<PaywallPreview> {
  bool yearly = true;
  bool uk = false;
  @override
  Widget build(BuildContext c) {
    final price = uk
        ? (yearly ? '£24.99' : '£3.49')
        : (yearly ? '\$29.99' : '\$3.99');
    final period = yearly ? 'year' : 'month';
    return CupertinoPageScaffold(
      backgroundColor: canvas(c),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Saving Goals', style: headline(c, 19)),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(c),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                  Text(
                    'DESIGN PREVIEW · NO PAYMENTS',
                    style: TextStyle(
                      color: muted(c),
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SavingsSegments<bool>(
                    groupValue: uk,
                    children: const {
                      false: Text('USA · USD'),
                      true: Text('UK · GBP'),
                    },
                    onValueChanged: (v) => setState(() => uk = v ?? false),
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(
                    height: 60,
                    width: 60,
                    child: FittedBox(child: SavingsSprout(progress: .5)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A little today.\nA better tomorrow.',
                    textAlign: TextAlign.center,
                    style: headline(c, 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your goals. A clearer plan.',
                    style: TextStyle(color: muted(c)),
                  ),
                  const SizedBox(height: 18),
                  for (final label in [
                    'Plan your savings',
                    'Track your progress',
                    'Celebrate your milestones',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.checkmark,
                            size: 18,
                            color: accent.resolveFrom(c),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Text(label)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  _plan(c, true, uk ? '£24.99' : '\$29.99'),
                  _plan(c, false, uk ? '£3.49' : '\$3.99'),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    'Start 7-day free trial',
                    onPressed: () => alert(
                      c,
                      'Preview only',
                      'Saving Goals is currently free. No trial or subscription has been started.',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sample: 7 days free, then $price/$period. Auto-renews unless cancelled. Cancel in store settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: muted(c),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Illustrative pricing. Trial for eligible new subscribers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted(c), fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      CupertinoButton(
                        onPressed: () => openLink(c, AppBrand.termsUrl),
                        child: const Text(
                          'Terms',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      CupertinoButton(
                        onPressed: () => openLink(c, AppBrand.privacyUrl),
                        child: const Text(
                          'Privacy',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      CupertinoButton(
                        onPressed: () => alert(
                          c,
                          'Nothing to restore',
                          'No purchases are offered in this free version.',
                        ),
                        child: const Text(
                          'Restore purchases',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _plan(BuildContext c, bool annual, String price) {
    final selected = yearly == annual;
    final period = annual ? 'year' : 'month';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        selected: selected,
        button: true,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => setState(() => yearly = annual),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected ? lime.withValues(alpha: .06) : panel(c),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? accent.resolveFrom(c)
                    : muted(c).withValues(alpha: .2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? CupertinoIcons.largecircle_fill_circle
                      : CupertinoIcons.circle,
                  size: 23,
                  color: selected ? accent.resolveFrom(c) : muted(c),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        annual ? 'Yearly' : 'Monthly',
                        style: headline(c, 17),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '7 days free, then $price/$period',
                        style: TextStyle(color: muted(c), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$price / $period',
                  style: TextStyle(
                    color: ink(c),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
