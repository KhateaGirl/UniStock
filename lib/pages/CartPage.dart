import 'package:UNISTOCK/models/CartItem.dart';
import 'package:UNISTOCK/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Stream<List<CartItem>> cartItemsStream;
  StreamSubscription<List<CartItem>>? cartItemsSubscription;
  Set<int> selectedItems = {};
  bool selectAll = false;
  List<CartItem> cartItems = [];
  late NotificationService notificationService;

  @override
  void initState() {
    super.initState();
    notificationService = NotificationService(); // Initialize NotificationService
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final User? user = auth.currentUser;

    if (user != null) {
      cartItemsStream = firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .snapshots()
          .map((snapshot) => _aggregateCartItems(snapshot.docs))
          .cast<List<CartItem>>(); // This explicitly casts the stream to the correct type

      cartItemsSubscription = cartItemsStream.listen((items) {
        if (mounted) {
          setState(() {
            cartItems = items;
            // Sync selectedItems with the updated cartItems
            if (selectAll) {
              selectedItems = cartItems.map((item) => item.itemLabel.hashCode).toSet();
            } else {
              selectedItems = cartItems.where((item) => item.selected).map((item) => item.itemLabel.hashCode).toSet();
            }
          });
        }
      });
    } else {
      cartItemsStream = Stream.value([]);
    }
  }

  @override
  void dispose() {
    // Cancel the subscription to avoid calling setState after dispose
    cartItemsSubscription?.cancel();
    super.dispose();
  }

  List<CartItem> _aggregateCartItems(List<QueryDocumentSnapshot> docs) {
    final Map<String, CartItem> itemMap = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final String itemLabel = data['itemLabel'] ?? 'Unknown';
      final String? itemSize = data['itemSize'] as String?;
      final String key = itemLabel + (itemSize ?? '');

      if (itemMap.containsKey(key)) {
        itemMap[key]!.quantity += (data['quantity'] as int? ?? 1);
      } else {
        itemMap[key] = CartItem.fromFirestore(doc);
      }
    }

    return itemMap.values.toList();
  }

  Future<void> updateCartItem(String itemLabel, String? itemSize, Map<String, dynamic> updates) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final cartCollection = firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart');

      final querySnapshot = await cartCollection
          .where('itemLabel', isEqualTo: itemLabel)
          .where('itemSize', isEqualTo: itemSize)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If the item exists, update it
        for (var doc in querySnapshot.docs) {
          await doc.reference.set(updates, SetOptions(merge: true));
        }
      } else {
        // If the item does not exist, add a new document
        await cartCollection.add({
          'itemLabel': itemLabel,
          'itemSize': itemSize,
          ...updates,
        });
      }
    }
  }

  void handleCheckboxChanged(bool? value, String itemLabel, String? itemSize) {
    if (mounted) {
      setState(() {
        if (value == true) {
          selectedItems.add(itemLabel.hashCode); // or some unique identifier
        } else {
          selectedItems.remove(itemLabel.hashCode);
        }
        updateCartItem(itemLabel, itemSize, {'selected': value});
      });
    }
  }

  void handleQuantityChanged(String itemLabel, String? itemSize, int quantity) async {
    if (quantity < 1) return; // Ensure quantity doesn't go below 1

    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final cartCollection = firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart');

      final querySnapshot = await cartCollection
          .where('itemLabel', isEqualTo: itemLabel)
          .where('itemSize', isEqualTo: itemSize)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docRef = querySnapshot.docs.first.reference;
        await docRef.update({'quantity': quantity});

        setState(() {
          cartItems = cartItems.map((item) {
            if (item.itemLabel == itemLabel && item.selectedSize == itemSize) {
              item.quantity = quantity;
            }
            return item;
          }).toList();
        });
      }
    }
  }

  void handleSizeChanged(String itemLabel, String? size) {
    updateCartItem(itemLabel, size, {'itemSize': size});
  }

  void handleSelectAllChanged(bool? value) {
    if (mounted) {
      setState(() {
        selectAll = value ?? false;
        if (selectAll) {
          selectedItems = cartItems.map((item) => item.itemLabel.hashCode).toSet();
          for (var item in cartItems) {
            updateCartItem(item.itemLabel, item.selectedSize, {'selected': true});
          }
        } else {
          selectedItems.clear();
          for (var item in cartItems) {
            updateCartItem(item.itemLabel, item.selectedSize, {'selected': false});
          }
        }
      });
    }
  }

  void handleCheckout() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final cartCollection = firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart');

      final ordersCollection = firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders');

      final WriteBatch batch = firestore.batch();

      for (CartItem item in cartItems) {
        if (item.selected) {
          // Query the document using the itemLabel and itemSize as fields, not as a document ID
          final querySnapshot = await cartCollection
              .where('itemLabel', isEqualTo: item.itemLabel)
              .where('itemSize', isEqualTo: item.selectedSize)
              .limit(1)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            final cartDocRef = querySnapshot.docs.first.reference;

            // Update the status in the cart collection (optional, depending on your use case)
            batch.update(cartDocRef, {'status': 'bought'});

            // Add the item to the orders collection
            final orderDocRef = ordersCollection.doc();
            batch.set(orderDocRef, {
              'itemLabel': item.itemLabel,
              'itemSize': item.selectedSize ?? '', // Handle null sizes
              'imagePath': item.imagePath,
              'price': item.price,
              'quantity': item.quantity,
              'orderDate': FieldValue.serverTimestamp(),
            });

            // Remove the item from the cart collection
            batch.delete(cartDocRef);

            // Send a notification for each item checked out
            await notificationService.showNotification(
              user.uid,   // User ID for notification
              item.itemLabel.hashCode, // Notification ID can be item-specific
              'Item Purchased',
              'Your purchase for ${item.itemLabel} has been successfully processed.',
            );
          } else {
            print("Document with itemLabel ${item.itemLabel} and size ${item.selectedSize} not found in the cart collection.");
          }
        }
      }

      try {
        await batch.commit(); // Commit the batch operation (update, add, delete)
        print("Checked out items successfully and removed from cart.");
      } catch (e) {
        print("Failed to complete batch operation: $e");
      }
    } else {
      print("User not logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: Color(0xFF046be0),
      ),
      body: StreamBuilder<List<CartItem>>(
        stream: cartItemsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No items in the cart.'));
          }

          final cartItems = snapshot.data!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: selectAll,
                      onChanged: handleSelectAllChanged,
                    ),
                    Text(
                      'Select All',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    return buildCartItem(cartItems[index]);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: handleCheckout,
                  child: Text('Checkout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFEB3B),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: TextStyle(
                      fontSize: 18,
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

  Widget buildCartItem(CartItem item) {
    final int totalPrice = item.price * item.quantity; // Ensure this is an int

    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Checkbox(
              value: selectedItems.contains(item.itemLabel.hashCode),
              onChanged: (bool? value) {
                handleCheckboxChanged(value, item.itemLabel, item.selectedSize);
              },
            ),
            Image.asset(
              item.imagePath,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemLabel,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Size: ${item.selectedSize ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₱$totalPrice',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: item.quantity > 1
                                ? () {
                              handleQuantityChanged(item.itemLabel, item.selectedSize, item.quantity - 1);
                            }
                                : null,
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              handleQuantityChanged(item.itemLabel, item.selectedSize, item.quantity + 1);
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
