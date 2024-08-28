import 'package:UNISTOCK/ProfileInfo.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileInfo profileInfo;

  EditProfilePage({required this.profileInfo});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _studentIdController;
  late TextEditingController _contactNumberController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _passwordController;

  bool _obscurePassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Fetch the latest profile data from Firestore
  }

  Future<void> _fetchUserProfile() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists) {
          ProfileInfo fetchedProfileInfo = ProfileInfo.fromDocumentSnapshot(
              userDoc.data() as Map<String, dynamic>);
          setState(() {
            _nameController =
                TextEditingController(text: fetchedProfileInfo.name);
            _studentIdController =
                TextEditingController(text: fetchedProfileInfo.studentId);
            _contactNumberController =
                TextEditingController(text: fetchedProfileInfo.contactNumber);
            _emailController =
                TextEditingController(text: fetchedProfileInfo.email);
            _addressController =
                TextEditingController(text: fetchedProfileInfo.address);
            _passwordController = TextEditingController(text: '********'); // Display asterisks for the password
          });
        }
      }
    } catch (e) {
      print('Failed to fetch user profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user profile.')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      final updatedProfileInfo = ProfileInfo(
        userId: currentUser.uid,  // Add userId here
        name: _nameController.text,
        studentId: _studentIdController.text,
        contactNumber: _contactNumberController.text,
        email: _emailController.text,
        address: _addressController.text,
      );

      try {
        // Update the profile information in Firestore
        await _firestore.collection('users').doc(currentUser.uid).update({
          'userId': updatedProfileInfo.userId,
          'name': updatedProfileInfo.name,
          'studentId': updatedProfileInfo.studentId,
          'contactNumber': updatedProfileInfo.contactNumber,
          'email': updatedProfileInfo.email,
          'address': updatedProfileInfo.address,
        });

        // If the password has been changed, update it
        if (_passwordController.text != '********') {
          await currentUser.updatePassword(_passwordController.text);
        }

        // Return the updated profile info to the previous screen
        Navigator.pop(context, updatedProfileInfo);
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } else {
      // Handle user not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF046be0),
        title: Text('Edit Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _studentIdController,
              decoration: InputDecoration(labelText: 'Student ID'),
            ),
            TextField(
              controller: _contactNumberController,
              decoration: InputDecoration(labelText: 'Contact Number'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF046be0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
