import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _obscureText = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
                      padding: EdgeInsets.symmetric(horizontal: mediaQuery.size.width * 0.1),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(130, 143, 143, 143),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildInputField('NAME', name),
                          const SizedBox(height: 20),
                          _buildInputField('EMAIL', email),
                          const SizedBox(height: 20),
                          _buildInputField('PASSWORD', password, isPassword: true),
                          const SizedBox(height: 20),
                          _buildRegisterButton(mediaQuery),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already Have An Account? ', style: TextStyle(color: Colors.white)),
                              GestureDetector(
                                child: const Text(
                                  'Log In',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildInputField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 22, color: Colors.white),
        ),
        Container(
          padding: const EdgeInsets.only(left: 10),
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && _obscureText,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: Color(0xFFFFEB3B), // Highlight color when focused
                  width: 2.0,
                ),
              ),
              border: InputBorder.none,
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
                  : null,
            ),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(MediaQueryData mediaQuery) {
    return Container(
      height: mediaQuery.size.height * 0.06,
      padding: EdgeInsets.symmetric(horizontal: mediaQuery.size.width * 0.15),
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 15, 5, 93),
          borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: TextButton(
          child: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'REGISTER',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          onPressed: () async {
            if (name.text.isEmpty || email.text.isEmpty || password.text.isEmpty) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Error'),
                    content: const Text('Please fill in all fields.'),
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
            } else {
              // Firebase Registration Logic
              try {
                UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                  email: email.text,
                  password: password.text,
                );

                // Save additional user information in Firestore
                await _firestore.collection('users').doc(userCredential.user!.uid).set({
                  'name': name.text,
                  'email': email.text,
                  'createdAt': Timestamp.now(),
                });

                // Registration success
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Success'),
                      content: const Text('Registration successful!'),
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
              } catch (e) {
                // Handle errors
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Error'),
                      content: Text(e.toString()),
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
          },
        ),
      ),
    );
  }
}
