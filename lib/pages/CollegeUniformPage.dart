import 'package:flutter/material.dart';
import 'package:UNISTOCK/pages/CartPage.dart';
import 'package:UNISTOCK/pages/SizeAndUniformSelection.dart';
import 'package:UNISTOCK/ProfileInfo.dart';

class CollegeUniformsPage extends StatelessWidget {
  final ProfileInfo currentProfileInfo;

  CollegeUniformsPage({required this.currentProfileInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF046be0),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Choose your course uniform',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              buildImageOption(
                context,
                'assets/images/bsit and bscpe.png',
                'BSIT & BSCPE',
                'IT&CPE',
              ),
              buildImageOption(
                context,
                'assets/images/bsa and bsba.png',
                'BSA & BSBA',
                'BSA & BSBA',
              ),
              buildImageOption(
                context,
                'assets/images/hrm and culinary.png',
                'HRM & CULINARY',
                'HRM & Culinary',
              ),
              buildImageOption(
                context,
                'assets/images/bacomm.png',
                'BACOMM',
                'BACOMM',
              ),
              buildImageOption(
                context,
                'assets/images/tourism1.png',
                'TOURISM',
                'Tourism',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImageOption(BuildContext context, String imagePath, String label,
      String courseLabel) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CollegeUniSelectionPage(
              courseLabel: courseLabel,
              currentProfileInfo: currentProfileInfo,
            ),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 180,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
