import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:todos/models/todo.dart';

class TodoReminderNotificationService {
  TodoReminderNotificationService._();

  static final instance = TodoReminderNotificationService._();

  static const _channelId = 'todo_reminders';
  static const _channelName = 'Rappels de taches';
  static const _channelDescription = 'Notifications de rappel pour les taches';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    if (!_notificationsSupported) {
      _initialized = true;
      return;
    }

    tzdata.initializeTimeZones();
    await _setLocalTimezone();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );

    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    if (!_notificationsSupported) return false;
    await initialize();

    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    final macosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return androidGranted != false &&
        iosGranted != false &&
        macosGranted != false;
  }

  Future<bool> scheduleForTodo(Todo todo) async {
    if (!_notificationsSupported) return false;
    final reminderAt = todo.reminderAt;
    if (reminderAt == null || todo.completed) {
      await cancelForTodo(todo);
      return true;
    }

    final scheduledAt = reminderAt.toLocal();
    if (!scheduledAt.isAfter(DateTime.now())) return false;

    final granted = await requestPermissions();
    if (!granted) return false;

    await cancelForTodo(todo);
    await _plugin.zonedSchedule(
      id: _notificationId(todo),
      title: 'Rappel : ${todo.title}',
      body: 'Cette tache est prevue maintenant.',
      scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: todo.id,
    );
    return true;
  }

  Future<void> cancelForTodo(Todo todo) async {
    if (!_notificationsSupported) return;
    await initialize();
    await _plugin.cancel(id: _notificationId(todo));
  }

  bool get _notificationsSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  Future<void> _setLocalTimezone() async {
    try {
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  int _notificationId(Todo todo) {
    final source = todo.id ?? todo.title;
    var hash = 0x811c9dc5;
    for (final codeUnit in source.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }
}
