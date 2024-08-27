import 'package:flutter/material.dart';
import 'package:UNISTOCK/pages/home_page.dart';
import 'package:UNISTOCK/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Authservice _auth = Authservice();
  final String _validStudentId = 'student123';
  final String _validPassword = 'password123';

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
        child: Padding(
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
                  labelText: 'Student ID',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
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
              ElevatedButton(
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
                onPressed: () async {
                  User? user = await _auth.signInAnon();
                  if (user == null) {
                    print('Error signing in');
                  } else {
                    print('Signed in as guest: ${user.uid}');
                    _loginAsGuest(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text('Guest'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context) {
    // Check if the credentials are valid
    if (_studentIdController.text == _validStudentId &&
        _passwordController.text == _validPassword) {
      // Navigate to HomePage with a slide transition
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset(0.0, 0.0);
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    } else {
      // Show an error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Invalid Student ID or Password'),
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
    }
  }

  void _loginAsGuest(BuildContext context) {
    // Logic for guest login (you can customize this as needed)
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset(0.0, 0.0);
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
