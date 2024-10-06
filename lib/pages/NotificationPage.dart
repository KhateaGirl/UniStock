import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:UNISTOCK/services/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  final String userId;

  NotificationsPage({required this.userId});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();
  late StreamSubscription<QuerySnapshot> _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeNotificationListener();
  }

  void _initializeNotificationListener() {
    _notificationSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          // Extract the data from the document change
          final data = docChange.doc.data() as Map<String, dynamic>;

          // Check if the notification status is 'unread'
          if (data['status'] == 'unread') {
            // Extract title, message, and timestamp
            final String title = data['title'] ?? 'No Title';
            final String message = data['message'] ?? 'No Message';
            final String timestamp = data['timestamp'] != null
                ? DateFormat.yMMMd().add_jm().format((data['timestamp'] as Timestamp).toDate())
                : 'No Timestamp';

            // Construct the notification body with your desired format
            final String notificationBody = "$message\n$title as of $timestamp";

            // Show the notification using NotificationService
            _notificationService.showNotification(
              widget.userId,
              docChange.doc.id.hashCode, // Use document ID's hash as a unique ID
              title,
              notificationBody,
              docChange.doc.id, // Pass the document ID as the fifth argument
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        title: Text('Notifications', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(), // Get all notifications regardless of status
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
            return _buildNotificationCard(data, doc.id);
          }).toList();

          return ListView(children: notifications);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> data, String docId) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['title'] ?? 'No Title',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              data['message'] ?? 'No Message',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            _buildNotificationFooter(data, docId),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationFooter(Map<String, dynamic> data, String docId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          data['timestamp'] != null
              ? DateFormat.yMMMd().add_jm().format((data['timestamp'] as Timestamp).toDate())
              : 'No Timestamp',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        if (data['orderSummary'] != null)
          TextButton(
            onPressed: () {
              // Update the status of the notification to 'read'
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .collection('notifications')
                  .doc(docId)
                  .update({'status': 'read'});

              // Navigate to OrderSummaryPage and pass the necessary document ID
              Navigator.pushNamed(
                context,
                '/orderSummary',
                arguments: {
                  'userId': widget.userId,
                  'docId': docId,
                },
              );
            },
            child: Text('View Receipt'),
          ),
      ],
    );
  }

  void _showOrderSummaryDialog(BuildContext context, Map<String, dynamic> data) {
    final orderSummary = List<Map<String, dynamic>>.from(data['orderSummary']);
    final timestamp = data['timestamp'] != null
        ? DateFormat.yMMMd().add_jm().format((data['timestamp'] as Timestamp).toDate())
        : 'No Timestamp';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogHeader(),
                SizedBox(height: 16),
                _buildOrderSummaryContent(orderSummary),
                Divider(),
                _buildDialogFooter(orderSummary, timestamp),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF046be0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 40,
          ),
          SizedBox(height: 8),
          Text(
            'Order Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryContent(List<Map<String, dynamic>> orderSummary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: orderSummary.map((item) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Item: ${item['label'] ?? 'N/A'}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text("Size: ${item['itemSize'] ?? 'N/A'}", style: TextStyle(fontSize: 14)),
              SizedBox(height: 4),
              Text("Quantity: ${item['quantity'] ?? 'N/A'}", style: TextStyle(fontSize: 14)),
              SizedBox(height: 4),
              Text("Price per Piece: \$${item['pricePerPiece'] ?? 'N/A'}", style: TextStyle(fontSize: 14)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDialogFooter(List<Map<String, dynamic>> orderSummary, String timestamp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Total Amount: \$${orderSummary.fold(0.0, (prev, item) => prev + (item['quantity'] ?? 0) * (item['pricePerPiece'] ?? 0)).toStringAsFixed(2)}",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        SizedBox(height: 16),
        Text(
          'Ref No: 4019 002 649304',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        Text(
          timestamp,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
