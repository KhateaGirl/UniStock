import 'package:UNISTOCK/ProfileInfo.dart';
import 'package:UNISTOCK/pages/MerchAccessoriesPage.dart';
import 'package:UNISTOCK/pages/ProfilePage.dart';
import 'package:UNISTOCK/pages/Uniform_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:UNISTOCK/pages/home_page.dart';
import 'package:UNISTOCK/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:UNISTOCK/services/register.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Authservice _auth = Authservice();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(); // Initialize Firebase
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF046be0),
      body: Center(
        child: SingleChildScrollView( // Wrap with SingleChildScrollView to prevent overflow
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Arial',
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'UNI',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'STOCK',
                      style: TextStyle(color: Color(0xFFFFEB3B)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: _studentIdController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: Colors.white),
                obscureText: true,
              ),
              SizedBox(height: 40),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () {
                  _login(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.yellow,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text('Login'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _studentIdController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          ProfileInfo profileInfo = ProfileInfo.fromDocumentSnapshot(
              userDoc.data() as Map<String, dynamic>);

          final navigationItems = [
            {
              'icon': Icons.inventory,
              'label': 'Uniform',
              'onPressed': () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          UniformPage(currentProfileInfo: profileInfo)),
                );
              }
            },
            {
              'icon': Icons.shopping_bag,
              'label': 'Merch/Accessories',
              'onPressed': () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MerchAccessoriesPage(currentProfileInfo: profileInfo)),
                );
              }
            },
            {
              'icon': Icons.account_circle,
              'label': 'Profile',
              'onPressed': () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(profileInfo: profileInfo),
                  ),
                );
              }
            },
          ];

          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => HomePage(
                profileInfo: profileInfo,
                navigationItems: navigationItems,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset(0.0, 0.0);
                const curve = Curves.ease;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User profile does not exist.')),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Login Error'),
            content: Text('Unknown error occurred'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
