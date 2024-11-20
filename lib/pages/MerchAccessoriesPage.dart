import 'package:UNISTOCK/services/DetailSelectionMerch.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:UNISTOCK/pages/CartPage.dart';
import 'package:UNISTOCK/ProfileInfo.dart';

class MerchAccessoriesPage extends StatefulWidget {
  final ProfileInfo currentProfileInfo;

  MerchAccessoriesPage({required this.currentProfileInfo});

  @override
  _MerchAccessoriesPageState createState() => _MerchAccessoriesPageState();
}

class _MerchAccessoriesPageState extends State<MerchAccessoriesPage> {
  final List<String> itemsWithoutSizes = [
    'water bottle',
    'wearable pin',
    'sti face mask',
    'laces'
  ];

  String _sortOrder = 'asc';

  Stream<QuerySnapshot> _fetchMerchData() {
    return FirebaseFirestore.instance
        .collection('Inventory_stock')
        .doc('Merch & Accessories')
        .collection('items')
        .snapshots();
  }

  void _sortItems(List<Map<String, dynamic>> items) {
    items.sort((a, b) {
      int priceA = a['price'] ?? 0;
      int priceB = b['price'] ?? 0;
      return _sortOrder == 'asc' ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });
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
              Text(
                'Merch/Accessories',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter & Sort',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.sort),
                    onSelected: (String result) {
                      setState(() {
                        _sortOrder = result == 'Sort by price ascending' ? 'asc' : 'desc';
                      });
                    },
                    itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'Sort by price ascending',
                        child: Text('Sort by price ascending'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Sort by price descending',
                        child: Text('Sort by price descending'),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Inventory_stock')
                    .doc('Merch & Accessories')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var data = snapshot.data!.data() as Map<String, dynamic>;

                  var items = data.entries.map((entry) {
                    var itemData = entry.value as Map<String, dynamic>;
                    return {
                      'label': entry.key,
                      'imagePath': itemData['imagePath'] ?? '',
                      'price': itemData['price'] ?? 0,
                    };
                  }).toList();
                  _sortItems(items);
                  return buildItemGrid(context, items);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItemGrid(BuildContext context, List<Map<String, dynamic>> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.7,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return buildItemCard(context, item['imagePath'], item['label'], item['price']);
      },
    );
  }

  Widget buildItemCard(BuildContext context, String imagePath, String label, int price) {
    final bool requiresSizeSelection = !itemsWithoutSizes.contains(label.toLowerCase());

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailSelectionMerch(
              label: label,
              itemSize: requiresSizeSelection ? '' : null,
              imagePath: imagePath,
              price: price,
              quantity: 1,
              currentProfileInfo: widget.currentProfileInfo,
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: imagePath.isNotEmpty
                  ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                height: 100,
                width: double.infinity,
              )
                  : Container(
                height: 100,
                color: Colors.grey,
                child: Icon(Icons.image, color: Colors.white),
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '₱$price',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
