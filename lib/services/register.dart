import 'package:UNISTOCK/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for input formatters

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController studentId = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  bool _obscureText = true;
  bool _obscureConfirmText = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String passwordPattern =
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$';
  final String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@(gmail\.com|yahoo\.com|hotmail\.com|outlook\.com)$';

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Color(0xFF046be0),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
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
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: mediaQuery.size.width * 0.1),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(130, 143, 143, 143),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildInputField('Name', name),
                          const SizedBox(height: 20),
                          _buildInputField('Email', email),
                          const SizedBox(height: 20),
                          _buildInputField('Student ID', studentId,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(
                                    11), // Limit to 11 digits
                              ]),
                          const SizedBox(height: 20),
                          _buildInputField('Contact Number', contactNumber,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(
                                    11), // Limit to 11 digits
                              ]),
                          const SizedBox(height: 20),
                          _buildInputField('Password', password,
                              isPassword: true),
                          const SizedBox(height: 20),
                          _buildInputField('Confirm Password', confirmPassword,
                              isConfirmPassword: true),
                          const SizedBox(height: 20),
                          _buildRegisterButton(mediaQuery),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already Have An Account? ',
                                  style: TextStyle(color: Colors.white)),
                              GestureDetector(
                                child: const Text(
                                  'Log In',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                onTap: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool isPassword = false,
      bool isConfirmPassword = false,
      List<TextInputFormatter>? inputFormatters}) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8), // Less rounded corners
      ),
      child: TextField(
        controller: controller,
        obscureText: (isPassword && _obscureText) ||
            (isConfirmPassword && _obscureConfirmText),
        inputFormatters: inputFormatters, // Add input formatters here
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white), // Bright white text
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), // Less rounded corners
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), // Less rounded corners
            borderSide: BorderSide(
              color: Color(0xFFFFEB3B),
              width: 2.0,
            ),
          ),
          border: InputBorder.none,
          suffixIcon: (isPassword || isConfirmPassword)
              ? IconButton(
                  icon: Icon(
                    (isPassword ? _obscureText : _obscureConfirmText)
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isPassword) {
                        _obscureText = !_obscureText;
                      } else {
                        _obscureConfirmText = !_obscureConfirmText;
                      }
                    });
                  },
                )
              : null,
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildRegisterButton(MediaQueryData mediaQuery) {
    return InkWell(
      borderRadius: BorderRadius.circular(8), // Less rounded corners for button
      onTap: () async {
        if (name.text.isEmpty ||
            email.text.isEmpty ||
            password.text.isEmpty ||
            confirmPassword.text.isEmpty ||
            studentId.text.isEmpty ||
            contactNumber.text.isEmpty) {
          _showErrorDialog('Please fill in all fields.');
        } else if (!RegExp(emailPattern).hasMatch(email.text)) {
          _showErrorDialog(
              'Please enter a valid email address (e.g., example@gmail.com)');
        } else if (!RegExp(passwordPattern).hasMatch(password.text)) {
          _showErrorDialog(
              'Password must be at least 8 characters, include an uppercase letter, a lowercase letter, a number, and a special character.');
        } else if (password.text != confirmPassword.text) {
          _showErrorDialog('Passwords do not match.');
        } else if (contactNumber.text.length != 11) {
          // Check length of contact number
          _showErrorDialog('Contact number must be exactly 11 digits.');
        } else {
          try {
            UserCredential userCredential =
                await _auth.createUserWithEmailAndPassword(
              email: email.text,
              password: password.text,
            );

            await userCredential.user!.sendEmailVerification();

            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .set({
              'userId': userCredential.user!.uid,
              'name': name.text,
              'email': email.text,
              'studentId': studentId.text,
              'contactNumber': contactNumber.text,
              'createdAt': Timestamp.now(),
            });

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Success'),
                  content: const Text(
                      'Registration successful! A verification email has been sent.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          } catch (e) {
            _showErrorDialog(e.toString());
          }
        }
      },
      child: Container(
        height: mediaQuery.size.height * 0.06,
        width: mediaQuery.size.width * 0.5,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 15, 5, 93),
          borderRadius:
              BorderRadius.circular(8), // Less rounded corners for button
        ),
        child: const Center(
          child: Text(
            'REGISTER',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
