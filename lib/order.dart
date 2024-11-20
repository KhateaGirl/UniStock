class Order {
  final String label;
  final String itemSize;
  final int price;
  final int quantity;
  String status;

  Order({
    required this.label,
    required this.itemSize,
    required this.price,
    required this.quantity,
    this.status = 'Processing',
  });
}
