import 'package:flutter/material.dart';
import 'package:UNISTOCK/pages/CartPage.dart';
import 'package:UNISTOCK/pages/CheckoutPage.dart';

class ProwareShirtsPage extends StatefulWidget {
  @override
  _ProwareShirtsPageState createState() => _ProwareShirtsPageState();
}

class _ProwareShirtsPageState extends State<ProwareShirtsPage> {
  String selectedSize = '';
  String selectedShirtType = 'College'; // Default selection
  PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  // Image paths for shirts
  final String collegeShirtImage = 'assets/images/washdayshirt1.png';
  final String shsShirtImage = 'assets/images/SHS_WASHDAY.png';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void handleAddToCart() {
    if (selectedSize.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Item Added to Cart'),
            content: Text(
              'Added to cart: $selectedShirtType Wash-Day Shirt, Size $selectedSize',
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    } else {
      // Show an alert dialog to prompt size selection
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Please select a size'),
            content: Text('You haven\'t selected a size for your shirt.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Choose your Proware/Wash-Day Shirt',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: MediaQuery.of(context).size.width * 0.8,
                child: Stack(
                  children: [
                    PageView(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: [
                        selectedShirtType == 'College'
                            ? buildShirtImage(collegeShirtImage)
                            : buildShirtImage(shsShirtImage),
                      ],
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          1,
                          (index) => buildPageIndicator(index),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'ProWare/Wash-Day Shirt',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: buildShirtTypeOption(
                        context,
                        'College Wash Day',
                        selectedShirtType == 'College',
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: buildShirtTypeOption(
                        context,
                        'SHS Wash Day',
                        selectedShirtType == 'SHS',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8.0,
                runSpacing: 8.0,
                children: buildSizeSelection(context),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle checkout
                      if (selectedSize.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                              itemLabel: '$selectedShirtType Wash-Day Shirt',
                              itemSize: selectedSize,
                              imagePath: selectedShirtType == 'College'
                                  ? collegeShirtImage
                                  : shsShirtImage,
                              price: 195, // Add price here if needed
                              quantity: 1, // Default quantity
                            ),
                          ),
                        );
                      } else {
                        // Show an alert dialog to prompt size selection
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Please select a size'),
                              content: Text(
                                  'You haven\'t selected a size for your shirt.'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  OutlinedButton(
                    onPressed: () {
                      // Handle add to cart
                      handleAddToCart();
                    },
                    style: OutlinedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      side: BorderSide(color: Colors.blue, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildShirtTypeOption(
      BuildContext context, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedShirtType = label.contains('College') ? 'College' : 'SHS';
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.blue,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildSizeSelection(BuildContext context) {
    List<String> sizes = ['S', 'M', 'L', 'XL', '2XL', '3XL'];
    return sizes.map((size) {
      bool isSelected = size == selectedSize;
      return GestureDetector(
        onTap: () {
          setState(() {
            selectedSize = size; // Update selected size
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
    }).toList();
  }

  Widget buildShirtImage(String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildPageIndicator(int index) {
    return Container(
      width: 8,
      height: 8,
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? Colors.blue : Colors.grey,
      ),
    );
  }
}
