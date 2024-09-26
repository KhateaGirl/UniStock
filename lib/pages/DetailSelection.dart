import 'package:UNISTOCK/ProfileInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:UNISTOCK/pages/CheckoutPage.dart';

class DetailSelection extends StatefulWidget {
  final String itemLabel;
  final String? itemSize; // Nullable String for itemSize
  final String imagePath;
  final int price; // Keep price as int
  final int quantity;
  final ProfileInfo currentProfileInfo;

  DetailSelection({
    required this.itemLabel,
    this.itemSize,
    required this.imagePath,
    required this.price,
    required this.quantity,
    required this.currentProfileInfo,
  });

  @override
  _DetailSelectionState createState() => _DetailSelectionState();
}

class _DetailSelectionState extends State<DetailSelection> {
  int _currentQuantity = 1;
  String _selectedSize = '';
  List<String> availableSizes = []; // List to store available sizes

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.quantity; // Initialize _currentQuantity with the quantity parameter
    _selectedSize = widget.itemSize ?? ''; // Initialize _selectedSize with itemSize or default to empty string

    // Fetch sizes dynamically from Firestore
    _fetchSizesFromFirestore();
  }

  // Fetch available sizes from Firestore
  Future<void> _fetchSizesFromFirestore() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Inventory_stock')
          .doc('senior_high_items')
          .collection('Items')
          .doc(widget.itemLabel)
          .get();

      if (doc.exists && doc['sizes'] != null) {
        List<dynamic> fetchedSizes = doc['sizes'];
        setState(() {
          availableSizes = List<String>.from(fetchedSizes);
        });
      } else {
        // Fallback to default hardcoded sizes
        setState(() {
          availableSizes = ['S', 'M', 'L', 'XL', '2XL', '3XL'];
        });
      }
    } catch (e) {
      print('Error fetching sizes: $e');
      setState(() {
        availableSizes = ['S', 'M', 'L', 'XL', '2XL', '3XL'];
      });
    }
  }

  bool get showSizeOptions => widget.itemSize != null;

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
    if (showSizeOptions && _selectedSize.isEmpty) {
      showSizeNotSelectedDialog();
    } else {
      String userId = widget.currentProfileInfo.userId;

      CollectionReference cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart');

      await cartRef.add({
        'itemLabel': widget.itemLabel,
        'itemSize': showSizeOptions ? _selectedSize : null,
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
                'Price: ₱${widget.price}', // Keep it as int
                style: TextStyle(fontSize: 20),
              ),
              _buildQuantitySelector(),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: handleCheckout,
                    child: Text('Checkout'),
                  ),
                  SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: handleAddToCart,
                    child: Text('Add to Cart'),
                  ),
                ],
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
          child: Text(size),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSize = value ?? '';
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
              _currentQuantity++;
            });
          },
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}
