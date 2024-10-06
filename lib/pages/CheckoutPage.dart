import 'package:UNISTOCK/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:UNISTOCK/pages/home_page.dart';
import 'package:UNISTOCK/pages/uniform_page.dart';
import 'package:UNISTOCK/pages/MerchAccessoriesPage.dart';
import 'package:UNISTOCK/pages/ProfilePage.dart';
import 'package:UNISTOCK/ProfileInfo.dart';

class CheckoutPage extends StatefulWidget {
  final String label;
  final String? itemSize;
  final String imagePath;
  final int unitPrice;
  final int price;
  final int quantity;
  final String category;
  final ProfileInfo currentProfileInfo;

  CheckoutPage({
    required this.label,
    required this.itemSize,
    required this.imagePath,
    required this.unitPrice,
    required this.price,
    required this.quantity,
    required this.category,
    required this.currentProfileInfo,
  });

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool isOrderProcessing = false; // To track if order is being processed

  final NotificationService notificationService = NotificationService();

  void showTermsAndConditionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Terms and Conditions'),
              content: Container(
                width: double.maxFinite,
                height: 300,
                child: SingleChildScrollView(
                  child: Text(
                    '1. Acceptance of Terms: By accessing or using this service, you agree to be bound by these terms and conditions. If you do not agree with any part of these terms, you may not use the service.\n\n'
                        '2. Use of Service: The service provided is for personal and non-commercial use only. You agree not to modify, copy, distribute, transmit, display, perform, reproduce, publish, license, create derivative works from, transfer, or sell any information, software, products, or services obtained from the service.\n\n'
                        '3. User Responsibilities: You are responsible for maintaining the confidentiality of any account information and passwords used for this service. You agree to accept responsibility for all activities that occur under your account or password.\n\n'
                        '4. Privacy: Your use of the service is subject to our Privacy Policy, which governs the collection, use, and disclosure of your information. By using the service, you consent to the practices described in the Privacy Policy.\n\n'
                        '5. Limitation of Liability: In no event shall we be liable for any direct, indirect, incidental, special, consequential, or punitive damages arising out of or related to your use of the service, whether based on warranty, contract, tort (including negligence), or any other legal theory.\n\n'
                        '6. Indemnification: You agree to indemnify and hold harmless the service provider, its affiliates, officers, directors, employees, and agents from and against any claims, liabilities, damages, losses, and expenses, including without limitation reasonable legal and accounting fees, arising out of or in any way connected with your access to or use of the service or your violation of these terms.\n\n'
                        '7. Modification of Terms: We reserve the right to modify or revise these terms and conditions at any time without prior notice. By continuing to use the service after such modifications, you agree to be bound by the revised terms.\n\n'
                        '8. Governing Law: These terms and conditions shall be governed by and construed in accordance with the laws of [Jurisdiction], without regard to its conflict of law provisions.\n\n'
                        '9. Contact: If you have any questions or concerns about these terms and conditions, please contact us at [Contact Information].',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Deny'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: isOrderProcessing
                      ? CircularProgressIndicator() // Show loading if processing
                      : Text('Accept'),
                  onPressed: isOrderProcessing
                      ? null // Disable button when processing
                      : () async {
                    setState(() {
                      isOrderProcessing = true; // Set flag to true
                    });

                    try {
                      // Calculate total price
                      final int totalPrice = widget.price * widget.quantity;

                      print(
                          "Placing Order - Item: ${widget.label}, Price: ${widget.price}, Quantity: ${widget.quantity}, Total: $totalPrice");

                      // Add order to Firestore and get the generated document reference
                      DocumentReference orderDocRef = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.currentProfileInfo.userId)
                          .collection('orders') // Subcollection for orders
                          .add({
                        'label': widget.label,
                        'itemSize': widget.itemSize,
                        'imagePath': widget.imagePath,
                        'price': widget.price,
                        'quantity': widget.quantity,
                        'totalPrice': totalPrice, // Storing the total price in Firestore
                        'category': widget.category, // Store the correct category
                        'orderDate': FieldValue.serverTimestamp(),
                      });

                      // Now use the document ID from the generated order
                      await notificationService.showNotification(
                        widget.currentProfileInfo.userId,
                        0,
                        'Order Placed',
                        'Your order for ${widget.label} has been successfully placed!',
                        orderDocRef.id, // Add the document ID as the fifth argument
                      );

                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PurchaseSummaryPage(
                            label: widget.label,
                            itemSize: widget.itemSize,
                            imagePath: widget.imagePath,
                            price: widget.price,
                            quantity: widget.quantity,
                            category: widget.category, // Pass category to summary page
                            currentProfileInfo: widget.currentProfileInfo,
                          ),
                        ),
                      );
                    } catch (e) {
                      // Handle error (e.g., show a message to the user)
                      print("Error placing order: $e");
                    } finally {
                      setState(() {
                        isOrderProcessing = false; // Reset flag
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
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
              // Navigate to cart page or handle cart functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Item:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.network(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                      return Center(
                        child: Icon(Icons.error, size: 50, color: Colors.red),
                      );
                    },
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Size: ${widget.itemSize}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Price: ₱${widget.price}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Quantity: ${widget.quantity}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showTermsAndConditionsDialog(context);
              },
              child: Text('Proceed to Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}

class PurchaseSummaryPage extends StatelessWidget {
  final String label;
  final String? itemSize;
  final String imagePath;
  final int price;
  final int quantity;
  final String category;
  final ProfileInfo currentProfileInfo;

  PurchaseSummaryPage({
    required this.label,
    required this.itemSize,
    required this.imagePath,
    required this.price,
    required this.quantity,
    required this.category,
    required this.currentProfileInfo,
  });

  Future<void> _saveOrderToFirestore() async {
    try {
      // Calculate total price
      final int totalPrice = price * quantity;

      print(
          "Saving Order - Item: $label, Price: $price, Quantity: $quantity, Total: $totalPrice");

      // Add order to Firestore
      CollectionReference orders = FirebaseFirestore.instance
          .collection('users')
          .doc(currentProfileInfo.userId)
          .collection('orders');

      await orders.add({
        'label': label,
        'itemSize': itemSize,
        'imagePath': imagePath,
        'price': price,
        'quantity': quantity,
        'totalPrice': totalPrice, // Store the total price in Firestore
        'category': category, // Store the correct category
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Order added to Firestore");
    } catch (e) {
      print("Failed to add order: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalCost = price * quantity;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF046be0),
        title: Text('Purchase Summary'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thank you for your purchase!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: imagePath.isNotEmpty
                          ? NetworkImage(imagePath)
                          : AssetImage(
                          'assets/icons/default_icon.png') as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Size: $itemSize',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Price: ₱$price',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Quantity: $quantity',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Total: ₱$totalCost',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _saveOrderToFirestore();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HomePage(
                          profileInfo: currentProfileInfo,
                          navigationItems: [
                            {
                              'icon': Icons.inventory,
                              'label': 'Uniform',
                              'onPressed': () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UniformPage(
                                          currentProfileInfo: currentProfileInfo)),
                                );
                              }
                            },
                            {
                              'icon': Icons.shopping_bag,
                              'label': 'Merch/Accessories',
                              'onPressed': () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MerchAccessoriesPage(
                                              currentProfileInfo: currentProfileInfo)),
                                );
                              }
                            },
                            {
                              'icon': Icons.account_circle,
                              'label': 'Profile',
                              'onPressed': () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfilePage(
                                        profileInfo: currentProfileInfo),
                                  ),
                                );
                              }
                            },
                          ],
                        ),
                  ),
                );
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
