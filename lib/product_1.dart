import 'package:flutter/material.dart';
import 'checkout.dart';

class Product1Page extends StatelessWidget {
  // Product details
  final String productName = "Dumbbell";
  final String productImage = 'assets/images/product_1.png';
  final double productPrice = 20.00;
  final List<Map<String, dynamic>> cartItems;

  // Initialize cart items
  Product1Page({required this.cartItems});

  // Add the product into cart
  void addToCart(BuildContext context) {
    cartItems.add({
      'name': productName,
      'image': productImage,
      'price': productPrice,
    });
    // Show notification of adding item
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$productName added to cart"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Buy the product now by direct to the checkout page
  void buyNow(BuildContext context) {
    List<Map<String, dynamic>> selectedProducts = [
      {
        'name': productName,
        'image': productImage,
        'price': productPrice,
      }
    ];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(selectedProducts: selectedProducts),
      ),
    );
  }

  // Interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image and Back Button
            Stack(
              children: [
                Image.asset(
                  productImage,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 30,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Price and Sold Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RM $productPrice',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '380 sold',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey),
                  SizedBox(height: 10),
                  // Product Description
                  Text(
                    'Great for Strength Training. Durable and easy to handle, suitable for all fitness levels.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey),
                  SizedBox(height: 10),
                  // Shipping Information
                  Row(
                    children: [
                      Icon(Icons.local_shipping, color: Colors.orange, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Guaranteed to get within 7-14 days',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey),
                  SizedBox(height: 10),
                  // Secure Return Information
                  Row(
                    children: [
                      Icon(Icons.security, color: Colors.orange, size: 24),
                      SizedBox(width: 8),
                      Text(
                        '15-Day Free Return',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey),
                  SizedBox(height: 10),
                  // Product Rating
                  Row(
                    children: [
                      Text(
                        'Rating: ',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                        ),
                      ),
                      Icon(Icons.star, color: Colors.orange, size: 20),
                      Icon(Icons.star, color: Colors.orange, size: 20),
                      Icon(Icons.star, color: Colors.orange, size: 20),
                      Icon(Icons.star, color: Colors.orange, size: 20),
                      Icon(Icons.star_half, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '4.5/5',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey),
                  SizedBox(height: 10),
                  // Customer Feedback
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/images/user_icon.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'User123:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Great product, exactly as described!',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/images/user_icon.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'User456:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Quick delivery and very durable.',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Chat Now Button
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Chat Now functionality
                },
                child: Container(
                  color: Color(0xFFb9d4c1), // Green color
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble, color: Colors.white),
                      Text('Chat Now', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            // Divider
            Container(width: 1, height: double.infinity, color: Colors.white),
            // Add to Cart Button
            Expanded(
              child: GestureDetector(
                onTap: () => addToCart(context),
                child: Container(
                  color: Color(0xFFb9d4c1), // Green color
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_shopping_cart, color: Colors.white),
                      Text('Add to Cart', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            // Divider
            Container(width: 1, height: double.infinity, color: Colors.white),
            // Buy Now Button
            Expanded(
              child: GestureDetector(
                onTap: () => buyNow(context),
                child: Container(
                  color: Colors.orange,
                  child: Center(
                    child: Text(
                      'Buy Now',
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
