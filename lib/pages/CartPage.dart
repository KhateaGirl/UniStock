import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Stream<List<CartItem>> cartItemsStream;
  Set<int> selectedItems = {}; // Track selected item IDs
  bool selectAll = false; // Track "Select All" state

  @override
  void initState() {
    super.initState();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final User? user = auth.currentUser;

    if (user != null) {
      cartItemsStream = firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return CartItem.fromFirestore(doc);
      }).toList());
    } else {
      cartItemsStream = Stream.value([]);
    }
  }

  Future<void> updateCartItem(int id, Map<String, dynamic> updates) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final exists = await documentExists(user.uid, id);
      if (exists) {
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .doc(id.toString())
            .update(updates);
      } else {
        print('Document does not exist at path: users/${user.uid}/cart/$id');
      }
    }
  }

  Future<bool> documentExists(String userId, int id) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final doc = await firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(id.toString())
        .get();
    return doc.exists;
  }

  void handleCheckboxChanged(bool? value, int id) {
    setState(() {
      if (value == true) {
        selectedItems.add(id);
      } else {
        selectedItems.remove(id);
      }
    });
    updateCartItem(id, {'selected': value});
  }

  void handleQuantityChanged(int id, int quantity) {
    setState(() {
      updateCartItem(id, {'quantity': quantity});
    });
  }

  void handleSizeChanged(int id, String? size) {
    updateCartItem(id, {'itemSize': size});
  }

  void handleSelectAllChanged(bool? value) {
    setState(() {
      selectAll = value ?? false;
      selectedItems.clear();
      if (selectAll) {
        // Load cart items and mark all as selected
        cartItemsStream.listen((items) {
          for (var item in items) {
            selectedItems.add(item.id);
            updateCartItem(item.id, {'selected': true});
          }
        });
      } else {
        // Unselect all items
        cartItemsStream.listen((items) {
          for (var item in items) {
            updateCartItem(item.id, {'selected': false});
          }
        });
      }
    });
  }

  void handleCheckout() {
    print("Checked out items");
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
    // Calculate total price
    final totalPrice = item.price * item.quantity;

    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Checkbox(
              value: selectedItems.contains(item.id),
              onChanged: (bool? value) {
                handleCheckboxChanged(value, item.id);
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
                    item.label,
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
                        '₱${totalPrice}',  // Show total price here
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
                              handleQuantityChanged(item.id, item.quantity - 1);
                            }
                                : null,
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              handleQuantityChanged(item.id, item.quantity + 1);
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

class CartItem {
  final int id;
  final String label;
  final String imagePath;
  final List<String> availableSizes;
  String? selectedSize;
  final int price;
  int quantity;

  CartItem({
    required this.id,
    required this.label,
    required this.imagePath,
    required this.availableSizes,
    this.selectedSize,
    required this.price,
    this.quantity = 1,
  });

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: data['id'] ?? 0,
      label: data['itemLabel'] ?? 'Unknown',
      imagePath: data['imagePath'] ?? 'assets/images/placeholder.png',
      availableSizes: List<String>.from(data['availableSizes'] ?? []),
      selectedSize: data['itemSize'] as String?,
      price: data['price'] ?? 0,
      quantity: data['quantity'] ?? 1,
    );
  }
}
