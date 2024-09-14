import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:UNISTOCK/pages/CartPage.dart';
import 'package:UNISTOCK/pages/NotificationPage.dart';
import 'package:UNISTOCK/ProfileInfo.dart';

class HomePage extends StatefulWidget {
  final ProfileInfo profileInfo;
  final List<String> imagePaths;
  final List<Map<String, dynamic>> navigationItems;

  HomePage({
    required this.profileInfo,
    required this.imagePaths,
    required this.navigationItems,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;  // Keep track of the current index for PageView

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF046be0),
        automaticallyImplyLeading: false,
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
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsPage(userId: widget.profileInfo.userId),
                ),
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
                    Container(
                      height: 200,  // Adjust height as needed
                      child: PageView.builder(
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;  // Update current index when the page changes
                          });
                        },
                        itemCount: widget.imagePaths.length,
                        itemBuilder: (context, index) {
                          return Container(
                            child: Center(
                              child: Image.asset(
                                widget.imagePaths[index],
                                fit: BoxFit.cover,
                                width: 1000,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    DotsIndicator(
                      dotsCount: widget.imagePaths.length,
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
                children: widget.navigationItems
                    .map((item) => Expanded(
                  flex: 1,
                  child: buildBottomNavItem(
                      item['icon'], item['label'], item['onPressed']),
                ))
                    .toList(),
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
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
