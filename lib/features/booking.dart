// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// class BookingPage extends StatefulWidget {
//   const BookingPage({Key? key}) : super(key: key);

//   @override
//   State<BookingPage> createState() => _BookingPageState();
// }

// class _BookingPageState extends State<BookingPage> {
//   DateTime? selectedDate;
//   TimeOfDay? selectedTime;

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   @override
//   void initState() {
//     super.initState();
//     tz.initializeTimeZones();
//     // Set local location to prevent timezone issues
//     tz.setLocalLocation(tz.getLocation('UTC'));
//     _initializeNotifications();
//     _setupFirebaseMessaging();
//   }

//   Future<void> _initializeNotifications() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         // Handle notification tap
//         debugPrint('Notification tapped: ${response.payload}');
//       },
//     );

//     // Request permission for Android 13+
//     await _requestPermissions();

//     // Create notification channel for Android
//     await _createNotificationChannel();
//   }

//   Future<void> _requestPermissions() async {
//     // For Android 13 and above
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.requestPermissions(alert: true, badge: true, sound: true);
//   }

//   Future<void> _createNotificationChannel() async {
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'booking_channel_id', // id
//       'Booking Notifications', // name
//       description: 'Notification for upcoming appointments', // description
//       importance: Importance.high,
//     );

//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.createNotificationChannel(channel);
//   }

//   Future<void> _setupFirebaseMessaging() async {
//     // Get FCM token for this device
//     String? token = await FirebaseMessaging.instance.getToken();
//     debugPrint('FCM Token: $token');

//     // Save this token to your Firebase database for the current user
//     // This would typically be: saveTokenToDatabase(token);

//     // Define the background message handler
//     Future<void> _firebaseMessagingBackgroundHandler(
//       RemoteMessage message,
//     ) async {
//       debugPrint('Handling a background message: ${message.messageId}');
//     }

//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       debugPrint('Got a message whilst in the foreground!');
//       debugPrint('Message data: ${message.data}');

//       if (message.notification != null) {
//         debugPrint(
//           'Message also contained a notification: ${message.notification}',
//         );

//         // Show the notification using flutter_local_notifications
//         _showNotificationFromFirebase(message);
//       }
//     });

//     // Handle background/terminated messages
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//     // Request permission for FCM
//     await FirebaseMessaging.instance.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//   }

//   void _showNotificationFromFirebase(RemoteMessage message) async {
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;

//     if (notification != null && android != null) {
//       await flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             'booking_channel_id',
//             'Booking Notifications',
//             channelDescription: 'Notification for upcoming appointments',
//             icon: android.smallIcon ?? '@mipmap/ic_launcher',
//             importance: Importance.high,
//             priority: Priority.high,
//           ),
//         ),
//       );
//     }
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(const Duration(days: 1)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );
//     if (pickedDate != null) {
//       setState(() {
//         selectedDate = pickedDate;
//       });
//     }
//   }

//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (pickedTime != null) {
//       setState(() {
//         selectedTime = pickedTime;
//       });
//     }
//   }

//   Future<void> _bookAppointment() async {
//     if (selectedDate == null || selectedTime == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select both date and time")),
//       );
//       return;
//     }

//     // Schedule the notification
//     bool success = await _scheduleNotification();

//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             "Appointment booked successfully! You'll receive a notification.",
//           ),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Appointment booked but notification setup failed."),
//         ),
//       );
//     }
//   }

//   Future<bool> _scheduleNotification() async {
//     try {
//       // Cancel any existing notifications with the same ID
//       await flutterLocalNotificationsPlugin.cancel(0);

//       // Combine selected date and time into a DateTime object
//       final DateTime appointmentDateTime = DateTime(
//         selectedDate!.year,
//         selectedDate!.month,
//         selectedDate!.day,
//         selectedTime!.hour,
//         selectedTime!.minute,
//       );

//       // For testing - notification 5 seconds from now
//       final DateTime notificationTime = DateTime.now().add(
//         const Duration(seconds: 5),
//       );

//       // For production - notification 1 hour before appointment
//       // final DateTime notificationTime = appointmentDateTime.subtract(const Duration(hours: 1));

//       final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
//         notificationTime,
//         tz.local,
//       );

