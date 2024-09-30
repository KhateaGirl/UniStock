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
  final int price;
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
  String? category;
  String courseLabel = '';
  int _availableQuantity = 0; // Track the available quantity for the selected size

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.quantity;
    _selectedSize = widget.itemSize ?? '';
    courseLabel = widget.courseLabel;

    _fetchItemDetailsFromFirestore();
  }

  Future<void> _fetchItemDetailsFromFirestore() async {
    try {
      String formattedCourseLabel = widget.courseLabel.replaceAll('&', 'and');
      print('Debug: Fetching document for course: $formattedCourseLabel, item ID: ${widget.itemId}');

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Inventory_stock')
          .doc('college_items')
          .collection(widget.courseLabel) // Instead of using formattedCourseLabel
          .doc(widget.itemId)
          .get();

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        if (data == null) {
          print('Debug: Document data is null for itemId: ${widget.itemId}');
          setState(() {
            availableSizes = [];
            _selectedSize = '';
            _availableQuantity = 0;
          });
          return;
        }

        print('Debug: Fetched document data: $data');

        if (data.containsKey('sizes')) {
          var sizesData = data['sizes'];

          if (sizesData is Map<String, dynamic>) {
            List<String> sizesList = sizesData.keys.toList();
            int initialQuantity = 0;

            // Select a default size if none is selected
            String defaultSize = sizesList.isNotEmpty ? sizesList[0] : '';

            if (defaultSize.isNotEmpty) {
              initialQuantity = sizesData[defaultSize]['quantity'] ?? 0;
            }

            setState(() {
              availableSizes = sizesList;
              _selectedSize = _selectedSize.isEmpty ? defaultSize : _selectedSize;
              _availableQuantity = initialQuantity;
              print('Debug: Available sizes updated: $availableSizes, Default size: $_selectedSize, Quantity for default size: $_availableQuantity');
            });
          } else {
            throw ('The "sizes" field exists but is not a Map for itemId: ${widget.itemId}');
          }
        } else {
          setState(() {
            availableSizes = [];
            _selectedSize = '';
            _availableQuantity = 0;
          });
          print('Debug: No sizes available for itemId: ${widget.itemId}');
        }

        setState(() {
          category = data['category'] ?? 'college_items';
          courseLabel = widget.courseLabel;
        });
      } else {
        print('Debug: Document does not exist for itemId: ${widget.itemId}');
        setState(() {
          availableSizes = [];
          _selectedSize = '';
          _availableQuantity = 0;
          category = 'Unknown';
        });
      }
    } catch (e) {
      print('Error fetching item details: $e');
      setState(() {
        availableSizes = [];
        _selectedSize = '';
        _availableQuantity = 0;
        category = 'Unknown';
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

    return false; // All conditions are met, buttons can be enabled
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
      final int unitPrice = widget.price;
      final int totalPrice = widget.price * _currentQuantity; // Calculate the total price

      // Debug information before checkout
      print("Debug: Checkout initiated - Item: ${widget.itemLabel}, Size: $_selectedSize, Quantity: $_currentQuantity, Total Price: $totalPrice, Category: ${category ?? 'college_items'}");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(
            itemLabel: widget.itemLabel,
            itemSize: availableSizes.isNotEmpty ? _selectedSize : null,
            imagePath: widget.imagePath,
            unitPrice: unitPrice,
            price: totalPrice,  // Store the total price in the `price` field itself
            quantity: _currentQuantity,
            category: category ?? 'college_items',  // Pass the correct category here
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
      final String resolvedCategory = category ?? 'Unknown'; // Ensure category has a default value

      // Calculate the total price before adding to the cart
      final int totalPrice = widget.price * _currentQuantity;

      // Debug information before adding to cart
      print("Debug: Adding to cart - Item: ${widget.itemLabel}, Size: $_selectedSize, Quantity: $_currentQuantity, Total Price: $totalPrice, Category: $resolvedCategory");

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
        'category': resolvedCategory,  // Store the correct category
        'courseLabel': courseLabel,
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
                'Price: ₱${widget.price}',
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
    if (availableSizes.isEmpty) {
      return Text('No available sizes', style: TextStyle(color: Colors.grey));
    }

    print('Debug: Building size selector with available sizes: $availableSizes');

    return DropdownButton<String>(
      value: _selectedSize.isEmpty ? null : _selectedSize,
      hint: Text('Select Size'),
      items: availableSizes.map((size) {
        return DropdownMenuItem(
          value: size,
          child: Text(size),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSize = value ?? '';
          print('Debug: Selected size changed to: $_selectedSize');

          // Fetch the available quantity for the selected size
          String formattedCourseLabel = widget.courseLabel.replaceAll('&', 'and');
          FirebaseFirestore.instance
              .collection('Inventory_stock')
              .doc('college_items')
              .collection(formattedCourseLabel)
              .doc(widget.itemId)
              .get()
              .then((doc) {
            if (doc.exists) {
              var sizesData = doc['sizes'];
              if (sizesData != null && sizesData is Map<String, dynamic>) {
                setState(() {
                  _availableQuantity = sizesData[_selectedSize]['quantity'] ?? 0;
                  print('Debug: Available quantity for size $_selectedSize is $_availableQuantity');
                });
              }
            }
          });
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
          onPressed: _currentQuantity < _availableQuantity // Limit by available stock
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
