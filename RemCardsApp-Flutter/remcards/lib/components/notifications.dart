import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:remcards/pages/components/utils.dart';

Future<void> createTestNotification() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: createUniqueId(),
      channelKey: 'basic_channel',
      title:
          'REMCARDS: ${Emojis.activites_party_popper} This is a successful test notification.',
      body: 'I see you\'re seeing this, nice! ${Emojis.hand_thumbs_up}',
      notificationLayout: NotificationLayout.Default,
    ),
  );
}

Future<void> createScheduledNotification(
    int id, int weekday, int hour, int minute, String sbjname) async {
  List adTime = advancedTime(hour, minute, 5);
  String time = timeToString(hour, minute);
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: createUniqueId(),
      channelKey: 'scheduled_channel',
      title: '${sbjname} is starting now...',
      body: 'Scheduled at exactly ${time}',
      notificationLayout: NotificationLayout.Default,
    ),
    schedule: NotificationCalendar(
        weekday: weekday,
        hour: adTime[0],
        minute: adTime[1],
        second: 0,
        millisecond: 0,
        repeats: true),
  );
}

Future<void> createReminderNotification(
    String subject, String task, int month, int day, int year) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: createUniqueId(),
      channelKey: 'scheduled_channel',
      title: '${subject} - (${task})',
      body: 'is due today!',
      notificationLayout: NotificationLayout.Default,
    ),
    schedule: NotificationCalendar(
        month: month,
        day: day,
        year: year,
        hour: 7,
        minute: 0,
        second: 0,
        millisecond: 0),
  );
}

Future<void> cancelScheduledNotifications() async {
  await AwesomeNotifications().cancelAllSchedules();
  print("Schedules Cancelled");
}
