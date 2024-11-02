import 'package:UNISTOCK/models/CartItem.dart';
import 'package:UNISTOCK/screensize.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class PreOrderPage extends StatefulWidget {
  @override
  _PreOrderPageState createState() => _PreOrderPageState();
}

class _PreOrderPageState extends State<PreOrderPage> {
  late Stream<List<CartItem>> preOrderItemsStream;
  StreamSubscription<List<CartItem>>? preOrderItemsSubscription;
  Set<int> selectedItems = {};
  bool selectAll = false;
  List<CartItem> preOrderItems = [];

  @override
  void initState() {
    super.initState();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final User? user = auth.currentUser;

    if (user != null) {
      preOrderItemsStream = firestore
          .collection('users')
          .doc(user.uid)
          .collection('preorders')
          .where('status', isNotEqualTo: 'approved')
          .snapshots()
          .map((snapshot) => _aggregatePreOrderItems(snapshot.docs))
          .cast<List<CartItem>>();


      preOrderItemsSubscription = preOrderItemsStream.listen((items) {
        if (mounted) {
          setState(() {
            preOrderItems = items;

            if (selectAll) {
              selectedItems = preOrderItems.map((item) => item.id.hashCode).toSet();
            } else {
              selectedItems = preOrderItems
                  .where((item) => item.selected)
                  .map((item) => item.id.hashCode)
                  .toSet();
            }
          });
        }
      });
    } else {
      preOrderItemsStream = Stream.value([]);
    }
  }

  List<CartItem> _aggregatePreOrderItems(List<DocumentSnapshot> docs) {
    Map<String, CartItem> groupedItems = {};

    for (var doc in docs) {
      if (doc['status'] == 'pre-order confirmed') {
        continue;
      }

      CartItem item = CartItem.fromFirestore(doc);
      String uniqueKey = "${item.label}_${item.selectedSize}";

      if (groupedItems.containsKey(uniqueKey)) {
        final existingItem = groupedItems[uniqueKey]!;
        groupedItems[uniqueKey] = CartItem(
          id: existingItem.id,
          label: existingItem.label,
          imagePath: existingItem.imagePath,
          availableSizes: existingItem.availableSizes,
          selectedSize: existingItem.selectedSize,
          price: existingItem.price + item.price,
          quantity: existingItem.quantity + item.quantity,
          selected: existingItem.selected,
          category: existingItem.category,
          courseLabel: existingItem.courseLabel,
          documentReferences: [...existingItem.documentReferences, doc.reference],
        );
      } else {
        groupedItems[uniqueKey] = CartItem(
          id: item.id,
          label: item.label,
          imagePath: item.imagePath,
          availableSizes: item.availableSizes,
          selectedSize: item.selectedSize,
          price: item.price,
          quantity: item.quantity,
          selected: item.selected,
          category: item.category,
          courseLabel: item.courseLabel,
          documentReferences: [doc.reference],
        );
      }
    }

    return groupedItems.values.toList();
  }

  @override
  void dispose() {
    preOrderItemsSubscription?.cancel();
    super.dispose();
  }

  Future<void> handlePreOrder() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final preOrderCollection = firestore.collection('users').doc(user.uid).collection('preorders');
      final WriteBatch batch = firestore.batch();

      List<Map<String, dynamic>> preOrderDetails = [];
      List<Map<String, dynamic>> orderSummary = []; // This will store each item for the notification summary

      for (CartItem item in preOrderItems) {
        if (item.selected) {
          final itemData = {
            'label': item.label,
            'itemSize': item.selectedSize ?? '',
            'imagePath': item.imagePath,
            'quantity': item.quantity,
            'category': item.category,
            'courseLabel': item.courseLabel,
          };

          // Add item to preOrderDetails for saving the pre-order
          preOrderDetails.add(itemData);

          // Add item to orderSummary for the notification
          orderSummary.add({
            'label': item.label,
            'itemSize': item.selectedSize ?? 'N/A',
            'quantity': item.quantity,
            'pricePerPiece': item.price,
          });

          for (DocumentReference preOrderDocRef in item.documentReferences) {
            batch.delete(preOrderDocRef);
          }
        }
      }

