import 'package:flutter/material.dart';
import 'package:UNISTOCK/pages/home_page.dart';

class CheckoutPage extends StatelessWidget {
  final String itemLabel;
  final String itemSize;
  final String imagePath;
  final int price;
  final int quantity;

  CheckoutPage({
    required this.itemLabel,
    required this.itemSize,
    required this.imagePath,
    required this.price,
    required this.quantity,
  });

  void showTermsAndConditionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Terms and Conditions'),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: SingleChildScrollView(
              child: Text(
                // Randomly generated terms and conditions
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
              child: Text('Accept'),
              onPressed: () {
                Navigator.of(context).pop();
                // Show the summary page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PurchaseSummaryPage(
                      itemLabel: itemLabel,
                      itemSize: itemSize,
                      imagePath: imagePath,
                      price: price,
                      quantity: quantity,
                    ),
                  ),
                );
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
                    image: DecorationImage(
                      image: AssetImage(imagePath),
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
                        itemLabel,
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Price: \$$price',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Quantity: $quantity',
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
                // Show terms and conditions dialog
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
  final String itemLabel;
  final String itemSize;
  final String imagePath;
  final int price;
  final int quantity;

  PurchaseSummaryPage({
    required this.itemLabel,
    required this.itemSize,
    required this.imagePath,
    required this.price,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
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
                      image: AssetImage(imagePath),
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
                        itemLabel,
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
                      SizedBox(height: 5),
                      Text(
                        'Price: \$$price',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Quantity: $quantity',
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomePage()), // Navigate to the home page
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
