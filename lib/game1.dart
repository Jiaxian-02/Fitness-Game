import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CatchTheBall extends StatefulWidget {
  final VoidCallback onCoinsUpdated; // Callback to update coins when game completes
  CatchTheBall({required this.onCoinsUpdated});

  @override
  _CatchTheBallGameState createState() => _CatchTheBallGameState();
}

class _CatchTheBallGameState extends State<CatchTheBall> {
  List<BallData> balls = [];
  double gloveX = 0.0;
  int score = 0;
  int coins =0;
  bool gameOver = false;
  int timer = 30;
  Random random = Random();

  @override
  void initState() {
    super.initState();
    startGame();
    startTimer();
  }

  // Initialize the game by generating balls periodically
  void startGame() {
    balls.clear();
    ballTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (gameOver || this.timer == 0) {
        timer.cancel();
      } else {
        generateNewBall();
      }
    });

    // Move balls downward periodically
    ballTimer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      if (gameOver || this.timer == 0) {
        timer.cancel();
      }
      setState(() {
        for (var ball in balls) {
          ball.y += ball.speed;
          if (ball.y >= 580 && ball.y <= 600) {
            if ((gloveX - ball.x).abs() < 50) {
              score += 1; // Add score if the ball is caught
              ball.y = -1000;
            } else if (ball.y > 600) {
              showGameOverDialog(); // Show game over dialog if the ball is missed
            }
          } else if (ball.y > 600) {
            showGameOverDialog();
          }
        }
        balls.removeWhere((ball) => ball.y <= -1000); // Remove off screen balls
      });
    });
  }

  // Generate new ball at random position
  void generateNewBall() {
    double xPosition = random.nextDouble() * 300;
    double speed = 5.0;
    balls.add(BallData(xPosition, 0.0, speed));
  }

  // Start the game countdown timer
  void startTimer() {
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (this.timer == 0 || gameOver) {
        timer.cancel();
        if (!gameOver && this.timer == 0) {
          showSuccessDialog();
        }
      } else {
        setState(() {
          this.timer--;
        });
      }
    });
  }

  // Show Game Over dialog if user miss the ball
  void showGameOverDialog() {
    if (gameOver) return; // Prevent showing multiple dialogs
    gameOver = true;

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
            'You missed the ball!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Asap',
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame(); // Reset the game after the dialog is closed
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: Text(
                'Play Again',
                style: TextStyle(
                  fontFamily: 'Asap',
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Exit the mini-game
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

  Timer? ballTimer; // Timer to control ball generation and movement
  Timer? gameTimer; // Timer to control game countdown

  // Reset the game to initial state
  void resetGame() {
    ballTimer?.cancel();
    gameTimer?.cancel();

    setState(() {
      gloveX = 0.0;
      balls.clear();
      score = 0;
      gameOver = false;
      timer = 30;
    });
    startGame();
    startTimer();
  }

  // Show success dialog when the game is completed successfully
  void showSuccessDialog() async {
    int rewardCoins = 10;

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
    if (mounted) {
      widget.onCoinsUpdated();
    }

    // Success pop up
    showDialog(
      context: context,
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
                Navigator.of(context).pop(); // Exit the mini-game
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

  // Show confirmation dialog when user want to exit the mini game
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
                color: Colors.orange,),
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
                Navigator.of(context).pop(); // Exit mini game page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: Text(
                "Exit",
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

  // Interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/playground_bg.png",
              fit: BoxFit.cover,
            ),
          ),
          // Darkened and blurred overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.3),
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
                width: 60, // Adjust size as needed
                height: 60,
              ),
            ),
          ),
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                gloveX += details.delta.dx;
                if (gloveX < 0) gloveX = 0;
                if (gloveX > 300) gloveX = 300;
              });
            },
            child: Stack(
              children: [
                ...balls.map((ball) => Positioned(
                  top: ball.y,
                  left: ball.x,
                  child: Ball(),
                )),
                Positioned(
                  bottom: 50,
                  left: gloveX,
                  child: Glove(),
                ),
                Align(
                  alignment: Alignment(0, -0.75),
                  child: Text(
                    "Score: $score",
                    style: TextStyle(
                      fontFamily: 'Asap',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  right: 10,
                  child: Text(
                    "Time: $timer",
                    style: TextStyle(
                      fontFamily: 'Asap',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Ball widget
class Ball extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/ball.png',
      width: 50,
      height: 50,
    );
  }
}

// Glove widget
class Glove extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/glove.png',
      width: 120,
      height: 90,
    );
  }
}

// Data class to represent a ball's position and speed
class BallData {
  double x;
  double y;
  double speed;

  BallData(this.x, this.y, this.speed);
}