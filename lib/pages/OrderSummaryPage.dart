import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderSummaryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String userId = args['userId'];
    final String docId = args['docId'];

    return Scaffold(
      appBar: AppBar(
        title: Text("Order Summary"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc(docId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Order Summary Not Found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (data['orderSummary'] == null) {
            return Center(child: Text("Order Summary Not Found"));
          }

          final String studentName = data['studentName'] ?? 'N/A';
          final String studentId = data['studentId'] ?? 'N/A';

          List<Map<String, dynamic>> orderSummaryList;
          if (data['orderSummary'] is Map) {
            orderSummaryList = [Map<String, dynamic>.from(data['orderSummary'])];
          } else if (data['orderSummary'] is List) {
            orderSummaryList = List<Map<String, dynamic>>.from(data['orderSummary']);
          } else {
            return Center(child: Text("Invalid Order Summary Format"));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 60,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Order Summary',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student Name: $studentName',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Student ID: $studentId',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...orderSummaryList.map((item) {
                        final int quantity = item['quantity'] ?? 0;
                        final double pricePerPiece = (item['pricePerPiece'] ?? 0).toDouble();

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Item: ${item['label'] ?? 'N/A'}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text("Size: ${item['itemSize'] ?? 'N/A'}",
                                  style: TextStyle(fontSize: 16)),
                              SizedBox(height: 8),
                              Text("Quantity: $quantity",
                                  style: TextStyle(fontSize: 16)),
                              SizedBox(height: 8),
                              Text(
                                "Price per Piece: \₱${pricePerPiece.toStringAsFixed(2)}",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 20),
                      Divider(),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Total Amount",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "\₱${orderSummaryList.fold(0.0, (prev, item) {
                                final int quantity = item['quantity'] ?? 0;
                                final double pricePerPiece = (item['pricePerPiece'] ?? 0).toDouble();
                                return prev + (quantity * pricePerPiece);
                              }).toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
