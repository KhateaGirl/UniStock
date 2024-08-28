import 'package:UNISTOCK/ProfileInfo.dart';
import 'package:flutter/material.dart';
import 'package:UNISTOCK/pages/CheckoutPage.dart'; // Adjust the import path as necessary

class DetailSelection extends StatefulWidget {
  final String itemLabel;
  final String? itemSize; // Nullable String for itemSize
  final String imagePath;
  final int price;
  final int quantity;
  final ProfileInfo currentProfileInfo;

  DetailSelection({
    required this.itemLabel,
    this.itemSize, // Nullable String
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

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.quantity;
    _selectedSize = widget.itemSize ??
        ''; // Initialize selected size from widget's initial value or empty string
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
            currentProfileInfo: widget.currentProfileInfo, // Pass the correct profile info here
          ),
        ),
      );
    }
  }

  void handleAddToCart() {
    if (showSizeOptions && _selectedSize.isEmpty) {
      showSizeNotSelectedDialog();
    } else {
      // Add to cart logic
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF046be0),
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
              color: Colors.white,
            ),
            children: <TextSpan>[
              TextSpan(text: 'UNI'),
              TextSpan(text: 'STOCK', style: TextStyle(color: Colors.yellow)),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () {
                  _showFullImage(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      widget.imagePath,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 0.8,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.itemLabel,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (showSizeOptions) ...[
                      SizedBox(height: 10),
                      _buildSizeSelector(),
                    ],
                    SizedBox(height: 10),
                    Text(
                      'Price: ₱${widget.price}',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildQuantitySelector(),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 120,
                          child: ElevatedButton(
                            onPressed: handleCheckout,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: Color(0xFFFFEB3B),
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
                        SizedBox(
                          width: 120,
                          child: OutlinedButton(
                            onPressed: handleAddToCart,
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
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              widget.imagePath,
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSizeSelector() {
    List<String> sizes = ['S', 'M', 'L', 'XL', '2XL', '3XL'];
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Size:',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 5),
          Wrap(
            spacing: 8.0,
            children: sizes.map((size) {
              bool isSelected = size == _selectedSize;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSize = size;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.blue[50],
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    size,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.blue,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        Text(
          'Quantity:',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(width: 10),
        IconButton(
          onPressed: () {
            setState(() {
              if (_currentQuantity > 1) {
                _currentQuantity--;
              }
            });
          },
          icon: Icon(Icons.remove),
        ),
        Text(
          '$_currentQuantity',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey[700],
          ),
        ),
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
