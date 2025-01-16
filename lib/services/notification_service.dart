import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart' show debugPrint;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._();

  Future<void> initialize() async {
    try {
      tz.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final granted = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap
        },
      );

      if (granted != null) {
        debugPrint('Notification permissions granted');
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'school_management_channel',
          'School Management',
          channelDescription: 'School Management App Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'school_management_channel',
          'School Management',
          channelDescription: 'School Management App Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Helper methods for specific notifications
  Future<void> scheduleExamNotification(
      String examTitle, DateTime examDate) async {
    // Schedule notification 1 day before
    final oneDayBefore = examDate.subtract(const Duration(days: 1));
    await scheduleNotification(
      id: examDate.millisecondsSinceEpoch ~/ 1000,
      title: 'Upcoming Exam Tomorrow',
      body: 'You have $examTitle tomorrow. Good luck!',
      scheduledDate: oneDayBefore,
    );

    // Schedule notification 1 hour before
    final oneHourBefore = examDate.subtract(const Duration(hours: 1));
    await scheduleNotification(
      id: (examDate.millisecondsSinceEpoch ~/ 1000) + 1,
      title: 'Exam in 1 Hour',
      body: '$examTitle starts in 1 hour. Be prepared!',
      scheduledDate: oneHourBefore,
    );
  }

  Future<void> scheduleAssignmentNotification(
    String assignmentTitle,
    DateTime dueDate,
  ) async {
    // Schedule notification 1 day before
    final oneDayBefore = dueDate.subtract(const Duration(days: 1));
    await scheduleNotification(
      id: dueDate.millisecondsSinceEpoch ~/ 1000,
      title: 'Assignment Due Tomorrow',
      body: '$assignmentTitle is due tomorrow. Don\'t forget to submit!',
      scheduledDate: oneDayBefore,
    );

    // Schedule notification 3 hours before
    final threeHoursBefore = dueDate.subtract(const Duration(hours: 3));
    await scheduleNotification(
      id: (dueDate.millisecondsSinceEpoch ~/ 1000) + 1,
      title: 'Assignment Due Soon',
      body: '$assignmentTitle is due in 3 hours. Submit now!',
      scheduledDate: threeHoursBefore,
    );
  }

  Future<void> scheduleFeeNotification(
    String description,
    DateTime dueDate,
    double amount,
  ) async {
    // Schedule notification 3 days before
    final threeDaysBefore = dueDate.subtract(const Duration(days: 3));
    await scheduleNotification(
      id: dueDate.millisecondsSinceEpoch ~/ 1000,
      title: 'Fee Payment Reminder',
      body: 'Payment of ₹$amount for $description is due in 3 days.',
      scheduledDate: threeDaysBefore,
    );

    // Schedule notification 1 day before
    final oneDayBefore = dueDate.subtract(const Duration(days: 1));
    await scheduleNotification(
      id: (dueDate.millisecondsSinceEpoch ~/ 1000) + 1,
      title: 'Fee Payment Due Tomorrow',
      body:
          'Last reminder: Payment of ₹$amount for $description is due tomorrow.',
      scheduledDate: oneDayBefore,
    );
  }
}
