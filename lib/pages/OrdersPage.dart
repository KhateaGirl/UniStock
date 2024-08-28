import 'package:UNISTOCK/pages/OrdersPage.dart' as UNISTOCKOrder;
import 'package:flutter/material.dart';

class Order {
  final String itemName;
  final int quantity;
  final int price;

  Order({
    required this.itemName,
    required this.quantity,
    required this.price,
  });
}
class OrdersPage extends StatelessWidget {
  final List<UNISTOCKOrder.Order> orders;

  OrdersPage({required this.orders});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF046be0),
        title: Text('My Orders'),
        centerTitle: true,
      ),
      body: orders.isEmpty
          ? Center(child: Text('No orders found.'))
          : ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
