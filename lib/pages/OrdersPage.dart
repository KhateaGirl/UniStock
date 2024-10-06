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
  final String? status;       // Add status field for additional checks

  Order({
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.orderDate,
    required this.category,    // Initialize category
    required this.courseLabel, // Initialize courseLabel
    this.status,               // Initialize status
  });
}

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  int? _expandedIndex; // To track which card is currently expanded

  Stream<QuerySnapshot> _getOrdersStream() {
    final User? user = auth.currentUser;
    if (user == null) {
      return Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
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
        stream: _getOrdersStream(),
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

          final orderDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: orderDocs.length,
            itemBuilder: (context, index) {
              final orderData = orderDocs[index].data() as Map<String, dynamic>;
              final orderItems = orderData['items'] as List<dynamic>;

              // Convert Timestamp to DateTime for display
              final DateTime orderDateTime = orderData['orderDate'] != null
                  ? (orderData['orderDate'] as Timestamp).toDate()
                  : DateTime.now();

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        'Receipt ID: ${orderDocs[index].id}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(
                        'Order Date: ${DateFormat.yMMMd().add_jm().format(orderDateTime)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          _expandedIndex == index ? Icons.expand_less : Icons.expand_more,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_expandedIndex == index) {
                              // If the current card is already expanded, collapse it
                              _expandedIndex = null;
                            } else {
                              // Expand the new card and collapse any previous one
                              _expandedIndex = index;
                            }
                          });
                        },
                      ),
                    ),
                    if (_expandedIndex == index)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: orderItems.length,
                          itemBuilder: (context, itemIndex) {
                            final item = orderItems[itemIndex] as Map<String, dynamic>;

                            return ListTile(
                              leading: Image.network(
                                item['imagePath'] ?? '',
                                width: 50,
                                height: 50,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.image, size: 50);
                                },
                              ),
                              title: Text(item['itemLabel'] ?? 'Unknown Item'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Size: ${item['itemSize'] ?? 'N/A'}'),
                                  Text('Unit Price: ₱${item['price'] ?? 0}'),
                                  Text('Quantity: ${item['quantity'] ?? 0}'),
                                  Text('Total: ₱${(item['price'] ?? 0) * (item['quantity'] ?? 0)}'),
                                  SizedBox(height: 5),
                                  Text(
                                    'Category: ${item['category'] ?? 'Unknown'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'Course Label: ${item['courseLabel'] ?? 'Unknown'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
