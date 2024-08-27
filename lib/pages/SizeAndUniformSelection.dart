import 'package:flutter/material.dart';
import 'package:UNISTOCK/pages/DetailSelection.dart';
import 'package:UNISTOCK/pages/CartPage.dart';

class CollegeUniSelectionPage extends StatefulWidget {
  final String courseLabel;

  CollegeUniSelectionPage({required this.courseLabel});

  @override
  _CollegeUniSelectionPageState createState() =>
      _CollegeUniSelectionPageState();
}

class _CollegeUniSelectionPageState extends State<CollegeUniSelectionPage> {
  String selectedSortOption = 'Sort by';
  List<Map<String, dynamic>> uniformItems = [];

  @override
  void initState() {
    super.initState();
    uniformItems = getUniformItems();
  }

  List<Map<String, dynamic>> getUniformItems() {
    switch (widget.courseLabel) {
      case 'IT&CPE':
        return [
          {
            'id': 'IT_BLAZER',
            'imagePath': 'assets/images/IT_BLAZER.png',
            'label': 'IT 3/4 Blouse',
            'price': 1000
          },
          {
            'id': 'IT_POLO',
            'imagePath': 'assets/images/IT_POLO.png',
            'label': 'IT 3/4 Polo',
            'price': 800
          },
          {
            'id': 'MALE_BLAZER',
            'imagePath': 'assets/images/IT_BLAZER.png',
            'label': 'Male Blazer',
            'price': 1200
          },
          {
            'id': 'FEMALE_BLAZER',
            'imagePath': 'assets/images/IT_BLAZER.png',
            'label': 'Female Blazer',
            'price': 1200
          },
        ];
      case 'HRM & Culinary':
        return [
          {
            'id': 'BLOUSE',
            'imagePath': 'assets/images/SHS_BLOUSE_WITH_VEST.png',
            'label': 'Blouse',
            'price': 950
          },
          {
            'id': 'POLO',
            'imagePath': 'assets/images/SHS_POLO_WITH_VEST.png',
            'label': 'Polo',
            'price': 850
          },
          {
            'id': 'CHEF_POLO',
            'imagePath': 'assets/images/STI_WHITE_CHEF_LONG_SLEEVE_BLOUSE.png',
            'label': 'Chef\'s Polo',
            'price': 1000
          },
          {
            'id': 'CHEF_PANTS',
            'imagePath': 'assets/images/STI_LONG_CHECKERED_PANTS.png',
            'label': 'Chef Pants',
            'price': 900
          },
          {
            'id': 'VEST_FEMALE',
            'imagePath': '',
            'label': 'Vest Female',
            'price': 0
          },
          {
            'id': 'VEST_MALE',
            'imagePath': '',
            'label': 'Vest Male',
            'price': 0
          },
        ];
      case 'Tourism':
        return [
          {
            'id': 'FEMALE_BLOUSE',
            'imagePath': 'assets/images/SHS_BLOUSE_WITH_VEST.png',
            'label': 'Female Blouse',
            'price': 950
          },
          {
            'id': 'MALE_POLO',
            'imagePath': 'assets/images/SHS_POLO_WITH_VEST.png',
            'label': 'Male Polo',
            'price': 850
          },
          {
            'id': 'FEMALE_BLAZER',
            'imagePath': 'assets/images/IT_BLAZER.png',
            'label': 'Female Blazer',
            'price': 1200
          },
          {
            'id': 'SKIRT',
            'imagePath': 'assets/images/SHS_SKIRT.png',
            'label': 'Skirt',
            'price': 700
          },
          {
            'id': 'CLOTH_PANTS',
            'imagePath': 'assets/images/SHS_PANTS.png',
            'label': 'Cloth Pants',
            'price': 800
          },
          {
            'id': 'TOURISM_BERET',
            'imagePath': '',
            'label': 'Tourism Beret',
            'price': 0
          },
          {
            'id': 'TOURISM_PIN',
            'imagePath': '',
            'label': 'Tourism Pin',
            'price': 0
          },
          {
            'id': 'NECKTIE',
            'imagePath': 'assets/images/SHS_NECKTIE.png',
            'label': 'Necktie',
            'price': 300
          },
          {'id': 'SCARF', 'imagePath': '', 'label': 'Scarf', 'price': 0},
        ];
      case 'BM/AB COMM':
        return [
          {
            'id': 'BLOUSE',
            'imagePath': 'assets/images/SHS_BLOUSE_WITH_VEST.png',
            'label': 'Blouse',
            'price': 950
          },
          {
            'id': 'POLO',
            'imagePath': 'assets/images/SHS_POLO_WITH_VEST.png',
            'label': 'Polo',
            'price': 850
          },
          {
            'id': 'BM_NECKTIE',
            'imagePath': 'assets/images/SHS_NECKTIE.png',
            'label': 'BM Necktie',
            'price': 300
          },
          {'id': 'BM_SCARF', 'imagePath': '', 'label': 'BM Scarf', 'price': 0},
          {
            'id': 'AB_COMM_NECKTIE',
            'imagePath': '',
            'label': 'AB COMM Necktie',
            'price': 0
          },
          {
            'id': 'AB_COMM_SCARF',
            'imagePath': '',
            'label': 'AB COMM Scarf',
            'price': 0
          },
        ];
      case 'BACOMM':
        return [
          {
            'id': 'BLOUSE',
            'imagePath': 'assets/images/SHS_BLOUSE_WITH_VEST.png',
            'label': 'Blouse',
            'price': 950
          },
          {
            'id': 'POLO',
            'imagePath': 'assets/images/SHS_POLO_WITH_VEST.png',
            'label': 'Polo',
            'price': 850
          },
          {
            'id': 'BM_NECKTIE',
            'imagePath': 'assets/images/SHS_NECKTIE.png',
            'label': 'BM Necktie',
            'price': 300
          },
          {'id': 'BM_SCARF', 'imagePath': '', 'label': 'BM Scarf', 'price': 0},
        ];
      default:
        return [];
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
      body: SingleChildScrollView(
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
          // Item is sold out or has no image
          return buildSoldOutItem();
        } else {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailSelection(
                    itemLabel: item['label'],
                    itemSize: item[
                        'size'], // Pass this if available, otherwise set it to null
                    imagePath: item['imagePath'],
                    price: item['price'],
                    quantity: item['quantity'] ??
                        1, // Default to 1 if quantity is not available
                  ),
                ),
              );
            },
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.asset(item['imagePath'], fit: BoxFit.cover),
                  ),
                  Text(
                    item['label'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₱${item['price'].toStringAsFixed(2)}',
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
        // You can handle the tap on sold out items here if needed
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
