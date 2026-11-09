part of 'save_goals_app.dart';

class FloatingNavigation extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelected;
  const FloatingNavigation({
    super.key,
    required this.index,
    required this.onSelected,
  });
  static const labels = ['Home', 'Goals', 'Activity', 'Settings'];
  static const icons = [
    CupertinoIcons.house,
    CupertinoIcons.flag,
    CupertinoIcons.chart_bar,
    CupertinoIcons.settings,
  ];
  @override
  Widget build(BuildContext c) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: isDark(c) ? .3 : .1),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          key: const ValueKey('floating-navigation'),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: panel(c).withValues(alpha: .52),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: ink(c).withValues(alpha: .13)),
          ),
          child: Row(
            children: List.generate(
              4,
              (i) => Expanded(
                flex: index == i ? 16 : 10,
                child: Semantics(
                  label: t(c, labels[i]),
                  onTap: () => onSelected(i),
                  selected: index == i,
                  button: true,
                  excludeSemantics: true,
                  child: CupertinoButton(
                    key: ValueKey('tab-$i'),
                    padding: EdgeInsets.zero,
                    onPressed: () => onSelected(i),
                    child: AnimatedContainer(
                      duration: MediaQuery.disableAnimationsOf(c)
                          ? Duration.zero
                          : const Duration(milliseconds: 180),
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: index == i ? lime : const Color(0x00000000),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icons[i],
                            size: 23,
                            color: index == i ? forest : muted(c),
                          ),
                          if (index == i) ...[
                            const SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                t(c, labels[i]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: forest,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Displays the launch screen only while the real local startup work runs.
class StartupGate extends StatefulWidget {
  const StartupGate({super.key});
  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  bool ready = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    final settings = context.read<AppSettings>();
    final goals = context.read<GoalsViewModel>();
    // Reminder setup must not hold the splash screen open.
    unawaited(_initializeReminders());
    await Future.wait([
      settings.loadSettings().catchError((Object _) {}),
      goals.loadData(),
    ]);
    if (mounted) setState(() => ready = true);
  }

  Future<void> _initializeReminders() async {
    try {
      await NotificationService.instance.initialize();
    } catch (_) {
      /* Optional on unsupported platforms. */
    }
  }

  @override
  Widget build(BuildContext c) =>
      ready ? const MainScreen() : const LaunchScreen();
}

class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});
  @override
  Widget build(BuildContext c) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: const SystemUiOverlayStyle(
      statusBarColor: Color(0x00000000),
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Color(0x00000000),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
    child: CupertinoPageScaffold(
      backgroundColor: lime,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (c, size) => Stack(
            children: [
              Align(
                alignment: const Alignment(0, -.12),
                child: Image.asset(
                  'assets/branding/sprout_lockup.png',
                  width: math.min(size.maxWidth * .74, 300),
                  semanticLabel: AppBrand.name,
                ),
              ),
              Positioned(
                top: size.maxHeight * .77,
                left: 0,
                right: 0,
                child: const Center(child: LaunchDots()),
              ),
              Positioned(
                bottom: 36,
                left: 24,
                right: 24,
                child: Text(
                  'Small steps. Real progress.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: forest,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class LaunchDots extends StatefulWidget {
  const LaunchDots({super.key});
  @override
  State<LaunchDots> createState() => _LaunchDotsState();
}

class _LaunchDotsState extends State<LaunchDots>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.stop();
    } else {
      controller.repeat();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Semantics(
    label: 'Loading your goals',
    liveRegion: true,
    child: AnimatedBuilder(
      animation: controller,
      builder: (c, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Opacity(
              opacity:
                  .25 +
                  .75 *
                      ((math.cos((controller.value - i / 3) * math.pi * 2) +
                              1) /
                          2),
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: forest,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
