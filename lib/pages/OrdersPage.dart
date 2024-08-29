import 'package:UNISTOCK/pages/OrdersPage.dart' as UNISTOCKOrder;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Order {
  final String itemName;
  final int quantity;
  final int price;
  final Timestamp orderDate; // This will hold the formatted date as a String

  Order({
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.orderDate, // Pass the formatted date string here
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

            Timestamp orderTimestamp;
            if (data['orderDate'] is String) {
              DateTime parsedDate = DateFormat("yyyy-MM-dd HH:mm:ss").parse(data['orderDate']);
              orderTimestamp = Timestamp.fromDate(parsedDate);
            } else {
              orderTimestamp = data['orderDate'] ?? Timestamp.now();
            }

            return UNISTOCKOrder.Order(
              itemName: data['itemLabel'] ?? 'Unknown',
              quantity: data['quantity'] ?? 0,
              price: data['price'] ?? 0,
              orderDate: orderTimestamp,
            );
          }).toList();

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              // Convert Timestamp to DateTime
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
                      Text('Quantity: ${order.quantity}'),
                      Text('Price: \$${order.price}'),
                      Text(
                        'Total: \$${order.price * order.quantity}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Order Date: ${DateFormat.yMMMd().add_jm().format(order.orderDate.toDate())}',
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
