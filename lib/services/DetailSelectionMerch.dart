import 'package:UNISTOCK/ProfileInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:UNISTOCK/pages/CheckoutPage.dart';

class DetailSelectionMerch extends StatefulWidget {
  final String label;
  final String? itemSize;
  final String imagePath;
  final int price;
  final int quantity;
  final ProfileInfo currentProfileInfo;

  DetailSelectionMerch({
    required this.label,
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
  List<String> availableSizes = [];
  Map<String, int> sizeQuantities = {};
  Map<String, int?> sizePrices = {};

  int _displayPrice = 0;
  int _availableQuantity = 0;

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.quantity;
    _selectedSize = widget.itemSize ?? '';
    _displayPrice = widget.price;

    _fetchSizesFromFirestore();
  }

  Future<void> _fetchSizesFromFirestore() async {
    try {
      if (['water bottle', 'wearable pin', 'sti face mask', 'laces']
          .contains(widget.label.toLowerCase())) {
        setState(() {
          availableSizes = [];
        });
        return;
      }

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Inventory_stock')
          .doc('Merch & Accessories')
          .get();

      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey(widget.label) &&
            data[widget.label]['sizes'] != null) {
          Map<String, dynamic> sizesMap = data[widget.label]['sizes'];
          setState(() {
            availableSizes = sizesMap.keys.toList();
            sizeQuantities = sizesMap.map((size, details) {
              return MapEntry(size, details['quantity'] ?? 0);
            });
            sizePrices = sizesMap.map((size, details) {
              return MapEntry(size, details['price'] != null ? details['price'] as int? : widget.price);
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

  bool get showSizeOptions => widget.itemSize != null && availableSizes.isNotEmpty;

  bool get disableButtons {
    // Disable buttons if there are no sizes available or if the selected size is out of stock
    if (availableSizes.isEmpty || _selectedSize.isEmpty || (sizeQuantities[_selectedSize] ?? 0) < _currentQuantity) {
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
    if (showSizeOptions && _selectedSize.isEmpty) {
      showSizeNotSelectedDialog();
    } else {
      final int unitPrice = _displayPrice;
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

      final int unitPrice = _displayPrice;
      final int totalPrice = unitPrice * _currentQuantity;

      CollectionReference cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart');

      await cartRef.add({
        'label': widget.label,
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

  void handlePreOrder() async {
    if (showSizeOptions && _selectedSize.isEmpty) {
      showSizeNotSelectedDialog();
    } else {
      String userId = widget.currentProfileInfo.userId;

      final int unitPrice = _displayPrice;
      final int totalPrice = unitPrice * _currentQuantity;

      CollectionReference preOrderRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('preorders');

      await preOrderRef.add({
        'label': widget.label,
        'itemSize': _selectedSize,
        'imagePath': widget.imagePath,
        'price': unitPrice,
        'quantity': _currentQuantity,
        'totalPrice': totalPrice,
        'category': 'merch_and_accessories',
        'status': 'pre-ordered',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item added to pre-order!')),
      );
    }
  }

  Widget _buildButtonsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(width: 40),
          Expanded(
            child: ElevatedButton(
              onPressed: disableButtons ? null : handleCheckout,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                backgroundColor: disableButtons ? Colors.grey : Color(0xFFFFEB3B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 31, 31, 31),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: disableButtons ? null : handleAddToCart,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                side: BorderSide(color: Colors.blue, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Add to Cart',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: handlePreOrder,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Pre-order',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                    if (showSizeOptions) ...[
                      SizedBox(height: 10),
                      _buildSizeSelector(),
                    ],
                    SizedBox(height: 10),
                    Text(
                      'Price: ₱$_displayPrice',
                      style: TextStyle(fontSize: 20),
                    ),
                    _buildQuantitySelector(),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButtonsRow(),
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
        ],
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
          _displayPrice = sizePrices[_selectedSize] ?? widget.price;
          _availableQuantity = sizeQuantities[_selectedSize] ?? 0;
          _currentQuantity = 1; // Reset quantity to 1 whenever a new size is selected
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
          onPressed: (_selectedSize.isNotEmpty && (sizeQuantities[_selectedSize] ?? 0) > _currentQuantity)
              ? () {
            setState(() {
              _currentQuantity++;
            });
          }
              : null,
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}