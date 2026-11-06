import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int _reminderId = 1001;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // Permissions are requested later, only when the user turns
      // reminders on, so all three are false here.
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _notifications.initialize(settings: initializationSettings);

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await initialize();

    final ios = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: false,
            sound: true,
          ) ??
          false;
    }

    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android != null) {
      return await android.requestNotificationsPermission() ?? true;
    }

    return false;
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String languageCode,
  }) async {
    await initialize();

    final permissionGranted = await requestPermission();

    if (!permissionGranted) {
      throw Exception('Notification permission was not granted.');
    }

    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final isUrdu = languageCode == 'ur';

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'fintrack_daily_reminders',
        'Savings Reminders',
        channelDescription: 'Daily reminders to save money',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );

    await _notifications.zonedSchedule(
      id: _reminderId,
      title: isUrdu ? 'بچت کی یاد دہانی' : 'Savings Goals Reminder',
      body: isUrdu
          ? 'آج اپنی بچت کے ہدف میں رقم جمع کرنا نہ بھولیں!'
          : 'Remember to contribute towards your savings goal today!',
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() async {
    await initialize();
    await _notifications.cancel(id: _reminderId);
  }
}
