import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [
    CartItem(
      id: 1,
      label: 'SHS APRON',
      imagePath: 'assets/images/SHS_APRON.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
      price: 100,
      quantity: 1,
    ),
    CartItem(
      id: 2,
      label: 'SHS PANTS',
      imagePath: 'assets/images/SHS_PANTS.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
      price: 150,
      quantity: 1,
    ),
    // Add more items as needed
  ];

  List<int> selectedItems = [];
  bool selectAll = false;

  void handleCheckboxChanged(bool? value, int id) {
    setState(() {
      if (value == true) {
        selectedItems.add(id);
      } else {
        selectedItems.remove(id);
      }
    });
  }

  void handleQuantityChanged(int id, int quantity) {
    setState(() {
      cartItems.firstWhere((item) => item.id == id).quantity = quantity;
    });
  }

  void handleSizeChanged(int id, String size) {
    setState(() {
      cartItems.firstWhere((item) => item.id == id).selectedSize = size;
    });
  }

  void handleSelectAllChanged(bool? value) {
    setState(() {
      selectAll = value ?? false;
      if (selectAll) {
        selectedItems = cartItems.map((item) => item.id).toList();
      } else {
        selectedItems.clear();
      }
    });
  }

  void handleCheckout() {
    // Implement your checkout logic here
    print("Checked out items: $selectedItems");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: Color(0xFF046be0),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Checkbox(
                  value: selectAll,
                  onChanged: handleSelectAllChanged,
                ),
                Text(
                  'Select All',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return buildCartItem(cartItems[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: handleCheckout,
              child: Text('Checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFEB3B),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCartItem(CartItem item) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Checkbox(
              value: selectedItems.contains(item.id),
              onChanged: (bool? value) {
                handleCheckboxChanged(value, item.id);
              },
            ),
            Image.asset(
              item.imagePath,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  DropdownButton<String>(
                    value: item.selectedSize,
                    hint: Text('Select Size'),
                    onChanged: (newSize) {
                      handleSizeChanged(item.id, newSize!);
                    },
                    items: item.availableSizes.map((size) {
                      return DropdownMenuItem<String>(
                        value: size,
                        child: Text(size),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₱${item.price}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: item.quantity > 1
                                ? () {
                                    handleQuantityChanged(
                                        item.id, item.quantity - 1);
                                  }
                                : null,
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              handleQuantityChanged(item.id, item.quantity + 1);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItem {
  final int id;
  final String label;
  final String imagePath;
  final List<String> availableSizes;
  String? selectedSize;
  final int price;
  int quantity;

  CartItem({
    required this.id,
    required this.label,
    required this.imagePath,
    required this.availableSizes,
    this.selectedSize,
    required this.price,
    this.quantity = 1,
  });
}
