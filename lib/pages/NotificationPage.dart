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
        backgroundColor: Color(0xFFFFFFFF),
        title: Text('Notifications', style: TextStyle(color: Colors.black)),
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
                    // Aligning timestamp and View Receipt button using Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['timestamp'] != null
                              ? DateFormat.yMMMd().add_jm().format((data['timestamp'] as Timestamp).toDate())
                              : 'No Timestamp',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        // Conditionally display the "View Receipt" button
                        if (data['orderSummary'] != null)
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  final orderSummary = List<Map<String, dynamic>>.from(data['orderSummary']);
                                  final timestamp = data['timestamp'] != null
                                      ? DateFormat.yMMMd().add_jm().format((data['timestamp'] as Timestamp).toDate())
                                      : 'No Timestamp';

                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Header section
                                          Container(
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
                                          ),
                                          SizedBox(height: 16),
                                          // Content section
                                          Column(
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
                                                      "Item: ${item['itemLabel'] ?? 'N/A'}",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      "Size: ${item['itemSize'] ?? 'N/A'}",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      "Quantity: ${item['quantity'] ?? 'N/A'}",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      "Price per Piece: \$${item['pricePerPiece'] ?? 'N/A'}",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                          Divider(),
                                          // Footer section
                                          Text(
                                            "Total Amount: \$${orderSummary.fold(0.0, (prev, item) => prev + (item['quantity'] ?? 0) * (item['pricePerPiece'] ?? 0)).toStringAsFixed(2)}",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Ref No: 4019 002 649304',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          Text(
                                            timestamp,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          // Close button
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
                            },
                            child: Text('View Receipt'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList();

          return ListView(children: notifications);
        },
      ),
    );
  }
}
