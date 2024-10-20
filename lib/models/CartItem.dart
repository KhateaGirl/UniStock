import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String label;
  final String imagePath;
  final List<String> availableSizes;
  String? selectedSize;
  int price;
  int quantity;
  bool selected;
  final String category;
  final String courseLabel;
  List<DocumentReference> documentReferences;

  CartItem({
    required this.id,
    required this.label,
    required this.imagePath,
    required this.availableSizes,
    this.selectedSize,
    required this.price,
    this.quantity = 1,
    this.selected = false,
    required this.category,
    required this.courseLabel,
    this.documentReferences = const [],
  });

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,
      label: data['label'] ?? 'Unknown',
      imagePath: data['imagePath'] ?? 'assets/images/placeholder.png',
      availableSizes: List<String>.from(data['availableSizes'] ?? []),
      selectedSize: data['itemSize'] as String?,
      price: data['price'] ?? 0,
      quantity: data['quantity'] ?? 1,
      selected: data['selected'] ?? false,
      category: data['category'] ?? 'Unknown',
      courseLabel: data['courseLabel'] ?? 'Unknown',
      documentReferences: [doc.reference],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'imagePath': imagePath,
      'availableSizes': availableSizes,
      'itemSize': selectedSize,
      'price': price,
      'quantity': quantity,
      'selected': selected,
      'category': category,
      'courseLabel': courseLabel,
    };
  }

  void addDocumentReference(DocumentReference ref) {
    documentReferences.add(ref);
  }
}
