import 'package:flutter/material.dart';
import 'package:UNISTOCK/pages/CartPage.dart';
import 'package:UNISTOCK/pages/DetailSelection.dart';

class MerchAccessoriesPage extends StatefulWidget {
  @override
  _MerchAccessoriesPageState createState() => _MerchAccessoriesPageState();
}

class _MerchAccessoriesPageState extends State<MerchAccessoriesPage> {
  String selectedSortOption = 'Sort by';
  List<Map<String, dynamic>> items = [
    {
      'imagePath': 'assets/images/clothing1.png',
      'label': '40th STI Anniversary Oversized Shirt',
      'price': 340,
    },
    {
      'imagePath': 'assets/images/clothing2.png',
      'label': 'STI 39th Anniversary Shirt (Blue)',
      'price': 195,
    },
    {
      'imagePath': 'assets/images/clothing3.png',
      'label': 'STI 39th Anniversary Shirt (Yellow)',
      'price': 195,
    },
    {
      'imagePath': 'assets/images/waterbottle.png',
      'label': 'Water Bottle',
      'price': 50,
    },
    {
      'imagePath': 'assets/images/wearablepins.png',
      'label': 'Wearable Pin',
      'price': 20,
    },
    {
      'imagePath': 'assets/images/lacesC.png',
      'label': 'Laces',
      'price': 15,
    },
    {
      'imagePath': 'assets/images/lacesSHS.png',
      'label': 'Laces',
      'price': 15,
    },
    {
      'imagePath': 'assets/images/38thanniversary.png',
      'label': 'Grit (STI 38th Anniversary) Shirt',
      'price': 195,
    },
    {
      'imagePath': 'assets/images/STI Facemask.png',
      'label': 'STI Face Mask',
      'price': 30,
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
                      selectedSortOption = result;
                      sortItems(result);
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
                      const PopupMenuItem<String>(
                        value: 'Sort by date',
                        child: Text('Sort by date'),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              buildItemGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItemGrid(BuildContext context) {
    List<Widget> itemRows = [];
    for (int i = 0; i < items.length; i += 2) {
      itemRows.add(buildItemRow(
        context,
        items[i]['imagePath'],
        items[i]['label'],
        items[i]['price'],
        i + 1 < items.length ? items[i + 1]['imagePath'] : '',
        i + 1 < items.length ? items[i + 1]['label'] : '',
        i + 1 < items.length ? items[i + 1]['price'] : 0,
      ));
    }
    return Column(children: itemRows);
  }

  Widget buildItemRow(BuildContext context, String imagePath1, String label1,
      int price1, String imagePath2, String label2, int price2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildItemList(context, imagePath1, label1, price1),
        if (imagePath2.isNotEmpty)
          buildItemList(context, imagePath2, label2, price2),
      ],
    );
  }

  Widget buildItemList(
      BuildContext context, String imagePath, String label, int price) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailSelection(
                itemLabel: label,
                itemSize: '', // Default size or adjust as needed
                imagePath: imagePath,
                price: price,
                quantity: 1, // Default quantity
              ),
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailSelection(
                      itemLabel: label,
                      itemSize: '', // Default size or adjust as needed
                      imagePath: imagePath,
                      price: price,
                      quantity: 1, // Default quantity
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      imagePath,
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.width * 0.4,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
            ),
          ),
        ),
      ),
    );
  }
}
