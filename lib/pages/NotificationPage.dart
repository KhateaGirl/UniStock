import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF046be0),
        title: Text('Notifications', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'No new notifications',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
