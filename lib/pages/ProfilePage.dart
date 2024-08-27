import 'package:flutter/material.dart';
import 'package:UNISTOCK/pages/EditProfilePage.dart';
import 'package:UNISTOCK/Profileinfo.dart';
import 'package:UNISTOCK/login_screen.dart';
import 'package:UNISTOCK/pages/OrdersPage.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class ProfilePage extends StatefulWidget {
  final ProfileInfo profileInfo;

  ProfilePage({required this.profileInfo});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileInfo profileInfo;
  List<Order> orders = []; // List to store orders

  @override
  void initState() {
    super.initState();
    profileInfo = widget.profileInfo;
    // Mock data for orders (replace with actual data retrieval logic)
    orders = [
      Order(itemName: 'T-Shirt', quantity: 2, price: 250),
      Order(itemName: 'Hoodie', quantity: 1, price: 500),
    ];
  }

  void _editProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(profileInfo: profileInfo),
      ),
    );

    if (result != null && result is ProfileInfo) {
      setState(() {
        profileInfo = result;
      });
    }
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase

      // Show a SnackBar to notify the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have been logged out.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Delay navigation to give the SnackBar time to display
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    } catch (e) {
      print("Error signing out: $e"); // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _viewOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrdersPage(orders: orders),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF046be0),
        title: Text('Profile'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.description, color: Colors.white), // Paper icon
            onPressed: _viewOrders,
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/images/profilepict.png'),
              backgroundColor: Colors.grey[200],
            ),
            SizedBox(height: 20),
            Text(
              profileInfo.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Text(
              profileInfo.studentId,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 5),
            Text(
              profileInfo.contactNumber,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 20),
            Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.email, color: Color(0xFF046be0)),
              title: Text(
                'Email',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                profileInfo.email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.home, color: Color(0xFF046be0)),
              title: Text(
                'Address',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                profileInfo.address,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _logout,
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFEB3B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
