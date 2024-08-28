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
  List<CartItem> cartItems = []; // Cache cart items

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
          .map((snapshot) =>
          snapshot.docs.map((doc) {
            final data = doc.data();
            return CartItem.fromFirestore(doc);
          }).toList());
      cartItemsStream.listen((items) {
        setState(() {
          cartItems = items;
          // Sync selectedItems with the updated cartItems
          if (selectAll) {
            selectedItems = cartItems.map((item) => item.itemLabel.hashCode).toSet();
          } else {
            selectedItems = cartItems.where((item) => item.selected).map((item) => item.itemLabel.hashCode).toSet();
          }
        });
      });
    } else {
      cartItemsStream = Stream.value([]);
    }
  }

  Future<void> updateCartItemByLabel(String itemLabel,
      Map<String, dynamic> updates) async {
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
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          await doc.reference.set(updates, SetOptions(merge: true));
        }
      } else {
        await cartCollection.add({
          'itemLabel': itemLabel,
          ...updates
        });
      }
    }
  }

  void handleCheckboxChanged(bool? value, String itemLabel) {
    setState(() {
      if (value == true) {
        selectedItems.add(itemLabel.hashCode); // or some unique identifier
      } else {
        selectedItems.remove(itemLabel.hashCode);
      }
      updateCartItemByLabel(itemLabel, {'selected': value});
    });
  }

  void handleQuantityChanged(String itemLabel, int quantity) {
    setState(() {
      updateCartItemByLabel(itemLabel, {'quantity': quantity});
    });
  }

  void handleSizeChanged(String itemLabel, String? size) {
    updateCartItemByLabel(itemLabel, {'itemSize': size});
  }

  void handleSelectAllChanged(bool? value) {
    setState(() {
      selectAll = value ?? false;
      if (selectAll) {
        selectedItems = cartItems.map((item) => item.itemLabel.hashCode).toSet();
        for (var item in cartItems) {
          updateCartItemByLabel(item.itemLabel, {'selected': true});
        }
      } else {
        selectedItems.clear();
        for (var item in cartItems) {
          updateCartItemByLabel(item.itemLabel, {'selected': false});
        }
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
    final totalPrice = item.price * item.quantity;

    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Checkbox(
              value: selectedItems.contains(item.itemLabel.hashCode),
              onChanged: (bool? value) {
                handleCheckboxChanged(value, item.itemLabel);
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
                        '₱${totalPrice}',
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
                              handleQuantityChanged(item.itemLabel, item.quantity - 1);
                            }
                                : null,
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              handleQuantityChanged(item.itemLabel, item.quantity + 1);
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
  final String itemLabel;
  final String imagePath;
  final List<String> availableSizes;
  String? selectedSize;
  final int price;
  int quantity;
  bool selected; // Added field

  CartItem({
    required this.itemLabel,
    required this.imagePath,
    required this.availableSizes,
    this.selectedSize,
    required this.price,
    this.quantity = 1,
    this.selected = false, // Default to false
  });

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItem(
      itemLabel: data['itemLabel'] ?? 'Unknown',
      imagePath: data['imagePath'] ?? 'assets/images/placeholder.png',
      availableSizes: List<String>.from(data['availableSizes'] ?? []),
      selectedSize: data['itemSize'] as String?,
      price: data['price'] ?? 0,
      quantity: data['quantity'] ?? 1,
      selected: data['selected'] ?? false, // Default to false
    );
  }
}
