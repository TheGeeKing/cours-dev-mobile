import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:timezone/timezone.dart';

export 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
export 'package:timezone/timezone.dart';

class WindowsInitializationSettings {
  const WindowsInitializationSettings({
    this.appName,
    this.appUserModelId,
    this.guid,
  });

  final String? appName;
  final String? appUserModelId;
  final String? guid;
}

class WindowsNotificationDetails {
  const WindowsNotificationDetails();
}

class WindowsProgressBar {
  const WindowsProgressBar();

  Map<String, String> get data => const {};
}

enum NotificationUpdateResult { success, error, notFound }

class FlutterLocalNotificationsWindows extends FlutterLocalNotificationsPlatform {
  Future<bool> initialize({
    required WindowsInitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {
    return true;
  }

  void dispose() {}

  Future<void> showRawXml({
    required int id,
    required String xml,
    Map<String, String> bindings = const <String, String>{},
  }) async {}

  Future<void> show({
    required int id,
    String? title,
    String? body,
    String? payload,
    WindowsNotificationDetails? notificationDetails,
  }) async {}

  Future<void> zonedSchedule({
    required int id,
    String? title,
    String? body,
    required TZDateTime scheduledDate,
    WindowsNotificationDetails? notificationDetails,
    String? payload,
  }) async {}

  Future<void> zonedScheduleRawXml({
    required int id,
    required String xml,
    required TZDateTime scheduledDate,
  }) async {}

  Future<NotificationUpdateResult> updateProgressBar({
    required int notificationId,
    required WindowsProgressBar progressBar,
  }) {
    return updateBindings(id: notificationId, bindings: progressBar.data);
  }

  Future<NotificationUpdateResult> updateBindings({
    required int id,
    required Map<String, String> bindings,
  }) async {
    return NotificationUpdateResult.success;
  }

  bool isValidXml(String xml) => true;

  @override
  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() async {
    return const NotificationAppLaunchDetails(false);
  }

  @override
  Future<void> cancel({required int id}) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> cancelAllPendingNotifications() async {}

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    return const [];
  }

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async {
    return const [];
  }
}
