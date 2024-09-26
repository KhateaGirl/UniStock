import 'package:UNISTOCK/ProfileInfo.dart';
import 'package:UNISTOCK/pages/CartPage.dart';
import 'package:UNISTOCK/pages/DetailSelection.dart';
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
  bool _isLoading = true; // To indicate loading data

  @override
  void initState() {
    super.initState();
    fetchUniformItems(); // Fetch items from Firestore
  }

  // Fetch items from Firestore based on courseLabel
  Future<void> fetchUniformItems() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Inventory_stock')
          .doc('college_items')
          .collection(widget.courseLabel)
          .get();

      setState(() {
        uniformItems = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'label': doc['label'],
            'price': (doc['price'] is double) ? (doc['price'] as double).toInt() : (doc['price'] as int),
            'imagePath': doc['imageUrl'] ?? '',
          };
        }).toList();
        _isLoading = false; // Data loaded
      });
    } catch (e) {
      print('Error fetching items: $e');
      setState(() {
        _isLoading = false; // Stop loading even on failure
      });
    }
  }

  // Sort items logic
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
        if (item['imagePath'] == '' || item['price'] == 0) {
          return buildSoldOutItem();
        } else {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailSelection(
                    itemLabel: item['label'],
                    itemSize: item['size'], // Pass the size if applicable
                    imagePath: item['imagePath'],
                    price: item['price'], // Pass price as an integer
                    quantity: 1, // Set default quantity to 1
                    currentProfileInfo: widget.currentProfileInfo,
                  ),
                ),
              );
            },
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.network(
                      item['imagePath'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    item['label'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₱${item['price'].toString()}', // Display price as string
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget buildSoldOutItem() {
    return GestureDetector(
      onTap: () {
        // Handle tap on sold-out items
      },
      child: Card(
        color: Colors.grey[300],
        child: Center(
          child: Text(
            'SOLD OUT',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
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
