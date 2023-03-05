import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:reminder/core/models/medication.dart';

class NotificationController {
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'alerts',
          channelName: 'Alerts',
          channelDescription: 'Notification tests as alerts',
          playSound: true,
          onlyAlertOnce: true,
          groupAlertBehavior: GroupAlertBehavior.Children,
          importance: NotificationImportance.High,
          defaultPrivacy: NotificationPrivacy.Private,
          defaultColor: Colors.deepPurple,
          ledColor: Colors.deepPurple,
        ),
      ],
      debug: true,
    );
  }

  static Future<void> scheduleNotification(
    BuildContext context,
    Medication medication,
  ) async {
    final time = medication.time.format(context);
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed =
          await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: medication.id, // -1 is replaced by a random number
        channelKey: 'alerts',
        title: 'Medication Reminder',
        body: 'Reminder to take your ${medication.name} at $time',
      ),
      actionButtons: [
        NotificationActionButton(key: 'OPEN', label: 'Open'),
        NotificationActionButton(
          key: 'DISMISS',
          label: 'Dismiss',
          actionType: ActionType.DismissAction,
          isDangerousOption: true,
        )
      ],
      schedule: NotificationCalendar(
        hour: medication.time.hour,
        minute: medication.time.minute,
        second: 0,
        repeats: true,
      ),
    );
  }

  static Future<void> cancelNotification(int index) async {
    await AwesomeNotifications().cancelSchedule(index);
  }
}
