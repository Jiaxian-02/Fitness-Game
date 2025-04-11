import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Reward {
  final String name;
  final String description;
  final String imagePath;
  final int coins;

  Reward({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.coins,
  });

  // Create a default reward for reaching checkpoint
  factory Reward.forCheckpoint() {
    return Reward(
      name: "Reward!",
      description: "",
      imagePath: 'assets/images/coins.png',
      coins: 10,
    );
  }

  // Display the reward pop up
  Future<void> showRewardPopup(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.all(20),
          title: Center(
            child: Text(
              name,
              style: TextStyle(
                fontFamily: 'Asap',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(imagePath, width: 80, height: 80),
              SizedBox(height: 10),
              Text(
                "You earned $coins coins!",
                style: TextStyle(
                  fontFamily: 'Asap',
                  fontSize: 18,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text(
                "OK",
                style: TextStyle(
                  fontFamily: 'Asap',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Add coins without showing pop up
  static Future<void> addCoinsSilently(int coins) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Update firestore with the new coin balance
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);
        final currentCoins = snapshot.exists ? (snapshot['coins'] ?? 0) : 0;
        transaction.update(userDocRef, {'coins': currentCoins + coins});
      });
    }
  }


}

