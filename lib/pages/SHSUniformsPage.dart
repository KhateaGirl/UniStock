import 'package:UNISTOCK/ProfileInfo.dart';
import 'package:flutter/material.dart';
import 'package:UNISTOCK/pages/CartPage.dart';
import 'package:UNISTOCK/pages/DetailSelection.dart';

class SHSUniformsPage extends StatefulWidget {
  final ProfileInfo currentProfileInfo;

  SHSUniformsPage({required this.currentProfileInfo});
  @override
  _SHSUniformsPageState createState() => _SHSUniformsPageState();
}

class _SHSUniformsPageState extends State<SHSUniformsPage> {
  String selectedSortOption = 'Sort by';

  List<Map<String, dynamic>> items = [
    {
      'id': 'SHS_APRON',
      'category': 'clothing',
      'imagePath': 'assets/images/SHS_APRON.png',
      'label': 'SHS APRON',
      'price': 120,
    },
    {
      'id': 'SHS_PANTS',
      'category': 'clothing',
      'imagePath': 'assets/images/SHS_PANTS.png',
      'label': 'SHS PANTS',
      'price': 200,
    },
    {
      'id': 'SHS_NECKTIE',
      'category': 'accessory',
      'imagePath': 'assets/images/SHS_NECKTIE.png',
      'label': 'SHS NECKTIE',
      'price': 50,
    },
    {
      'id': 'SHS_BLOUSE_WITH_VEST',
      'category': 'clothing',
      'imagePath': 'assets/images/SHS_BLOUSE_WITH_VEST.png',
      'label': 'Blouse with Vest',
      'price': 180,
    },
    {
      'id': 'SHS_SKIRT',
      'category': 'clothing',
      'imagePath': 'assets/images/SHS_SKIRT.png',
      'label': 'SHS Skirt',
      'price': 150,
    },
    {
      'id': 'STI_WHITE_CHEF_LONG_SLEEVE_BLOUSE',
      'category': 'clothing',
      'imagePath': 'assets/images/STI_WHITE_CHEF_LONG_SLEEVE_BLOUSE.png',
      'label': 'STI Chef\'s Blouse',
      'price': 300,
    },
    {
      'id': 'STI_LONG_CHECKERED_PANTS',
      'category': 'clothing',
      'imagePath': 'assets/images/STI_LONG_CHECKERED_PANTS.png',
      'label': 'STI Checkered Pants',
      'price': 220,
    },
    {
      'id': 'SHS_PE_PANTS',
      'category': 'clothing',
      'imagePath': 'assets/images/SHS_PE_PANTS.png',
      'label': 'SHS PE PANTS',
      'price': 180,
    },
    {
      'id': 'SHS_PE_SHIRT',
      'category': 'clothing',
      'imagePath': 'assets/images/SHS_PE_SHIRT.png',
      'label': 'SHS PE SHIRT',
      'price': 160,
    },
    {
      'id': 'STI_CHECKERED_BEANIE',
      'category': 'accessory',
      'imagePath': 'assets/images/STI_CHECKERED_BEANIE.png',
      'label': 'STI Checkered Beanie',
      'price': 80,
    },
    {
      'id': 'SHS_WASHDAY',
      'category': 'clothing',
      'imagePath': 'assets/images/SHS_WASHDAY.png',
      'label': 'SHS Washday',
      'price': 90,
    },
    {
      'id': 'SHS_POLO_WITH_VEST',
      'category': 'clothing',
      'imagePath': 'assets/images/SHS_POLO_WITH_VEST.png',
      'label': 'Polo with Vest',
      'price': 210,
    },
  ];

  void sortItems(String sortBy) {
    setState(() {
      if (sortBy == 'Sort by price ascending') {
        items.sort((a, b) => a['price'].compareTo(b['price']));
      } else if (sortBy == 'Sort by price descending') {
        items.sort((a, b) => b['price'].compareTo(a['price']));
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
                'SHS Uniforms',
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
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return buildItem(
          context,
          item['id'],
          item['imagePath'],
          item['label'],
          '₱${item['price']}',
          item['category'],
        );
      },
    );
  }

  Widget buildItem(BuildContext context, String id, String imagePath,
      String label, String price, String category) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailSelection(
              itemLabel: label,
              itemSize: category == 'clothing' ? '' : null,
              imagePath: imagePath,
              price: int.parse(price.substring(1)), // Remove ₱ and parse int
              quantity: 1,
              currentProfileInfo: widget.currentProfileInfo, // Pass the profile info
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                price,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNoSizeOption(BuildContext context, String label) {
    return Column(
      children: [
        SizedBox(height: 16.0),
        ExpansionTile(
          title: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          children: [
            GestureDetector(
              onTap: () {
                // Handle fabric button click
              },
              child: Container(
                padding: EdgeInsets.all(12.0),
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Fabric',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.0),
      ],
    );
  }
}
