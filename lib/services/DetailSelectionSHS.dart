import 'package:UNISTOCK/ProfileInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:UNISTOCK/pages/CheckoutPage.dart';

class DetailSelectionSHS extends StatefulWidget {
  final String label;
  final String? itemSize;
  final String imagePath;
  final int price;
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
  List<String> availableSizes = [];
  Map<String, int> sizeQuantities = {};
  Map<String, int?> sizePrices = {};

  @override
  void initState() {
    super.initState();
    _fetchSizesFromFirestore();
  }

  Future<void> _fetchSizesFromFirestore() async {
    try {
      print('Attempting to fetch document for label: ${widget.label}');

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Inventory_stock')
          .doc('senior_high_items')
          .collection('Items')
          .where('label', isEqualTo: widget.label)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        var data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('sizes') && data['sizes'] != null) {
          Map<String, dynamic> sizesMap = data['sizes'] as Map<String, dynamic>;

          print('Fetched sizes from Firestore: $sizesMap');

          setState(() {
            availableSizes = sizesMap.keys.toList();
            sizeQuantities = sizesMap.map((size, details) =>
                MapEntry(size, details['quantity'] ?? 0));
            sizePrices = sizesMap.map((size, details) =>
                MapEntry(size, details['price'] != null ? details['price'] as int : null));

            availableSizes = availableSizes.where((size) => sizeQuantities[size]! > 0).toList();

            print('Available sizes after filtering: $availableSizes');
          });
        } else {
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
      return true;
    }

    if (_selectedSize.isEmpty) {
      return true;
    }

    if (sizeQuantities[_selectedSize] == null || sizeQuantities[_selectedSize]! < _currentQuantity) {
      return true;
    }

    return false;
  }

  void handleCheckout() {
    if (_selectedSize.isEmpty) {
      showSizeNotSelectedDialog();
    } else {
      final int? sizePrice = sizePrices[_selectedSize];
      final int unitPrice = sizePrice ?? widget.price;
      final int totalPrice = unitPrice * _currentQuantity;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(
            label: widget.label,
            itemSize: _selectedSize,
            imagePath: widget.imagePath,
            unitPrice: unitPrice,
            price: totalPrice,
            quantity: _currentQuantity,
            category: 'senior_high_items',
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
      final int unitPrice = sizePrice ?? widget.price;
      final int totalPrice = unitPrice * _currentQuantity;

      CollectionReference cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart');

      await cartRef.add({
        'label': widget.label,
        'itemSize': _selectedSize,
        'imagePath': widget.imagePath,
        'price': totalPrice,
        'quantity': _currentQuantity,
        'category': 'senior_high_items',
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item added to cart!')),
      );
    }
  }

  void handlePreOrder() async {
    String userId = widget.currentProfileInfo.userId;

    final int? sizePrice = sizePrices[_selectedSize];
    final int unitPrice = sizePrice ?? widget.price;
    final int totalPrice = unitPrice * _currentQuantity;

    CollectionReference preOrderRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('preorders');

    await preOrderRef.add({
      'label': widget.label,
      'itemSize': _selectedSize,
      'imagePath': widget.imagePath,
      'price': totalPrice,
      'quantity': _currentQuantity,
      'category': 'senior_high_items',
      'status': 'pre-ordered',
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item added to pre-order!')),
    );
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
    final int displayPrice = sizePrice ?? widget.price;

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
                'Price: ₱$displayPrice',
                style: TextStyle(fontSize: 20),
              ),
              _buildQuantitySelector(),
              SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'This item is either out of stock or requires a size selection.',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centers the buttons
                  children: [
                    ElevatedButton(
                      onPressed: disableButtons ? null : handleCheckout,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Smaller padding
                        textStyle: const TextStyle(fontSize: 12), // Smaller font size
                      ),
                      child: const Text('Checkout'),
                    ),
                    const SizedBox(width: 8), // Space between buttons
                    OutlinedButton(
                      onPressed: disableButtons ? null : handleAddToCart,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2), // Smaller padding
                        textStyle: const TextStyle(fontSize: 12), // Smaller font size
                      ),
                      child: const Text('Add to Cart'),
                    ),
                    const SizedBox(width: 8), // Space between buttons
                    ElevatedButton(
                      onPressed: handlePreOrder, // Always enabled
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2), // Smaller padding
                        textStyle: const TextStyle(fontSize: 12, color: Colors.white), // Smaller font size
                      ),
                      child: const Text('Pre-order'),
                    ),
                  ],
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
