import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;  // Add this field
  final String itemLabel;
  final String imagePath;
  final List<String> availableSizes;
  String? selectedSize;
  final int price;
  int quantity;
  bool selected;

  CartItem({
    required this.id,  // Include id in the constructor
    required this.itemLabel,
    required this.imagePath,
    required this.availableSizes,
    this.selectedSize,
    required this.price,
    this.quantity = 1,
    this.selected = false,
  });

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,  // Assign the document ID here
      itemLabel: data['itemLabel'] ?? 'Unknown',
      imagePath: data['imagePath'] ?? 'assets/images/placeholder.png',
      availableSizes: List<String>.from(data['availableSizes'] ?? []),
      selectedSize: data['itemSize'] as String?,  // Use this to differentiate
      price: data['price'] ?? 0,
      quantity: data['quantity'] ?? 1,
      selected: data['selected'] ?? false,
    );
  }
}
