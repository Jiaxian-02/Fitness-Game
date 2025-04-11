import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

class GameIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Play background music when enter this page
    FlameAudio.bgm.play('background_music.mp3', volume: 1.0);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/intro_page.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 20,
            child: IconButton(
              icon: Image.asset("assets/images/help_button.png"),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Center(
                        child: Text(
                          "Introduction",
                          style: TextStyle(
                            fontFamily: 'Asap',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              "Welcome to Nini's Adventureland!",
                              style: TextStyle(
                                fontFamily: 'Asap',
                                fontSize: 18,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "How to play:\n"
                                "1. Walk in real life to explore the game world!\n"
                                "2. Earn rewards and unlock mini-games along the way!\n"
                                "3. Join the community to motivate each other!\n"
                                "4. Walk more, earn more, discount more!",
                            style: TextStyle(
                              fontFamily: 'Asap',
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Done",
                              style: TextStyle(
                                fontFamily: 'Asap',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 300.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/game'); // Navigate to the main game page
                },
                child: Text(
                  "Start",
                  style: TextStyle(
                    fontFamily: 'Asap',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding:
                  EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded button
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
