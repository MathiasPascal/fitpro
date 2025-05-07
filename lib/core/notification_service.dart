// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest_all.dart' as tzData;

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> initialize() async {
//     tzData.initializeTimeZones();

//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     final InitializationSettings initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _notificationsPlugin.initialize(initSettings);

//     // Android 13+ runtime permission
//     await _notificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.requestPermission();
//   }

//   static Future<void> scheduleAppointmentNotification(DateTime appointmentTime) async {
//     final DateTime notificationTime = appointmentTime.subtract(const Duration(hours: 1));
//     final tz.TZDateTime tzTime = tz.TZDateTime.from(notificationTime, tz.local);

//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//           'appointment_channel',
//           'Appointment Notifications',
//           channelDescription: 'Notifications for upcoming appointments',
//           importance: Importance.high,
//           priority: Priority.high,
//         );

//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: DarwinNotificationDetails(),
//     );

//     await _notificationsPlugin.zonedSchedule(
//       0,
//       'Upcoming Appointment',
//       'You have an appointment in 1 hour.',
//       tzTime,
//       notificationDetails,
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }
// }
