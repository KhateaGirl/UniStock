import 'package:UNISTOCK/ProfileInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:UNISTOCK/pages/CheckoutPage.dart';

class DetailSelectionSHS extends StatefulWidget {
  final String itemLabel;
  final String? itemSize;
  final String imagePath;
  final int price;
  final int quantity;
  final ProfileInfo currentProfileInfo;

  DetailSelectionSHS({
    required this.itemLabel,
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

  @override
  void initState() {
    super.initState();
    _fetchSizesFromFirestore();
  }

  Future<void> _fetchSizesFromFirestore() async {
    try {
      // Fetch the item document from Firestore
      print('Attempting to fetch document for label: ${widget.itemLabel}');

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Inventory_stock')
          .doc('senior_high_items')
          .collection('Items')
          .where('label', isEqualTo: widget.itemLabel)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first; // Get the first matching document
        var data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('sizes') && data['sizes'] != null) {
          Map<String, dynamic> sizesMap = data['sizes'] as Map<String, dynamic>;

          // Debug print to see what sizes are fetched
          print('Fetched sizes from Firestore: $sizesMap');

          // Extract available sizes and quantities
          setState(() {
            availableSizes = sizesMap.keys.toList(); // Extract size labels like '2XL', '5XL'
            sizeQuantities = sizesMap.map((size, details) =>
                MapEntry(size, details['quantity'] ?? 0)); // Extract quantities

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
          });
        }
      } else {
        print('No document found with label: ${widget.itemLabel}');
      }
    } catch (e) {
      print('Error fetching sizes: $e');
      setState(() {
        availableSizes = [];
        sizeQuantities = {};
      });
    }
  }

  bool get disableButtons {
    // Disable buttons if:
    // 1. No sizes are available.
    // 2. A size is required but not selected.
    // 3. The selected size does not have sufficient stock for the current quantity.
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(
            itemLabel: widget.itemLabel,
            itemSize: _selectedSize,
            imagePath: widget.imagePath,
            price: widget.price,
            quantity: _currentQuantity,
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

      CollectionReference cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart');

      await cartRef.add({
        'itemLabel': widget.itemLabel,
        'itemSize': _selectedSize,
        'imagePath': widget.imagePath,
        'price': widget.price,
        'quantity': _currentQuantity,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

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
                'Price: ₱${widget.price}', // Keep it as int
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
          child: Text('$size (${sizeQuantities[size] ?? 0} available)'),
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
