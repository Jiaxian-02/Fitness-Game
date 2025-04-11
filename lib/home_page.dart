import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_1.dart';
import 'product_2.dart';

class ECommercePage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems; // List to hold cart item

  ECommercePage({required this.cartItems});

  @override
  _ECommercePageState createState() => _ECommercePageState();
}

class _ECommercePageState extends State<ECommercePage> {
  int coins = 0; // coins balance

  @override
  void initState() {
    super.initState();
    fetchCoins();
  }

  // Fetch the coin balance from firestore
  Future<void> fetchCoins() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (snapshot.exists && snapshot['coins'] != null) {
        setState(() {
          coins = snapshot['coins'];
        });
      }
    }
  }

  // Interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.orange,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.white, size: 26),
              onPressed: () {
              },
            ),
            Expanded(
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 10),
                      Icon(Icons.search, color: Colors.grey),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 8, bottom: 8),
                          ),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/images/banner.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet,
                            color: Colors.orange, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'RM20.50',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/coins.png',
                          height: 28,
                          width: 28,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '$coins Coins',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            // Buttons: Mall, Game & Win Coins, Offers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconButton(
                    icon: Icons.store,
                    label: 'Mall',
                    onTap: () {
                    },
                  ),
                  _buildIconButton(
                    icon: Icons.videogame_asset,
                    label: 'Game &\nWin Coins',
                    onTap: () {
                      Navigator.pushNamed(context, '/intro');
                    },
                  ),
                  _buildIconButton(
                    icon: Icons.local_offer,
                    label: 'Offers',
                    onTap: () {
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 14,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _buildProductCard(
                        context,
                        imagePath: 'assets/images/product_1.png',
                        name: 'Dumbbell',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Product1Page(cartItems: widget.cartItems),
                            ),
                          );
                        },
                      ),
                      _buildProductCard(
                        context,
                        imagePath: 'assets/images/product_2.png',
                        name: 'Skipping Rope',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Product2Page(cartItems: widget.cartItems),
                            ),
                          );
                        },
                      ),
                      // Product 3 (UI Only)
                      _buildProductCard(
                        context,
                        imagePath: 'assets/images/product_3.png',
                        name: 'Vitamin B',
                        onTap: () {
                          // No functionality for this product
                        },
                      ),
                      // Product 4 (UI Only)
                      _buildProductCard(
                        context,
                        imagePath: 'assets/images/product_4.png',
                        name: 'Only Organic',
                        onTap: () {
                          // No functionality for this product
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Default as home page
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home'); // Navigate to home page
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/cart'); // Navigate to cart page
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/account'); // Navigate to account page
          }
        },
      ),
    );
  }

  // Build icon for navigation
  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.orange, size: 40),
            SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build product
  Widget _buildProductCard(
      BuildContext context, {
        required String imagePath,
        required String name,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 120, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
