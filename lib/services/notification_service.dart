import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:UNISTOCK/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class NotificationService {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationService() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  Future<void> _onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;

    if (payload != null && payload.isNotEmpty) {
      final Map<String, dynamic> payloadData = jsonDecode(payload);
      final String userId = payloadData['userId'];
      final String docId = payloadData['docId'];

      DocumentSnapshot<Map<String, dynamic>> notificationSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(docId)
          .get();

      if (notificationSnapshot.exists) {
        final data = notificationSnapshot.data();
        if (data != null && data.containsKey('orderSummary') && data['orderSummary'] != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('notifications')
              .doc(docId)
              .update({'status': 'read'});

          navigatorKey.currentState?.pushNamed(
            '/orderSummary',
            arguments: {'userId': userId, 'docId': docId},
          );
        } else {
        }
      }
    }
  }

  Future<void> showNotification(String userId, int id, String title, String body, String docId) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    final String payload = jsonEncode({'userId': userId, 'docId': docId});

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}
