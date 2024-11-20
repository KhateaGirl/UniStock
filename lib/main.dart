import 'dart:async';
import 'package:UNISTOCK/pages/OrderSummaryPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:UNISTOCK/services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UNISTOCK',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorKey: navigatorKey,
      home: AppWithNotificationListener(),
      routes: {
        '/orderSummary': (context) => OrderSummaryPage(),
      },
    );
  }
}

class AppWithNotificationListener extends StatefulWidget {
  @override
  _AppWithNotificationListenerState createState() => _AppWithNotificationListenerState();
}

class _AppWithNotificationListenerState extends State<AppWithNotificationListener> {
  final NotificationService _notificationService = NotificationService();
  late StreamSubscription<QuerySnapshot> _notificationSubscription;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _setupNotificationListener();
  }

  void _setupNotificationListener() {
    User? user = _auth.currentUser;
    if (user != null) {
      _notificationSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        for (var docChange in snapshot.docChanges) {
          if (docChange.type == DocumentChangeType.added) {
            final data = docChange.doc.data() as Map<String, dynamic>;

            if (data['status'] == 'unread') {
              final String title = data['title'] ?? 'No Title';
              final String message = data['message'] ?? 'No Message';
              final String timestamp = data['timestamp'] != null
                  ? DateFormat.yMMMd().add_jm().format((data['timestamp'] as Timestamp).toDate())
                  : 'No Timestamp';

              final String notificationBody = "$message\n$title as of $timestamp";

              _notificationService.showNotification(
                user.uid,
                docChange.doc.id.hashCode,
                title,
                notificationBody,
                docChange.doc.id,
              );
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoginScreen();
  }
}
