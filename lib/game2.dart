import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MemorySequenceGame extends StatefulWidget {
  @override
  _MemorySequenceGameState createState() => _MemorySequenceGameState();
}

class _MemorySequenceGameState extends State<MemorySequenceGame> {
  final List<String> items = [
    "assets/images/apple.png",
    "assets/images/cherry.png",
    "assets/images/grape.png",
    "assets/images/watermelon.png",
    "assets/images/orange.png",
    "assets/images/strawberry.png"
  ];

  List<String> sequence = [];
  List<String> playerSequence = [];
  int currentRound = 1;
  bool gameActive = true;
  bool showSequence = false;

  @override
  void initState() {
    super.initState();
    startNewRound();
  }

  // Start a new round by adding a new item to the sequence
  void startNewRound() {
    setState(() {
      sequence.add(items[Random().nextInt(items.length)]);
      playerSequence.clear();
      showSequence = true;
    });
    Future.delayed(Duration(seconds: sequence.length), () {
      setState(() {
        showSequence = false;
      });
    });
  }

  // Handle player's tap on an item
  void handleTap(String tappedItem) {
    setState(() {
      playerSequence.add(tappedItem);
    });
    // Check if the player's sequence matches the generated sequence
    for (int i = 0; i < playerSequence.length; i++) {
      if (playerSequence[i] != sequence[i]) {
        endGame(false);
        return;
      }
    }
    // Proceed to next round the the sequence is match
    if (playerSequence.length == sequence.length) {
      if (currentRound == 6) {
        endGame(true);
      } else {
        setState(() {
          currentRound++;
        });
        Future.delayed(Duration(seconds: 1), startNewRound);
      }
    }
  }

  // End the game
  void endGame(bool won) {
    setState(() {
      gameActive = false;
    });
    if (won) {
      showSuccessDialog();
    } else {
      showGameOverDialog();
    }
  }

  // Show game over dialog
  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Game Over!',
              style: TextStyle(
                fontFamily: 'Asap',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.orange,
              ),
            ),
          ),
          content: Text(
            'Oops! You missed the sequence. Try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Asap',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();  // Restart the game
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: Text(
                'Play Again',
                style: TextStyle(
                    fontFamily: 'Asap',
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                'Exit',
                style: TextStyle(
                  fontFamily: 'Asap',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showSuccessDialog() async {
    int rewardCoins = 15;

    // Add coins to firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);
        if (snapshot.exists) {
          // Update existing coins
          final currentCoins = snapshot['coins'] ?? 0;
          transaction.update(userDocRef, {'coins': currentCoins + rewardCoins});
        } else {
          transaction.set(userDocRef, {'coins': rewardCoins});
        }
      });
    }

    // Show the success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Congratulations!',
              style: TextStyle(
                fontFamily: 'Asap',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.orange,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You completed the mini-game!',
                style: TextStyle(
                  fontFamily: 'Asap',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '+$rewardCoins ',
                    style: TextStyle(
                      fontFamily: 'Asap',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Image.asset(
                    'assets/images/coins.png',
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Exit the mini game
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: Text(
                'Exit',
                style: TextStyle(
                  fontFamily: 'Asap',
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Reset the game to the initial state
  void resetGame() {
    setState(() {
      sequence.clear();
      playerSequence.clear();
      currentRound = 1;
      gameActive = true;
      startNewRound();
    });
  }

  // Show confirmation dialog to exit the game
  void showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Exit Game',
              style: TextStyle(
                fontFamily: 'Asap',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.orange,
              ),
            ),
          ),
          content: Text(
            'Are you sure you want to exit?',
            style: TextStyle(
                fontFamily: 'Asap',
                fontWeight: FontWeight.w600,
                fontSize: 18),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              style: ElevatedButton.styleFrom(
              ),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontFamily: 'Asap',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Exit mini-game page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: Text(
                "Exit",
                style: TextStyle(
                    fontFamily: 'Asap',
                    fontWeight: FontWeight.w500,
                    color: Colors.white
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Interface
  @override
  Widget build(BuildContext context) {
    double containerWidth = sequence.length * 55.0 + 10;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/shopping_bg.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0),
              ),
            ),
          ),
          Positioned(
            top: 20, // Adjust as needed
            left: 20,
            child: GestureDetector(
              onTap: showExitConfirmationDialog,
              child: Image.asset(
                'assets/images/backward.png',
                width: 60,
                height: 60,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Round $currentRound',
                  style: TextStyle(
                    fontFamily: 'Asap',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  showSequence ? 'Memorize the Sequence!' : 'Your Turn!',
                  style: TextStyle(
                    fontFamily: 'Asap',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                if (showSequence)
                  Container(
                    width: containerWidth,
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: sequence
                          .map((item) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            item,
                            width: 35,
                            height: 35,
                          ),
                        ),
                      ))
                          .toList(),
                    ),
                  ),
                SizedBox(height: 30),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: items.map((item) {
                    return ElevatedButton(
                      onPressed: gameActive && !showSequence
                          ? () => handleTap(item)
                          : null,
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(16),
                        backgroundColor: Colors.white,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(12.0),
                        child: Image.asset(
                          item,
                          width: 50,
                          height: 50,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}