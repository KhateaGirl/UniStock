import 'package:flutter/material.dart';
import 'package:UNISTOCK/Profileinfo.dart';


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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profileInfo.name);
    _studentIdController = TextEditingController(text: widget.profileInfo.studentId);
    _contactNumberController = TextEditingController(text: widget.profileInfo.contactNumber);
    _emailController = TextEditingController(text: widget.profileInfo.email);
    _addressController = TextEditingController(text: widget.profileInfo.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final updatedProfileInfo = ProfileInfo(
      name: _nameController.text,
      studentId: _studentIdController.text,
      contactNumber: _contactNumberController.text,
      email: _emailController.text,
      address: _addressController.text,
    );

    Navigator.pop(context, updatedProfileInfo);
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
