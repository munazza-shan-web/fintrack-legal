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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppHeader(),
          const SizedBox(height: 20),
          CupertinoListSection.insetGrouped(
            margin: EdgeInsets.zero,
            header: Text(t(c, 'Make it yours')),
            children: [
              CupertinoListTile.notched(
                title: Text(t(c, 'Currency')),
                leading: const Icon(CupertinoIcons.money_dollar_circle),
                additionalInfo: Text(settings.currencyCode),
                trailing: const CupertinoListTileChevron(),
                onTap: () async {
                  final value = await chooseOption(c, 'Currency', {
                    'PKR': 'Pakistani Rupee',
                    'USD': 'US Dollar',
                    'GBP': 'British Pound',
                    'EUR': 'Euro',
                  });
                  if (value != null) await settings.setCurrency(value);
                },
              ),
              CupertinoListTile.notched(
                title: Text(t(c, 'Language')),
                leading: const Icon(CupertinoIcons.globe),
                additionalInfo: Text(
                  settings.languageCode == 'ur' ? 'اردو' : 'English',
                ),
                trailing: const CupertinoListTileChevron(),
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
              CupertinoListTile.notched(
                title: Text(t(c, 'Appearance')),
                leading: const Icon(CupertinoIcons.circle_lefthalf_fill),
                additionalInfo: Text(
                  t(c, settings.themeMode == ThemeMode.dark ? 'Dark' : 'Light'),
                ),
                trailing: const CupertinoListTileChevron(),
                onTap: () async {
                  final value = await chooseOption(c, 'Appearance', {
                    'light': 'Light',
                    'dark': 'Dark',
                  });
                  if (value != null) {
                    await settings.setTheme(
                      value == 'dark' ? ThemeMode.dark : ThemeMode.light,
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          CupertinoListSection.insetGrouped(
            margin: EdgeInsets.zero,
            header: Text(t(c, 'Your privacy & routine')),
            children: [
              CupertinoListTile.notched(
                title: Text(t(c, 'Hide balances')),
                leading: const Icon(CupertinoIcons.eye_slash),
                trailing: CupertinoSwitch(
                  value: settings.hideBalances,
                  onChanged: settings.setHideBalances,
                ),
              ),
              CupertinoListTile.notched(
                title: Text(t(c, 'Daily reminder')),
                leading: const Icon(CupertinoIcons.bell),
                trailing: CupertinoSwitch(
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
              if (settings.remindersEnabled)
                CupertinoListTile.notched(
                  title: Text(t(c, 'Reminder time')),
                  additionalInfo: Text(settings.reminderTimeLabel),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _reminderTime(c, settings),
                ),
            ],
          ),
          const SizedBox(height: 24),
          CupertinoListSection.insetGrouped(
            margin: EdgeInsets.zero,
            header: Text(t(c, 'About Savings Goals')),
            children: [
              CupertinoListTile.notched(
                title: Text(t(c, 'Privacy Policy')),
                leading: const Icon(CupertinoIcons.hand_raised),
                trailing: const CupertinoListTileChevron(),
                onTap: () => openLink(c, AppBrand.privacyUrl),
              ),
              CupertinoListTile.notched(
                title: Text(t(c, 'Terms & Conditions')),
                leading: const Icon(CupertinoIcons.doc_text),
                trailing: const CupertinoListTileChevron(),
                onTap: () => openLink(c, AppBrand.termsUrl),
              ),
              CupertinoListTile.notched(
                title: Text(t(c, 'Contact support')),
                leading: const Icon(CupertinoIcons.envelope),
                trailing: const CupertinoListTileChevron(),
                onTap: () => openLink(c, 'mailto:jiyoo7480@gmail.com'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(c, '100% free. Every goal. Every feature.'),
                  style: headline(c, 18),
                ),
                const SizedBox(height: 10),
                Text(
                  AppBrand.organization,
                  style: TextStyle(color: muted(c), fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  t(c, 'Your data stays on your device'),
                  style: TextStyle(color: muted(c), fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  t(c, 'Currency changes labels, not amounts.'),
                  style: TextStyle(color: muted(c), fontSize: 12),
                ),
              ],
            ),
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
