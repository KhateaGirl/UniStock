import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;  // Document ID
  final String itemLabel;
  final String imagePath;
  final List<String> availableSizes;
  String? selectedSize;
  final int price;
  int quantity;
  bool selected;
  final String category; // Add category field
  final String courseLabel; // Add course label field

  CartItem({
    required this.id,  // Include id in the constructor
    required this.itemLabel,
    required this.imagePath,
    required this.availableSizes,
    this.selectedSize,
    required this.price,
    this.quantity = 1,
    this.selected = false,
    required this.category,  // Include category
    required this.courseLabel, // Include courseLabel
  });

  // Factory method to create a CartItem from Firestore data
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
      category: data['category'] ?? 'Unknown', // Assign category value
      courseLabel: data['courseLabel'] ?? 'Unknown', // Assign course label value
    );
  }

  // Method to convert to a Map for saving back to Firestore if needed
  Map<String, dynamic> toMap() {
    return {
      'itemLabel': itemLabel,
      'imagePath': imagePath,
      'availableSizes': availableSizes,
      'itemSize': selectedSize,
      'price': price,
      'quantity': quantity,
      'selected': selected,
      'category': category, // Add category to map
      'courseLabel': courseLabel, // Add course label to map
    };
  }
}
