import 'package:UNISTOCK/services/DetailSelectionCOL.dart';
import 'package:UNISTOCK/ProfileInfo.dart';
import 'package:UNISTOCK/pages/CartPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CollegeUniSelectionPage extends StatefulWidget {
  final String courseLabel;
  final ProfileInfo currentProfileInfo;

  CollegeUniSelectionPage({
    required this.currentProfileInfo,
    required this.courseLabel,
  });

  @override
  _CollegeUniSelectionPageState createState() =>
      _CollegeUniSelectionPageState();
}

class _CollegeUniSelectionPageState extends State<CollegeUniSelectionPage> {
  String selectedSortOption = 'Sort by';
  List<Map<String, dynamic>> uniformItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUniformItems();
  }

  Future<void> fetchUniformItems() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Inventory_stock')
          .doc('college_items')
          .collection(widget.courseLabel)
          .get();

      setState(() {
        uniformItems = querySnapshot.docs.map((doc) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

          if (data != null) {
            int? price = data['price'] != null ? (data['price'] is double ? (data['price'] as double).toInt() : data['price']) : null;

            return {
              'id': doc.id,
              'label': data['label'] ?? 'Unknown Label',
              'price': price,
              'imagePath': data['imageUrl'] ?? '',
              'sizes': data.containsKey('sizes') ? data['sizes'] : {},
            };
          } else {
            return {
              'id': doc.id,
              'label': 'Unknown Label',
              'price': null,
              'imagePath': '',
              'sizes': {},
            };
          }
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void sortItems(String sortBy) {
    setState(() {
      if (sortBy == 'Sort by price ascending') {
        uniformItems.sort((a, b) => a['price'].compareTo(b['price']));
      } else if (sortBy == 'Sort by price descending') {
        uniformItems.sort((a, b) => b['price'].compareTo(a['price']));
      }
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Select your items for ${widget.courseLabel}',
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
                    'Sort and Filter',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.sort),
                    onSelected: (String result) {
                      setState(() {
                        selectedSortOption = result;
                        sortItems(result);
                      });
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
              buildItemGrid(context),
              SizedBox(height: 16),
              buildNoSizeOption(context, 'No possible size?'),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItemGrid(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: uniformItems.length,
      itemBuilder: (context, index) {
        final item = uniformItems[index];
        final String imagePath = item['imagePath'] ?? '';
        final String label = item['label'] ?? 'No Label Available';
        final int? price = item['price'];

        if (imagePath.isEmpty && price == null) {
          return buildSoldOutItem(label);
        } else {
          return buildItem(
            context,
            item['id'],
            imagePath,
            label,
            price,
          );
        }
      },
    );
  }

  Widget buildItem(BuildContext context, String id, String imagePath,
      String label, int? price) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailSelectionCOL(
              itemId: id,
              courseLabel: widget.courseLabel,
              label: label,
              itemSize: null,
              imagePath: imagePath,
              price: price ?? 0,
              quantity: 1,
              currentProfileInfo: widget.currentProfileInfo,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: imagePath.isNotEmpty
                  ? Image.network(
                imagePath,
                fit: BoxFit.contain,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        'Image not available',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              )
                  : Container(
                color: Colors.grey[300],
                child: Center(
                  child: Text(
                    'Image not available',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 4),
            Text(
              price != null && price > 0 ? '₱$price' : '₱',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget buildSoldOutItem(String label) {
    return Card(
      color: Colors.grey[300],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: Center(
                child: Text(
                  'Image not available',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Price not available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }


  Widget buildNoSizeOption(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}
