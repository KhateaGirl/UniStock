import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:UNISTOCK/pages/CheckoutPage.dart';
import 'package:UNISTOCK/ProfileInfo.dart';

class DetailSelectionCOL extends StatefulWidget {
  final String itemId;
  final String itemLabel;
  final String courseLabel;
  final String? itemSize;
  final String imagePath;
  final int price; // General price
  final int quantity;
  final ProfileInfo currentProfileInfo;

  DetailSelectionCOL({
    required this.itemId,
    required this.itemLabel,
    required this.courseLabel,
    required this.itemSize,
    required this.imagePath,
    required this.price,
    required this.quantity,
    required this.currentProfileInfo,
  });

  @override
  _DetailSelectionCOLState createState() => _DetailSelectionCOLState();
}

class _DetailSelectionCOLState extends State<DetailSelectionCOL> {
  int _currentQuantity = 1;
  String _selectedSize = '';
  List<String> availableSizes = [];
  Map<String, int?> sizePrices = {}; // Track prices by size
  Map<String, int> sizeQuantities = {}; // Track quantities by size
  int _displayPrice = 0; // Display price based on the selected size
  int _availableQuantity = 0; // Track the available quantity for the selected size

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.quantity;
    _selectedSize = widget.itemSize ?? '';
    _displayPrice = widget.price; // Set the default price to the general price

    _fetchItemDetailsFromFirestore();
  }

  Future<void> _fetchItemDetailsFromFirestore() async {
    try {
      String courseLabel = widget.courseLabel;

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Inventory_stock')
          .doc('college_items')
          .collection(courseLabel)
          .doc(widget.itemId)
          .get();

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        if (data == null) {
          setState(() {
            availableSizes = [];
            _selectedSize = '';
            _availableQuantity = 0;
          });
          return;
        }

        if (data.containsKey('sizes') && data['sizes'] is Map<String, dynamic>) {
          var sizesData = data['sizes'] as Map<String, dynamic>;

          // Extract size prices and quantities
          sizePrices = sizesData.map((size, details) {
            if (details is Map<String, dynamic> && details.containsKey('price')) {
              return MapEntry(size, details['price'] != null ? details['price'] as int? : null);
            } else {
              return MapEntry(size, null); // Price is null if not specified
            }
          });

          sizeQuantities = sizesData.map((size, details) {
            if (details is Map<String, dynamic> && details.containsKey('quantity')) {
              return MapEntry(size, details['quantity'] ?? 0);
            } else {
              return MapEntry(size, 0);
            }
          });

          String defaultSize = sizesData.keys.isNotEmpty ? sizesData.keys.first : '';
          int initialQuantity = defaultSize.isNotEmpty ? sizeQuantities[defaultSize] ?? 0 : 0;
          int initialPrice = defaultSize.isNotEmpty && sizePrices[defaultSize] != null ? sizePrices[defaultSize]! : widget.price;

          setState(() {
            availableSizes = sizesData.keys.toList();
            _selectedSize = _selectedSize.isEmpty ? defaultSize : _selectedSize;
            _availableQuantity = initialQuantity;
            _displayPrice = initialPrice; // Set display price to initial size price
          });
        } else {
          setState(() {
            availableSizes = [];
            _selectedSize = '';
            _availableQuantity = 1;
            _displayPrice = data['price'] ?? widget.price; // Use general price
          });
        }
      } else {
        setState(() {
          availableSizes = [];
          _selectedSize = '';
          _availableQuantity = 0;
        });
      }
    } catch (e) {
      setState(() {
        availableSizes = [];
        _selectedSize = '';
        _availableQuantity = 0;
      });
    }
  }

  bool get disableButtons {
    if (availableSizes.isEmpty) {
      return true;
    }

    if (_selectedSize.isEmpty) {
      return true;
    }

    return false;
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
    if (availableSizes.isNotEmpty && _selectedSize.isEmpty) {
      showSizeNotSelectedDialog();
    } else {
      final int totalPrice = _displayPrice * _currentQuantity; // Calculate the total price

      // Debug information before checkout
      print("Debug: Checkout initiated - Item: ${widget.itemLabel}, Size: $_selectedSize, Quantity: $_currentQuantity, Total Price: $totalPrice");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(
            itemLabel: widget.itemLabel,
            itemSize: availableSizes.isNotEmpty ? _selectedSize : null,
            imagePath: widget.imagePath,
            unitPrice: _displayPrice,  // Use the size-specific price
            price: totalPrice,  // Store the total price in the `price` field itself
            quantity: _currentQuantity,
            category: 'college_items',  // Pass the correct category here
            currentProfileInfo: widget.currentProfileInfo,
          ),
        ),
      );
    }
  }

  void handleAddToCart() async {
    if (availableSizes.isNotEmpty && _selectedSize.isEmpty) {
      showSizeNotSelectedDialog();
    } else {
      String userId = widget.currentProfileInfo.userId;

      // Calculate the total price before adding to the cart
      final int totalPrice = _displayPrice * _currentQuantity;

      // Debug information before adding to cart
      print("Debug: Adding to cart - Item: ${widget.itemLabel}, Size: $_selectedSize, Quantity: $_currentQuantity, Total Price: $totalPrice");

      CollectionReference cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart');

      await cartRef.add({
        'itemLabel': widget.itemLabel,
        'itemSize': availableSizes.isNotEmpty ? _selectedSize : null,
        'imagePath': widget.imagePath,
        'price': totalPrice, // Store the total price in the `price` field
        'quantity': _currentQuantity,
        'category': 'college_items',  // Store the correct category
        'courseLabel': widget.courseLabel,
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
              if (availableSizes.isNotEmpty) ...[
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

  Widget _buildSizeSelector() {
    return availableSizes.isEmpty
        ? Text(
      'This item does not have sizes available',
      style: TextStyle(color: Colors.grey, fontSize: 16),
    )
        : DropdownButton<String>(
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
          _displayPrice = sizePrices[_selectedSize] ?? widget.price; // Use fallback price if null
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
              print('Quantity decreased: $_currentQuantity');
            });
          }
              : null,
          icon: Icon(Icons.remove),
        ),
        Text('$_currentQuantity'),
        IconButton(
          onPressed: _currentQuantity < _availableQuantity
              ? () {
            setState(() {
              _currentQuantity++;
              print('Quantity increased: $_currentQuantity');
            });
          }
              : null,
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}
