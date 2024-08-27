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
  final List<Order> orders;

  OrdersPage({required this.orders});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
        backgroundColor: Color(0xFF046be0),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return ListTile(
              title: Text(order.itemName),
              subtitle:
                  Text('Quantity: ${order.quantity}, Price: \$${order.price}'),
            );
          },
        ),
      ),
    );
  }
}
