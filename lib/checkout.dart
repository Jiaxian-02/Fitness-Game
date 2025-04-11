import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedProducts;

  CheckoutPage({required this.selectedProducts});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  double merchandiseSubtotal = 0.0; // Subtotal of selected product
  double discount = 0.0; // Default discount
  double shippingFee = 4.99; // Default shipping fee
  int coins = 0; // User's coins
  String selectedOfferText = "Select to use offers";

  @override
  void initState() {
    super.initState();
    // Calculate the subtotal
    merchandiseSubtotal = widget.selectedProducts.fold(
        0, (sum, item) => sum + item['price']);
    fetchCoins();
  }

  // Fetch user's coin balance from firestore
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

  // Apply discount based on selected offer
  void _applyOffer(int selectedOffer) {
    setState(() {
      switch (selectedOffer) {
        case 0:
          discount = 2.0;
          break;
        case 1:
          discount = 4.0;
          break;
        case 2:
          discount = 10.0;
          break;
      }
      // Update the UI
      selectedOfferText = "Offer Applied";
    });
  }

  // Calculate the total payment amount after discount
  double get totalPayment => merchandiseSubtotal + shippingFee - discount;

  // Show dialog for selecting offers
  void _showOffersDialog() {
    int selectedOffer = -1;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.all(16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Save Using Coins',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.cancel, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Image.asset('assets/images/coins.png', width: 20),
                      SizedBox(width: 5),
                      Text('$coins coins available to use'),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildOfferOption(
                    'RM2 off',
                    50,
                    coins,
                    0,
                    selectedOffer,
                        (int index) => setState(() => selectedOffer = index),
                  ),
                  SizedBox(height: 10),
                  _buildOfferOption(
                    'RM4 off',
                    100,
                    coins,
                    1,
                    selectedOffer,
                        (int index) => setState(() => selectedOffer = index),
                  ),
                  SizedBox(height: 10),
                  _buildOfferOption(
                    'RM10 off',
                    250,
                    coins,
                    2,
                    selectedOffer,
                        (int index) => setState(() => selectedOffer = index),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: selectedOffer != -1 && coins >= _getOfferCoin(selectedOffer)
                        ? () {
                      _applyOffer(selectedOffer);
                      Navigator.pop(context);
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedOffer != -1 && coins >= _getOfferCoin(selectedOffer)
                          ? Colors.orange
                          : Colors.grey,
                    ),
                    child: Text('Redeem Now',
                      style: TextStyle(
                        color: selectedOffer != -1 && coins >= _getOfferCoin(selectedOffer)
                            ? Colors.white
                            : Colors.grey,),
                    )
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Widget to build an offer option
  Widget _buildOfferOption(
      String title,
      int cost,
      int coins,
      int index,
      int selectedOffer,
      ValueChanged<int> onTap,
      ) {
    bool isAvailable = coins >= cost;
    bool isSelected = selectedOffer == index;
    return GestureDetector(
      onTap: isAvailable ? () => onTap(index) : null,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          border: Border.all(color: isAvailable ? Colors.orange : Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : (isAvailable ? Colors.black : Colors.grey),
              ),
            ),
            Row(
              children: [
                Image.asset('assets/images/coins.png', width: 16, height: 16),
                SizedBox(width: 4),
                Text(
                  '$cost',
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isAvailable ? Colors.black : Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Get the coins needed for offer
  int _getOfferCoin(int selectedOffer) {
    switch (selectedOffer) {
      case 0:
        return 50;
      case 1:
        return 100;
      case 2:
        return 250;
      default:
        return 0;
    }
  }

  // Interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar with Back Icon
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Checkout',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 48),
                ],
              ),
            ),
            Divider(),

            // Delivery Address
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Address',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_pin, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '123, Jalan ABC, 47500, Subang Jaya, Selangor',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),

            // Items Purchased
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Item(s) Purchased',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ...widget.selectedProducts.map(
                  (item) => ListTile(
                leading: Image.asset(item['image'], width: 50, height: 50),
                title: Text(item['name']),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('RM ${item['price'].toStringAsFixed(2)}'),
                    Text('Qty: 1'),
                  ],
                ),
              ),
            ),
            Divider(),

            // Offers Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Offers',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: _showOffersDialog,
                    child: Text(
                      selectedOfferText,
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),

            // Payment Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Merchandise Subtotal'),
                      Text('RM ${merchandiseSubtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Shipping Fee'),
                      Text('RM ${shippingFee.toStringAsFixed(2)}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Discount'),
                      Text('- RM ${discount.toStringAsFixed(2)}'),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Payment',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'RM ${totalPayment.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Place Order Button
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {}, // No functionality, but button remains styled
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: Text(
                    'Place Order',
                    style: TextStyle(color: Colors.white),
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
