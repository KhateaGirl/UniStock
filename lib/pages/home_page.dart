import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:UNISTOCK/pages/CartPage.dart';
import 'package:UNISTOCK/pages/NotificationPage.dart';
import 'package:UNISTOCK/pages/ProfilePage.dart';
import 'package:UNISTOCK/Profileinfo.dart';
import 'package:UNISTOCK/pages/MerchAccessoriesPage.dart'; // Import the MerchAccessoriesPage
import 'uniform_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<String> imgList = [
    'assets/images/sti announcement 1.png',
    'assets/images/sti announcement 2.png',
    'assets/images/sti announcement 3.png',
  ];

  final ProfileInfo profileInfo = ProfileInfo(
    name: 'John Doe',
    studentId: '123456789',
    contactNumber: '123-456-7890',
    email: 'john.doe@example.com',
    address: '123 Main St, City, Country',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF046be0),
        automaticallyImplyLeading: false, // Removes the back button
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
              color: Colors.white, // Text color set to white
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
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
          ),
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
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        aspectRatio: 2.0,
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                      ),
                      items: imgList
                          .map((item) => Container(
                                child: Center(
                                  child: Image.asset(item,
                                      fit: BoxFit.cover, width: 1000),
                                ),
                              ))
                          .toList(),
                    ),
                    DotsIndicator(
                      dotsCount: imgList.length,
                      position: _currentIndex.toDouble(),
                      decorator: DotsDecorator(
                        activeColor: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 16),
                    Divider(
                      color: Colors.grey,
                      height: 1,
                      thickness: 1,
                    ),
                    SizedBox(height: 16),
                    // Placeholder for announcements and restrictions
                    Container(
                      width: double.infinity,
                      height: 150,
                      color: Colors.grey[200],
                      child: Center(
                        child: Text(
                          'Announcements and Restrictions',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.grey,
            height: 1,
            thickness: 1,
          ),
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: buildBottomNavItem(Icons.inventory, 'Uniform', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UniformPage()),
                      );
                    }),
                  ),
                  Expanded(
                    flex: 1,
                    child: buildBottomNavItem(
                        Icons.shopping_bag, 'Merch/Accessories', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MerchAccessoriesPage()),
                      );
                    }),
                  ),
                  Expanded(
                    flex: 1,
                    child:
                        buildBottomNavItem(Icons.account_circle, 'Profile', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(
                            profileInfo: profileInfo,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomNavItem(
      IconData icon, String categoryName, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.blue,
              size: 28,
            ),
          ),
          SizedBox(height: 4),
          Text(
            categoryName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black, // Adjust text color here
            ),
          ),
        ],
      ),
    );
  }
}
