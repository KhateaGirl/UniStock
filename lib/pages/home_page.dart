import 'package:UNISTOCK/screensize.dart';
import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:UNISTOCK/pages/CartPage.dart';
import 'package:UNISTOCK/pages/NotificationPage.dart';
import 'package:UNISTOCK/ProfileInfo.dart';
import 'package:UNISTOCK/screen_breakpoint.dart';

class HomePage extends StatefulWidget {
  final ProfileInfo profileInfo;
  final List<Map<String, dynamic>> navigationItems;

  HomePage({
    required this.profileInfo,
    required this.navigationItems,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;  // Keep track of the current index for PageView
  List<String> _imageUrls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnnouncementImages();
  }

  // Fetch announcement image URLs from Firestore
  Future<void> _fetchAnnouncementImages() async {
    try {
      String adminDocumentId = 'ZmjXRodEmi3LOaYA10tH';  // Adjust this if necessary

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('admin')
          .doc(adminDocumentId)
          .collection('announcements')
          .get();

      List<String> urls = snapshot.docs.map((doc) {
        return doc['image_url'] as String;
      }).toList();

      setState(() {
        _imageUrls = urls;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching announcements: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobileDevice;
    final bool isTablet = context.isTabletDevice;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF046be0),
        automaticallyImplyLeading: false,
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: isMobile ? 20.0 : 24.0,
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
            icon: Icon(Icons.notifications, color: Colors.white, size: isMobile ? 20.0 : 24.0),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NotificationsPage(userId: widget.profileInfo.userId),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white, size: isMobile ? 20.0 : 24.0),
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
          ? Center(child: CircularProgressIndicator()) // Loading indicator while fetching data
          : Column(
        children: <Widget>[
          // PageView for Announcements
          Container(
            height: isMobile
                ? MediaQuery.of(context).size.height * 0.25
                : MediaQuery.of(context).size.height * 0.3, // Adjust height based on screen size
            width: double.infinity,
            child: _imageUrls.isNotEmpty
                ? PageView.builder(
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index; // Update current index when the page changes
                });
              },
              itemCount: _imageUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  child: Image.network(
                    _imageUrls[index],
                    fit: BoxFit.cover, // Make the image cover the entire container
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 50),
                          Text('Image failed to load'),
                        ],
                      );
                    },
                  ),
                );
              },
            )
                : Center(child: Text('No announcements available')),
          ),
          // Dots Indicator for PageView
          if (_imageUrls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DotsIndicator(
                dotsCount: _imageUrls.length,
                position: _currentIndex.toDouble(),
                decorator: DotsDecorator(
                  activeColor: Colors.blue,
                  size: isMobile ? Size(6.0, 6.0) : Size(8.0, 8.0),
                  activeSize: isMobile ? Size(10.0, 10.0) : Size(12.0, 12.0),
                ),
              ),
            ),
          SizedBox(height: isMobile ? 8 : 10),
          Divider(
            color: Colors.grey,
            height: 1,
            thickness: 1,
          ),
          Container(
            width: double.infinity,
            height: isMobile ? 150 : 250,
            color: Colors.grey[200],
            child: Center(
              child: Text(
                'Announcements and Restrictions',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          SizedBox(height: isMobile ? 20 : 50),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // Pushes the navigation items to the bottom
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0), // Add space between previous content
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: widget.navigationItems
                          .map((item) => Flexible(
                        flex: 1,
                        child: buildBottomNavItem(
                            item['icon'], item['label'], item['onPressed'], isMobile),
                      ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            )

          ),
        ],
      ),
    );
  }

  Widget buildBottomNavItem(
      IconData icon, String categoryName, VoidCallback onPressed, bool isMobile) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.blue,
              size: isMobile ? 24 : 28,
            ),
          ),
          SizedBox(height: isMobile ? 2 : 4),
          Text(
            categoryName,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
