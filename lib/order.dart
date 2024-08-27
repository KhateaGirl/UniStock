class Order {
  final String itemLabel;
  final String itemSize;
  final int price;
  final int quantity;
  String status;

  Order({
    required this.itemLabel,
    required this.itemSize,
    required this.price,
    required this.quantity,
    this.status = 'Processing', // Initial status
  });
}
