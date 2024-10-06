import 'package:UNISTOCK/ProfileInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:UNISTOCK/pages/CheckoutPage.dart';

class DetailSelectionSHS extends StatefulWidget {
  final String label;
  final String? itemSize;
  final String imagePath;
  final int price; // General price
  final int quantity;
  final ProfileInfo currentProfileInfo;

  DetailSelectionSHS({
    required this.label,
    this.itemSize,
    required this.imagePath,
    required this.price,
    required this.quantity,
    required this.currentProfileInfo,
  });

  @override
  _DetailSelectionSHSState createState() => _DetailSelectionSHSState();
}

class _DetailSelectionSHSState extends State<DetailSelectionSHS> {
  int _currentQuantity = 1;
  String _selectedSize = '';
  List<String> availableSizes = []; // List to store available sizes
  Map<String, int> sizeQuantities = {}; // Track available quantities by size
  Map<String, int?> sizePrices = {}; // Track prices by size, nullable

  @override
  void initState() {
    super.initState();
    _fetchSizesFromFirestore();
  }

  Future<void> _fetchSizesFromFirestore() async {
    try {
      // Fetch the item document from Firestore
      print('Attempting to fetch document for label: ${widget.label}');

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Inventory_stock')
          .doc('senior_high_items')
          .collection('Items')
          .where('label', isEqualTo: widget.label)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first; // Get the first matching document
        var data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('sizes') && data['sizes'] != null) {
          Map<String, dynamic> sizesMap = data['sizes'] as Map<String, dynamic>;

          // Debug print to see what sizes are fetched
          print('Fetched sizes from Firestore: $sizesMap');

          // Extract available sizes, quantities, and prices
          setState(() {
            availableSizes = sizesMap.keys.toList(); // Extract size labels like '2XL', '5XL'
            sizeQuantities = sizesMap.map((size, details) =>
                MapEntry(size, details['quantity'] ?? 0)); // Extract quantities
            sizePrices = sizesMap.map((size, details) =>
                MapEntry(size, details['price'] != null ? details['price'] as int : null)); // Extract prices if available

            // Filter available sizes to include only those with quantity > 0
            availableSizes = availableSizes.where((size) => sizeQuantities[size]! > 0).toList();

            print('Available sizes after filtering: $availableSizes');
          });
        } else {
          // Fallback if sizes aren't specified
          print('Sizes are not specified or available.');
          setState(() {
            availableSizes = [];
            sizeQuantities = {};
            sizePrices = {};
          });
        }
      } else {
        print('No document found with label: ${widget.label}');
      }
    } catch (e) {
      print('Error fetching sizes: $e');
      setState(() {
        availableSizes = [];
        sizeQuantities = {};
        sizePrices = {};
      });
    }
  }

  bool get disableButtons {
    if (availableSizes.isEmpty) {
      return true; // No sizes are available, cannot proceed
    }

    if (_selectedSize.isEmpty) {
      return true; // Size selection is required but not selected
    }

    if (sizeQuantities[_selectedSize] == null || sizeQuantities[_selectedSize]! < _currentQuantity) {
      return true; // Not enough stock available for the selected size
    }

    return false; // All conditions met, buttons should be enabled
  }

  void handleCheckout() {
    if (_selectedSize.isEmpty) {
      showSizeNotSelectedDialog();
    } else {
      final int? sizePrice = sizePrices[_selectedSize];
      final int unitPrice = sizePrice ?? widget.price; // Use size-specific price if available
      final int totalPrice = unitPrice * _currentQuantity;

      // Debug information before proceeding to checkout
      print("Debug: Checkout initiated - Item: ${widget.label}, Size: $_selectedSize, Quantity: $_currentQuantity, Total Price: $totalPrice, Category: senior_high_items");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(
            label: widget.label,
            itemSize: _selectedSize,
            imagePath: widget.imagePath,
            unitPrice: unitPrice,  // Pass the unit price
            price: totalPrice,  // Use the total price instead of unit price
            quantity: _currentQuantity,
            category: 'senior_high_items',  // Pass the correct category here
            currentProfileInfo: widget.currentProfileInfo,
          ),
        ),
      );
    }
  }

  void handleAddToCart() async {
    if (_selectedSize.isEmpty) {
      showSizeNotSelectedDialog();
    } else {
      String userId = widget.currentProfileInfo.userId;

      final int? sizePrice = sizePrices[_selectedSize];
      final int unitPrice = sizePrice ?? widget.price; // Use size-specific price if available
      final int totalPrice = unitPrice * _currentQuantity;

      // Debug information before adding to cart
      print("Debug: Adding to cart - Item: ${widget.label}, Size: $_selectedSize, Quantity: $_currentQuantity, Total Price: $totalPrice, Category: senior_high_items");

      // Reference to the user's cart in Firestore
      CollectionReference cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart');

      // Add item to the cart with the total price
      await cartRef.add({
        'label': widget.label,
        'itemSize': _selectedSize,
        'imagePath': widget.imagePath,
        'price': totalPrice,  // Store the total price in the price field
        'quantity': _currentQuantity,
        'category': 'senior_high_items',  // Include category when adding to cart
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Show a confirmation message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item added to cart!')),
      );
    }
  }

  void showSizeNotSelectedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Size Not Selected'),
          content: Text('Please select a size before proceeding.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int? sizePrice = sizePrices[_selectedSize];
    final int displayPrice = sizePrice ?? widget.price; // Use size-specific price if available

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                widget.imagePath,
                height: 300,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 16),
              Text(
                widget.label,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (availableSizes.isNotEmpty) ...[
                SizedBox(height: 10),
                _buildSizeSelector(),
              ],
              SizedBox(height: 10),
              Text(
                'Price: ₱$displayPrice', // Update price based on size selection
                style: TextStyle(fontSize: 20),
              ),
              _buildQuantitySelector(),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: disableButtons ? null : handleCheckout,
                    child: Text('Checkout'),
                  ),
                  SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: disableButtons ? null : handleAddToCart,
                    child: Text('Add to Cart'),
                  ),
                ],
              ),
              if (disableButtons)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'This item is either out of stock or requires a size selection.',
                    style: TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeSelector() {
    return DropdownButton<String>(
      value: _selectedSize.isEmpty ? null : _selectedSize,
      hint: Text('Select Size'),
      items: availableSizes.map((size) {
        return DropdownMenuItem(
          value: size,
          child: Text('$size'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSize = value ?? '';
          print('Selected size changed to: $_selectedSize');
        });
      },
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        Text('Quantity:'),
        IconButton(
          onPressed: _currentQuantity > 1
              ? () {
            setState(() {
              _currentQuantity--;
              print('Quantity decreased: $_currentQuantity');
            });
          }
              : null,
          icon: Icon(Icons.remove),
        ),
        Text('$_currentQuantity'),
        IconButton(
          onPressed: () {
            setState(() {
              if ((_selectedSize.isEmpty && availableSizes.isEmpty) ||
                  (sizeQuantities[_selectedSize] ?? 0) > _currentQuantity) {
                _currentQuantity++;
                print('Quantity increased: $_currentQuantity');
              }
            });
          },
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}