      if (preOrderDetails.isNotEmpty) {
        final preOrderDocRef = preOrderCollection.doc();
        batch.set(preOrderDocRef, {
          'items': preOrderDetails,
          'preOrderDate': FieldValue.serverTimestamp(),
          'status': 'pre-order confirmed',
        });

        try {
          await batch.commit();
          print("Pre-ordered items successfully.");
        } catch (e) {
          print("Failed to complete pre-order operation: $e");
        }
      } else {
        print("No items selected for pre-order.");
      }
    } else {
      print("User not logged in");
    }
  }

  Future<void> updatePreOrderItemSelection(List<DocumentReference> docRefs, bool? selected) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final WriteBatch batch = firestore.batch();

    for (DocumentReference docRef in docRefs) {
      batch.update(docRef, {'selected': selected});
    }

    await batch.commit();
  }

  Future<void> updatePreOrderItemQuantity(String label, int change) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final preOrderDocs = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('preorders')
          .where('label', isEqualTo: label)
          .get();

      if (preOrderDocs.docs.isEmpty) {
        return;
      }

      final firstDoc = preOrderDocs.docs.first;
      final int unitPrice = firstDoc['price'] ~/ firstDoc['quantity'];

      int totalQuantity = preOrderDocs.docs.fold(0, (sum, doc) => sum + (doc['quantity'] as int));
      totalQuantity += change;

      if (totalQuantity > 0) {
        final int newTotalPrice = unitPrice * totalQuantity;

        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('preorders')
            .doc(firstDoc.id)
            .update({
          'quantity': totalQuantity,
          'price': newTotalPrice,
        });

        for (var i = 1; i < preOrderDocs.docs.length; i++) {
          await firestore
              .collection('users')
              .doc(user.uid)
              .collection('preorders')
              .doc(preOrderDocs.docs[i].id)
              .delete();
        }

        setState(() {
          preOrderItems = preOrderItems.map((item) {
            if (item.label == label) {
              return CartItem(
                id: item.id,
                label: item.label,
                imagePath: item.imagePath,
                availableSizes: item.availableSizes,
                selectedSize: item.selectedSize,
                price: newTotalPrice,
                quantity: totalQuantity,
                selected: item.selected,
                category: item.category,
                courseLabel: item.courseLabel,
                documentReferences: item.documentReferences,
              );
            }
            return item;
          }).toList();
        });
      } else {
        for (var doc in preOrderDocs.docs) {
          await firestore
              .collection('users')
              .doc(user.uid)
              .collection('preorders')
              .doc(doc.id)
              .delete();
        }

        setState(() {
          preOrderItems = preOrderItems.where((item) => item.label != label).toList();
        });
      }
    }
  }

  void handlePreOrderCheckboxChanged(bool? value, CartItem item) {
    if (mounted) {
      setState(() {
        if (value == true) {
          selectedItems.add(item.id.hashCode);
        } else {
          selectedItems.remove(item.id.hashCode);
        }
        updatePreOrderItemSelection(item.documentReferences, value);
      });
    }
  }

  void handleSelectAllChanged(bool? value) {
    if (mounted) {
      setState(() {
        selectAll = value ?? false;
        for (var item in preOrderItems) {
          handlePreOrderCheckboxChanged(selectAll, item);
        }
      });
    }
  }

  void handleQuantityChanged(String label, String? itemSize, int change) async {
    await updatePreOrderItemQuantity(label, change);
  }

  void showPreOrderTermsAndConditionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pre-order Terms and Conditions'),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: SingleChildScrollView(
              child: Text(
                '1. Pre-order Agreement: By placing a pre-order, you agree to pay in advance for items that will be delivered at a later date...\n\n'
                    '2. Expected Delivery: Pre-order items may have longer delivery times. Please review the expected delivery date before confirming...\n\n'
                    '3. Changes and Cancellations: You can cancel your pre-order before the expected shipment date. Once processed, cancellations may not be allowed...\n\n'
                    '4. Payment Terms: Full payment is required at the time of pre-order confirmation. We will notify you of any delays...\n\n'
                    '5. Contact: For any inquiries, please reach out to [Contact Information].',
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
              onPressed: () async {
                Navigator.of(context).pop();
                handlePreOrder();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobileDevice;
    final bool isTablet = context.isTabletDevice;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pre-order'),
        backgroundColor: Color(0xFF046be0),
      ),
      body: StreamBuilder<List<CartItem>>(
        stream: preOrderItemsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No items available for pre-order.'));
          }

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(isMobile ? 4.0 : 8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: selectAll,
                      onChanged: handleSelectAllChanged,
                    ),
                    Text(
                      'Select All',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: preOrderItems.length,
                  itemBuilder: (context, index) {
                    return buildPreOrderItem(preOrderItems[index], isMobile);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isMobile ? 4.0 : 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    showPreOrderTermsAndConditionsDialog(context);
                  },
                  child: Text('Confirm Pre-order'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 30 : 50,
                      vertical: isMobile ? 10 : 15,
                    ),
                    textStyle: TextStyle(
                      fontSize: isMobile ? 14 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildPreOrderItem(CartItem item, bool isMobile) {
    final int unitPrice = item.price;
    final int totalPrice = unitPrice * item.quantity;

    return Card(
      margin: EdgeInsets.all(isMobile ? 4.0 : 8.0),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 4.0 : 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(right: isMobile ? 4.0 : 8.0),
              child: Checkbox(
                value: selectedItems.contains(item.id.hashCode),
                onChanged: (bool? value) {
                  handlePreOrderCheckboxChanged(value, item);
                },
              ),
            ),
            SizedBox(
              width: isMobile ? 40 : 50,
              height: isMobile ? 40 : 50,
              child: Image.network(
                item.imagePath,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: isMobile ? 8 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isMobile ? 4 : 8),
                  Text(
                    'Size: ${item.selectedSize ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: isMobile ? 4 : 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₱$unitPrice',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, size: isMobile ? 16 : 24),
                            onPressed: item.quantity > 1
                                ? () {
                              handleQuantityChanged(
                                  item.label, item.selectedSize, -1);
                            }
                                : null,
                          ),
                          Text(
                            '${item.quantity}',
                            style: TextStyle(fontSize: isMobile ? 14 : 16),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, size: isMobile ? 16 : 24),
                            onPressed: () {
                              handleQuantityChanged(
                                  item.label, item.selectedSize, 1);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
