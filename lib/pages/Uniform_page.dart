import 'package:flutter/material.dart';
import 'package:UNISTOCK/pages/CartPage.dart';
import 'package:UNISTOCK/pages/CollegeUniformPage.dart';
import 'package:UNISTOCK/pages/SHSUniformsPage.dart';
import 'package:UNISTOCK/pages/ProwareShirtsPage.dart';

class UniformPage extends StatelessWidget {
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
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CollegeUniformsPage(),
                    ),
                  );
                },
                child: Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(15.0), // Rounded corners
                          child: Image.asset(
                            'assets/images/college uniform.png',
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 200,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'College Uniforms',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SHSUniformsPage()),
                  );
                },
                child: Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(15.0), // Rounded corners
                          child: Image.asset(
                            'assets/images/shs uniform.png',
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 200,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'SHS Uniforms',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProwareShirtsPage(),
                    ),
                  );
                },
                child: Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(15.0), // Rounded corners
                          child: Image.asset(
                            'assets/images/washdayshirt.png',
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 200,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Proware Shirts',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