//       // Configure notification details
//       const AndroidNotificationDetails androidDetails =
//           AndroidNotificationDetails(
//             'booking_channel_id',
//             'Booking Notifications',
//             channelDescription: 'Notification for upcoming appointments',
//             importance: Importance.max,
//             priority: Priority.high,
//             icon: '@mipmap/ic_launcher',
//             playSound: true,
//             enableVibration: true,
//           );

//       const NotificationDetails platformDetails = NotificationDetails(
//         android: androidDetails,
//       );

//       // Schedule the notification
//       await flutterLocalNotificationsPlugin.zonedSchedule(
//         0, // notification id
//         'Upcoming Appointment',
//         'You have an appointment at ${selectedTime!.format(context)} on ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
//         scheduledDate,
//         platformDetails,
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//         matchDateTimeComponents: DateTimeComponents.time,
//       );

//       debugPrint('Notification scheduled for: $scheduledDate');

//       // Also schedule a Firebase Cloud Message for redundancy
//       // In a real app, you would typically send this to your server
//       // which would then use Firebase Admin SDK to schedule the notification
//       _scheduleFirebaseNotification(appointmentDateTime);

//       return true;
//     } catch (e) {
//       debugPrint('Error scheduling notification: $e');
//       return false;
//     }
//   }

//   Future<void> _scheduleFirebaseNotification(DateTime appointmentTime) async {
//     // This is a simplified example. In a real-world scenario,
//     // you would send this data to your backend server, which would
//     // then schedule the Firebase notification using the Admin SDK.

//     // For now, we'll just log what would be sent
//     debugPrint('Would schedule Firebase notification for: $appointmentTime');
//     debugPrint(
//       'With payload: {"type": "appointment_reminder", "time": "${appointmentTime.toIso8601String()}"}',
//     );

//     // If you have a Firebase Function set up, you could make an HTTP request to it:
//     // final response = await http.post(
//     //   Uri.parse('https://your-firebase-function-url'),
//     //   headers: {'Content-Type': 'application/json'},
//     //   body: jsonEncode({
//     //     'userId': 'user-id-here',
//     //     'appointmentTime': appointmentTime.toIso8601String(),
//     //     'title': 'Upcoming Appointment',
//     //     'body': 'You have an appointment soon',
//     //   }),
//     // );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Book Appointment'),
//         backgroundColor: Colors.deepPurple,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             ListTile(
//               title: const Text("Select Date"),
//               subtitle: Text(
//                 selectedDate != null
//                     ? "${selectedDate!.toLocal()}".split(' ')[0]
//                     : "No date selected",
//               ),
//               trailing: const Icon(Icons.calendar_today),
//               onTap: () => _selectDate(context),
//             ),
//             ListTile(
//               title: const Text("Select Time"),
//               subtitle: Text(
//                 selectedTime != null
//                     ? selectedTime!.format(context)
//                     : "No time selected",
//               ),
//               trailing: const Icon(Icons.access_time),
//               onTap: () => _selectTime(context),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _bookAppointment,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                 child: Text("Book Now", style: TextStyle(fontSize: 16)),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 // Show a test notification immediately for debugging
//                 const AndroidNotificationDetails androidDetails =
//                     AndroidNotificationDetails(
//                       'test_channel_id',
//                       'Test Notifications',
//                       channelDescription: 'For testing notifications',
//                       importance: Importance.max,
//                       priority: Priority.high,
//                     );
//                 const NotificationDetails platformDetails = NotificationDetails(
//                   android: androidDetails,
//                 );

//                 await flutterLocalNotificationsPlugin.show(
//                   1,
//                   'Test Notification',
//                   'This is a test notification',
//                   platformDetails,
//                 );

//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Test notification sent")),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.grey[300],
//                 foregroundColor: Colors.black87,
//               ),
//               child: const Text("Send Test Notification"),
//             ),
//             const SizedBox(height: 12),
//             ElevatedButton(
//               onPressed: () async {
//                 // Send a test Firebase message (simulated)
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text(
//                       "FCM Test: In a real app, this would trigger a Firebase Cloud Message",
//                     ),
//                     duration: Duration(seconds: 3),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange[300],
//                 foregroundColor: Colors.black87,
//               ),
//               child: const Text("Test Firebase Message"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// extension on AndroidFlutterLocalNotificationsPlugin? {
//   requestPermissions({
//     required bool alert,
//     required bool badge,
//     required bool sound,
//   }) {}
// }
