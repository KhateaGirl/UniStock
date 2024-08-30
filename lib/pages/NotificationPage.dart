import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  final String userId;

  NotificationsPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF046be0),
        title: Text('Notifications', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No new notifications',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Build the list of notifications
          final notifications = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return ListTile(
              title: Text(data['title']),
              subtitle: Text(data['body']),
              trailing: Text(
                DateFormat.yMMMd().add_jm().format(data['timestamp'].toDate()),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            );
          }).toList();

          return ListView(children: notifications);
        },
      ),
    );
  }
}
