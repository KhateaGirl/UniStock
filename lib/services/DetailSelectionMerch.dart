import 'package:UNISTOCK/ProfileInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:UNISTOCK/pages/CheckoutPage.dart';

class DetailSelectionMerch extends StatefulWidget {
  final String itemLabel;
  final String? itemSize;
  final String imagePath;
  final int price;
  final int quantity;
  final ProfileInfo currentProfileInfo;

  DetailSelectionMerch({
    required this.itemLabel,
    this.itemSize,
    required this.imagePath,
    required this.price,
    required this.quantity,
    required this.currentProfileInfo,
  });

  @override
  _DetailSelectionMerchState createState() => _DetailSelectionMerchState();
}

class _DetailSelectionMerchState extends State<DetailSelectionMerch> {
  int _currentQuantity = 1;
  String _selectedSize = '';
  List<String> availableSizes = []; // List to store available sizes
  Map<String, int> sizeQuantities = {}; // Track available quantities by size
  Map<String, int?> sizePrices = {}; // Track prices by size

  int _displayPrice = 0; // Display price based on the selected size
  int _availableQuantity = 0; // Track available quantity for the selected size

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.quantity;
    _selectedSize = widget.itemSize ?? '';
    _displayPrice = widget.price; // Set the default price to the general price

    _fetchSizesFromFirestore();
  }


  Future<void> _fetchSizesFromFirestore() async {
    try {
      // Check if the item does not need a size selector
      if (['water bottle', 'wearable pin', 'sti face mask', 'laces']
          .contains(widget.itemLabel.toLowerCase())) {
        setState(() {
          availableSizes = [];
        });
        return;
      }

      // Fetch the item document from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Inventory_stock')
          .doc('Merch & Accessories')
          .get();

      // Check if the document exists and fetch the sizes
      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey(widget.itemLabel) &&
            data[widget.itemLabel]['sizes'] != null) {
          Map<String, dynamic> sizesMap = data[widget.itemLabel]['sizes'];
          setState(() {
            availableSizes = sizesMap.keys.toList();
            sizeQuantities = sizesMap.map((size, details) {
              return MapEntry(size, details['quantity'] ?? 0);
            });
            sizePrices = sizesMap.map((size, details) {
              return MapEntry(size, details['price'] != null ? details['price'] as int? : widget.price); // Fallback to widget.price if null
            });
          });
        } else {
          setState(() {
            availableSizes = [];
            sizeQuantities = {};
            sizePrices = {};
          });
        }
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

  bool get showSizeOptions =>
      widget.itemSize != null && availableSizes.isNotEmpty;

  bool get disableButtons {
    // Disable buttons if no size selected, no available sizes, or no quantity for the selected size
    return availableSizes.isEmpty ||
        (_selectedSize.isNotEmpty && (sizeQuantities[_selectedSize] ?? 0) < _currentQuantity);
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

  void handleCheckout() {
    if (showSizeOptions && _selectedSize.isEmpty) {
      showSizeNotSelectedDialog();
    } else {
      final int unitPrice = _displayPrice; // Use the updated _displayPrice that takes size or fallback into account
      final int totalPrice = unitPrice * _currentQuantity;

      // Debug information before proceeding to checkout
      print("Debug: Checkout initiated - Item: ${widget.itemLabel}, Size: $_selectedSize, Quantity: $_currentQuantity, Total Price: $totalPrice, Category: merch_and_accessories");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(
            itemLabel: widget.itemLabel,
            itemSize: _selectedSize,
            imagePath: widget.imagePath,
            unitPrice: unitPrice,
            price: totalPrice,
            quantity: _currentQuantity,
            category: 'merch_and_accessories',
            currentProfileInfo: widget.currentProfileInfo,
          ),
        ),
      );
    }
  }

  void handleAddToCart() async {
    if (showSizeOptions && _selectedSize.isEmpty) {
      showSizeNotSelectedDialog();
    } else {
      String userId = widget.currentProfileInfo.userId;

      final int unitPrice = _displayPrice; // Use _displayPrice to account for selected size or fallback
      final int totalPrice = unitPrice * _currentQuantity;

      // Debug information before adding to cart
      print("Debug: Adding to cart - Item: ${widget.itemLabel}, Size: $_selectedSize, Quantity: $_currentQuantity, Total Price: $totalPrice, Category: merch_and_accessories");

      CollectionReference cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart');

      await cartRef.add({
        'itemLabel': widget.itemLabel,
        'itemSize': _selectedSize,
        'imagePath': widget.imagePath,
        'price': unitPrice,
        'quantity': _currentQuantity,
        'totalPrice': totalPrice,
        'category': 'merch_and_accessories',
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item added to cart!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemLabel),
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
                widget.itemLabel,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (showSizeOptions) ...[
                SizedBox(height: 10),
                _buildSizeSelector(),
              ],
              SizedBox(height: 10),
              Text(
                'Price: ₱$_displayPrice', // Display the dynamic price based on the selected size
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

  Widget _buildSizeSelector () {
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
          _displayPrice = sizePrices[_selectedSize] ?? widget.price; // Update price based on size or fallback
          _availableQuantity = sizeQuantities[_selectedSize] ?? 0;
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
            });
          }
              : null,
          icon: Icon(Icons.remove),
        ),
        Text('$_currentQuantity'),
        IconButton(
          onPressed: () {
            setState(() {
              // Only increase if the selected size has enough quantity available
              if (_selectedSize.isNotEmpty && (sizeQuantities[_selectedSize] ?? 0) > _currentQuantity) {
                _currentQuantity++;
              }
            });
          },
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}