import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Order {
  final String itemName;
  final int quantity;
  final int price;
  final Timestamp orderDate;
  final String category;
  final String courseLabel;
  final String? status;

  Order({
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.orderDate,
    required this.category,
    required this.courseLabel,
    this.status,
  });
}

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  int? _expandedIndex;

  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    final User? user = auth.currentUser;
    if (user == null) {
      return [];
    }

    List<Map<String, dynamic>> allOrders = [];

    QuerySnapshot userOrdersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .get();

    for (var doc in userOrdersSnapshot.docs) {
      var orderData = doc.data() as Map<String, dynamic>;
      allOrders.add({
        'receiptId': doc.id,
        'orderDate': orderData['orderDate'] as Timestamp,
        'items': orderData['items'] as List<dynamic>,
      });
    }

    QuerySnapshot approvedPreordersSnapshot = await FirebaseFirestore.instance
        .collection('approved_preorders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('preOrderDate', descending: true)
        .get();

    for (var doc in approvedPreordersSnapshot.docs) {
      var preorderData = doc.data() as Map<String, dynamic>;
      allOrders.add({
        'receiptId': doc.id,
        'orderDate': preorderData['preOrderDate'] as Timestamp,
        'items': preorderData['items'] as List<dynamic>,
      });
    }

    allOrders.sort((a, b) =>
        (b['orderDate'] as Timestamp).compareTo(a['orderDate'] as Timestamp));

    return allOrders;
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders found.'));
          }

          final orderDocs = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: orderDocs.length,
            itemBuilder: (context, index) {
              final orderData = orderDocs[index];
              final orderItems = orderData['items'] as List<dynamic>;
              final int orderTotal = orderItems.fold<int>(
                0,
                    (sum, item) =>
                sum + ((item['price'] ?? 0) as int) * ((item['quantity'] ?? 0) as int),
              );
              final DateTime orderDateTime = (orderData['orderDate'] as Timestamp).toDate();

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        'Receipt ID: ${orderData['receiptId']}',
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
                              _expandedIndex = null;
                            } else {
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
                              title: Text(item['label'] ?? 'Unknown Item'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Size: ${item['itemSize'] ?? 'N/A'}'),
                                  Text('Unit Price: ₱${item['price'] ?? 0}'),
                                  Text('Quantity: ${item['quantity'] ?? 0}'),
                                  SizedBox(height: 5),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Transaction Total: ₱$orderTotal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
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
