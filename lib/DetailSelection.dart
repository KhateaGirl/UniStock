import 'package:flutter/material.dart';

class DetailSelection extends StatelessWidget {
  final String itemId;
  final String itemImage;
  final String itemLabel;
  final int itemPrice;

  DetailSelection({
    required this.itemId,
    required this.itemImage,
    required this.itemLabel,
    required this.itemPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(itemLabel),
      ),
      body: Center(
        child: Column(
          children: [
            Image.asset(itemImage),
            Text(itemLabel),
            Text('₱$itemPrice'),
            // Add more details or actions here as needed
          ],
        ),
      ),
    );
  }
}
