import 'package:flutter/material.dart';
import 'game1.dart';
import 'game2.dart';

class MiniGame {
  final String name;
  final String description;
  final int rewardCoins;

  MiniGame({
    required this.name,
    required this.description,
    required this.rewardCoins,
  });

  // Show the mini-game option with the specific name, description, and reward
  Future<void> showMiniGameOption(BuildContext context, Function onYes, Function onNo) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          title: Center(
            child: Text(
              name,  // The mini game name
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
                description,  // Mini-game description
                style: TextStyle(
                    fontFamily: 'Asap',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Reward:',
                    style: TextStyle(
                        fontFamily: 'Asap',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 5),
                  Image.asset(
                    'assets/images/coins.png',
                    width: 24,
                    height: 24,
                  ),
                  SizedBox(width: 5),
                  Text(
                    '$rewardCoins',  // The reward amount
                    style: TextStyle(
                        fontFamily: 'Asap',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onNo(); // Callback for leave
              },
              child: Text(
                'Leave',
                style: TextStyle(
                    fontFamily: 'Asap',
                    fontSize:18,
                    fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onYes();  // Callback for starting the mini-game
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Accept',
                style: TextStyle(
                  fontFamily: 'Asap',
                  fontSize:18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Start the mini-game based on its name and wait for it to finish
  Future<void> startMiniGame(BuildContext context, VoidCallback onCoinsUpdated) async {
    if (name == 'Catch The Ball!') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          // Navigate to catch the ball mini game
          builder: (context) => CatchTheBall(onCoinsUpdated: onCoinsUpdated),
        ),
      );
    } else if (name == 'Memory Challenge!') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          // Navigate to memory challenge mini game
          builder: (context) => MemorySequenceGame(),
        ),
      );
    }
  }
}
