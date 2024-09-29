import 'package:UNISTOCK/pages/OrdersPage.dart' as UNISTOCKOrder;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Order {
  final String itemName;
  final int quantity;
  final int price;
  final Timestamp orderDate;
  final String category;      // Add category field
  final String courseLabel;   // Add course label field

  Order({
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.orderDate,
    required this.category,    // Initialize category
    required this.courseLabel, // Initialize courseLabel
  });
}

class OrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF046be0),
          title: Text('My Orders'),
          centerTitle: true,
        ),
        body: Center(child: Text('Please log in to view your orders.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF046be0),
        title: Text('My Orders'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('orders')
            .orderBy('orderDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            // Ensure orderDate is a Timestamp
            Timestamp orderTimestamp;
            if (data['orderDate'] is Timestamp) {
              orderTimestamp = data['orderDate'];
            } else {
              orderTimestamp = Timestamp.now();
            }

            return UNISTOCKOrder.Order(
              itemName: data['itemLabel'] ?? 'Unknown',
              quantity: data['quantity'] ?? 0,
              price: data['price'] ?? 0,
              orderDate: orderTimestamp,
              category: data['category'] ?? 'Unknown',  // Read category
              courseLabel: data['courseLabel'] ?? 'Unknown',  // Read course label
            );
          }).toList();

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              // Convert Timestamp to DateTime for display
              final DateTime orderDateTime = order.orderDate.toDate();

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.itemName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Unit Price: ₱${order.price ~/ order.quantity}'), // Display the unit price calculated from total and quantity
                      Text('Quantity: ${order.quantity}'),
                      Text('Total: ₱${order.price}'), // Keep total price as it is
                      SizedBox(height: 8),
                      Text(
                        'Order Date: ${DateFormat.yMMMd().add_jm().format(orderDateTime)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Category: ${order.category}', // Display category
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Course Label: ${order.courseLabel}', // Display courseLabel
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
