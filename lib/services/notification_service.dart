import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:UNISTOCK/main.dart'; // Import to access the navigator key
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert'; // Import to use jsonEncode and jsonDecode

class NotificationService {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationService() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Initialize with settings
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  // Handle when the user taps the notification
  Future<void> _onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;

    if (payload != null && payload.isNotEmpty) {
      // Decode the payload to extract userId and docId
      final Map<String, dynamic> payloadData = jsonDecode(payload);

      final String userId = payloadData['userId'];
      final String docId = payloadData['docId'];

      // Fetch the notification data to check if an orderSummary exists
      DocumentSnapshot<Map<String, dynamic>> notificationSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(docId)
          .get();

      if (notificationSnapshot.exists) {
        final data = notificationSnapshot.data();
        if (data != null && data.containsKey('orderSummary') && data['orderSummary'] != null) {
          // Update the status to 'read'
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('notifications')
              .doc(docId)
              .update({'status': 'read'});

          // Navigate to the Order Summary using the payload as the document ID
          navigatorKey.currentState?.pushNamed(
            '/orderSummary',
            arguments: {'userId': userId, 'docId': docId},
          );
        } else {
          // Optionally, log a message or handle it differently
          print("No order summary available for this notification.");
        }
      }
    }
  }

  Future<void> showNotification(String userId, int id, String title, String body, String docId) async {
    // Android specific notification details
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id', // You can define this channel id for different types of notifications
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    // Create a payload with userId and docId
    final String payload = jsonEncode({'userId': userId, 'docId': docId});

    // Show the notification with the document ID as payload
    await flutterLocalNotificationsPlugin.show(
      id, // Unique id for each notification to avoid duplication
      title,
      body,
      platformChannelSpecifics,
      payload: payload, // Pass the document ID as the payload to handle notification taps
    );
  }
}
