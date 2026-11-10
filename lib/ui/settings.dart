part of 'save_goals_app.dart';

Future<String?> chooseOption(
  BuildContext c,
  String title,
  Map<String, String> options,
) => showCupertinoModalPopup<String>(
  context: c,
  builder: (sheet) => CupertinoActionSheet(
    title: Text(t(c, title)),
    actions: options.entries
        .map(
          (entry) => CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(sheet, entry.key),
            child: Text(t(c, entry.value)),
          ),
        )
        .toList(),
    cancelButton: CupertinoActionSheetAction(
      onPressed: () => Navigator.pop(sheet),
      child: Text(t(c, 'Cancel')),
    ),
  ),
);
Future<void> openLink(BuildContext c, String url) async {
  try {
    if (!await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        ) &&
        c.mounted) {
      await alert(
        c,
        t(c, 'Error'),
        t(c, 'Could not open this link. Please try again.'),
      );
    }
  } catch (_) {
    if (c.mounted) {
      await alert(
        c,
        t(c, 'Error'),
        t(c, 'Could not open this link. Please try again.'),
      );
    }
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext c) {
    final settings = c.watch<AppSettings>();
    return PageShell(
      title: 'Settings',
      rootTab: true,
      child: Column(
        children: [
          SettingsGroup(
            children: [
              SettingsRow(
                'Currency',
                CupertinoIcons.money_dollar_circle,
                value: settings.currencyCode,
                onTap: () async {
                  final value = await chooseOption(c, 'Currency', {
                    'USD': 'US Dollar',
                    'GBP': 'British Pound',
                    'EUR': 'Euro',
                    'PKR': 'Pakistani Rupee',
                  });
                  if (value != null) await settings.setCurrency(value);
                },
              ),
              SettingsRow(
                'Language',
                CupertinoIcons.globe,
                value: settings.languageCode == 'ur' ? 'اردو' : 'English',
                onTap: () async {
                  final value = await chooseOption(c, 'Language', {
                    'en': 'English',
                    'ur': 'اردو',
                  });
                  if (value != null) {
                    try {
                      await settings.setLanguage(value);
                    } catch (_) {
                      if (c.mounted) {
                        await alert(
                          c,
                          t(c, 'Error'),
                          t(c, 'Could not update reminders. Please try again.'),
                        );
                      }
                    }
                  }
                },
              ),
              SettingsRow(
                'Appearance',
                CupertinoIcons.moon,
                value: t(c, settings.appearanceLabel),
                onTap: () async {
                  final value = await chooseOption(c, 'Appearance', {
                    'light': 'Light',
                    'dark': 'Dark',
                    'black': 'Black',
                  });
                  if (value != null) {
                    await settings.setAppearance(value);
                  }
                },
              ),
              SettingsRow(
                'Hide balances',
                CupertinoIcons.eye_slash,
                control: CupertinoSwitch(
                  value: settings.hideBalances,
                  onChanged: settings.setHideBalances,
                ),
              ),
              SettingsRow(
                'Daily reminder',
                CupertinoIcons.bell,
                control: CupertinoSwitch(
                  value: settings.remindersEnabled,
                  onChanged: (value) async {
                    try {
                      await settings.setRemindersEnabled(value);
                    } catch (_) {
                      if (c.mounted) {
                        await alert(
                          c,
                          t(c, 'Reminders unavailable'),
                          t(
                            c,
                            'Allow notifications in device settings, then try again.',
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              SettingsRow(
                'Reminder time',
                CupertinoIcons.clock,
                value: settings.reminderTimeLabel,
                onTap: () => _reminderTime(c, settings),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SettingsGroup(
            children: [
              SettingsRow(
                'Privacy Policy',
                CupertinoIcons.doc_text,
                onTap: () => openLink(c, AppBrand.privacyUrl),
              ),
              SettingsRow(
                'Terms & Conditions',
                CupertinoIcons.doc_text,
                onTap: () => openLink(c, AppBrand.termsUrl),
              ),
              SettingsRow(
                'Contact support',
                CupertinoIcons.headphones,
                onTap: () => openLink(c, 'mailto:${AppBrand.supportEmail}'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark(c)
                  ? const Color(0xFF2B3A24)
                  : const Color(0xFFE2EDCF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 56,
                  height: 56,
                  child: FittedBox(child: SavingsSprout(progress: .6)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t(c, '100% free. Every goal. Every feature.'),
                        style: headline(c, 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppBrand.organization,
                        style: TextStyle(
                          color: muted(c),
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SettingsGroup(
            children: [
              SettingsRow(
                'Preview trial screen',
                CupertinoIcons.rectangle,
                onTap: () => openPage(c, const PaywallPreview()),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Design preview only. The app is free; no payments or subscriptions.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted(c), fontSize: 11),
          ),
          const SizedBox(height: 10),
          Text(
            t(c, 'Your data stays on your device'),
            style: TextStyle(color: muted(c), fontSize: 11),
          ),
          Text(
            t(c, 'Currency changes labels, not amounts.'),
            style: TextStyle(color: muted(c), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Future<void> _reminderTime(BuildContext c, AppSettings settings) async {
    var selected = Duration(
      hours: settings.reminderHour,
      minutes: settings.reminderMinute,
    );
    final result = await showCupertinoModalPopup<Duration>(
      context: c,
      builder: (sheet) => Container(
        height: 330 + MediaQuery.paddingOf(sheet).bottom,
        color: panel(c),
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
                    onPressed: () => Navigator.pop(sheet, selected),
                    child: Text(t(c, 'Done')),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: selected,
                  onTimerDurationChanged: (value) => selected = value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (result != null) {
      try {
        await settings.setReminderTime(result.inHours, result.inMinutes % 60);
      } catch (_) {
        if (c.mounted) {
          await alert(
            c,
            t(c, 'Error'),
            t(c, 'Could not update reminders. Please try again.'),
          );
        }
      }
    }
  }
}
