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

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Inventory_stock')
          .doc('college_items')
          .collection(formattedCourseLabel)
          .doc(widget.itemId)
          .get();

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        if (data == null) {
          throw ('Document data is null for itemId: ${widget.itemId}');
        }

        print('Debug: Fetched document data: $data');

        if (data.containsKey('sizes')) {
          var sizesData = data['sizes'];

          if (sizesData is Map<String, dynamic>) {
            setState(() {
              availableSizes = sizesData.keys.toList();
              if (_selectedSize.isNotEmpty && sizesData[_selectedSize] != null) {
                _availableQuantity = sizesData[_selectedSize]['quantity'] ?? 0;
              }
            });
          } else {
            throw ('The "sizes" field exists but is not a Map for itemId: ${widget.itemId}');
          }
        } else {
          setState(() {
            availableSizes = [];
          });
        }

        setState(() {
          category = data['category'] ?? 'college_items';
          courseLabel = widget.courseLabel;
        });
      } else {
        setState(() {
          availableSizes = [];
          category = 'Unknown';
        });
      }
    } catch (e) {
      print('Error fetching item details: $e');
      setState(() {
        availableSizes = [];
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(
            itemLabel: widget.itemLabel,
            itemSize: availableSizes.isNotEmpty ? _selectedSize : null,
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
    if (availableSizes.isNotEmpty && _selectedSize.isEmpty) {
      showSizeNotSelectedDialog();
    } else {
      String userId = widget.currentProfileInfo.userId;

      CollectionReference cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart');

      await cartRef.add({
        'itemLabel': widget.itemLabel,
        'itemSize': availableSizes.isNotEmpty ? _selectedSize : null,
        'imagePath': widget.imagePath,
        'price': widget.price,
        'quantity': _currentQuantity,
        'category': category ?? 'Unknown',
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
          print('Selected size changed to: $_selectedSize');

          // Update the available quantity for the selected size
          if (value != null && value.isNotEmpty) {
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
                  });
                }
              }
            });
          }
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
