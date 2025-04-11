import 'package:flutter/material.dart';
import 'checkout.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems; // Item list

  CartPage({required this.cartItems});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool selectAll = false; // Checkbox state
  double totalAmount = 0.0; // Total cart amount
  late List<bool> selectedItems; // Selection state for each item

  @override
  void initState() {
    super.initState();
    // Initialize the selected items list
    selectedItems = List<bool>.filled(widget.cartItems.length, false);
  }

  // Update the total amount based on selected items
  void _updateTotal() {
    setState(() {
      totalAmount = 0.0;
      for (int i = 0; i < widget.cartItems.length; i++) {
        if (selectedItems[i]) {
          totalAmount += widget.cartItems[i]['price'];
        }
      }
    });
  }

  // Toggle the select all checkbox
  void _toggleSelectAll(bool value) {
    setState(() {
      selectAll = value;
      // Set all items to the same selection state
      for (int i = 0; i < selectedItems.length; i++) {
        selectedItems[i] = value;
      }
      _updateTotal();
    });
  }

  // Remove item from the cart
  void _removeItem(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
      selectedItems.removeAt(index);
      _updateTotal();
    });
  }

  // Interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Title Bar
          Padding(
            padding: const EdgeInsets.only(top: 40.0, bottom: 16.0),
            child: Center(
              child: Text(
                "Shopping Cart",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Divider(height: 1, thickness: 1),
          Expanded(
            child: widget.cartItems.isEmpty
                ? Center(
              child: Text(
                "No items in the shopping cart.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: selectedItems[index],
                        onChanged: (bool? value) {
                          setState(() {
                            selectedItems[index] = value ?? false;
                            _updateTotal();
                          });
                        },
                      ),
                      SizedBox(width: 8),
                      // Enlarged Item Image
                      Image.asset(
                        widget.cartItems[index]['image'],
                        width: 80, // Updated size
                        height: 80, // Updated size
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 16),
                      // Item Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.cartItems[index]['name'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'RM ${widget.cartItems[index]['price'].toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete,
                            color: Colors.orange), // Trash Icon in Orange
                        onPressed: () => _removeItem(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, thickness: 1),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: selectAll,
                      onChanged: (bool? value) {
                        _toggleSelectAll(value ?? false);
                      },
                    ),
                    Text("All"),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Total ",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Text(
                      "RM${totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: totalAmount > 0
                          ? () {
                        // Navigate to Checkout Page
                        final selectedProducts = <Map<String, dynamic>>[];
                        for (int i = 0;
                        i < widget.cartItems.length;
                        i++) {
                          if (selectedItems[i]) {
                            selectedProducts.add(widget.cartItems[i]);
                          }
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                              selectedProducts: selectedProducts,
                            ),
                          ),
                        );
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(
                        "Check Out (${selectedItems.where((item) => item).length})",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Default to Cart Page
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
            // Navigate to homepage
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            // Navigate to cart page
            Navigator.pushReplacementNamed(context, '/cart');
          } else if (index == 2) {
            // Navigate to account page
            Navigator.pushReplacementNamed(context, '/account');
          }
        },
      ),
    );
  }
}