import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';

class AppSettings extends ChangeNotifier {
  static const String _currencyKey = 'currency_code';
  static const String _languageKey = 'language_code';
  static const String _themeKey = 'theme_mode';
  static const String _privacyKey = 'hide_balances';
  static const String _reminderKey = 'reminders_enabled';
  static const String _reminderHourKey = 'reminder_hour';
  static const String _reminderMinuteKey = 'reminder_minute';

  String _currencyCode = 'PKR';
  String _languageCode = 'en';
  ThemeMode _themeMode = ThemeMode.light;
  bool _hideBalances = false;
  bool _remindersEnabled = false;
  int _reminderHour = 20;
  int _reminderMinute = 0;

  String get currencyCode => _currencyCode;
  String get languageCode => _languageCode;
  ThemeMode get themeMode => _themeMode;
  bool get hideBalances => _hideBalances;
  bool get remindersEnabled => _remindersEnabled;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;

  String get currencySymbol {
    switch (_currencyCode) {
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      default:
        return 'Rs.';
    }
  }

  String get reminderTimeLabel {
    final hour = _reminderHour.toString().padLeft(2, '0');
    final minute = _reminderMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _currencyCode = prefs.getString(_currencyKey) ?? 'PKR';
    _languageCode = prefs.getString(_languageKey) ?? 'en';

    final savedTheme = prefs.getString(_themeKey) ?? 'light';
    _themeMode = savedTheme == 'light' ? ThemeMode.light : ThemeMode.dark;

    _hideBalances = prefs.getBool(_privacyKey) ?? false;
    _remindersEnabled = prefs.getBool(_reminderKey) ?? false;
    _reminderHour = prefs.getInt(_reminderHourKey) ?? 20;
    _reminderMinute = prefs.getInt(_reminderMinuteKey) ?? 0;

    notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    if (!['PKR', 'USD', 'GBP', 'EUR'].contains(code)) return;

    _currencyCode = code;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, code);
  }

  Future<void> setLanguage(String code) async {
    if (!['en', 'ur'].contains(code)) return;

    _languageCode = code;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);

    if (_remindersEnabled) {
      await _scheduleReminder();
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeKey,
      mode == ThemeMode.light ? 'light' : 'dark',
    );
  }

  Future<void> setHideBalances(bool value) async {
    _hideBalances = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_privacyKey, value);
  }

  Future<void> setRemindersEnabled(bool value) async {
    if (value == _remindersEnabled) return;

    final prefs = await SharedPreferences.getInstance();

    if (value) {
      try {
        await _scheduleReminder();

        _remindersEnabled = true;
        await prefs.setBool(_reminderKey, true);
      } catch (error) {
        _remindersEnabled = false;
        await prefs.setBool(_reminderKey, false);
        notifyListeners();
        rethrow;
      }
    } else {
      await NotificationService.instance.cancelDailyReminder();

      _remindersEnabled = false;
      await prefs.setBool(_reminderKey, false);
    }

    notifyListeners();
  }

  Future<void> setReminderTime(int hour, int minute) async {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return;
    }

    final oldHour = _reminderHour;
    final oldMinute = _reminderMinute;

    _reminderHour = hour;
    _reminderMinute = minute;

    try {
      if (_remindersEnabled) {
        await _scheduleReminder();
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_reminderHourKey, hour);
      await prefs.setInt(_reminderMinuteKey, minute);

      notifyListeners();
    } catch (error) {
      _reminderHour = oldHour;
      _reminderMinute = oldMinute;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _scheduleReminder() async {
    await NotificationService.instance.scheduleDailyReminder(
      hour: _reminderHour,
      minute: _reminderMinute,
      languageCode: _languageCode,
    );
  }

  String formatMoney(double amount) {
    if (_hideBalances) return '••••••';

    return '$currencySymbol ${amount.toStringAsFixed(2)}';
  }
}
