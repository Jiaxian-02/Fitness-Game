import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'community_page.dart';
import 'community_group.dart';
import 'game1.dart';
import 'game2.dart';
import 'leaderboard.dart';

class SidePanel extends StatefulWidget {
  final String username;
  final int coins;
  final bool isMiniGame1Unlocked;
  final bool isMiniGame2Unlocked;
  final int currentSteps;
  final int miniGame1UnlockSteps;
  final int miniGame2UnlockSteps;
  final VoidCallback onCoinsUpdated;

  SidePanel({
    required this.username,
    required this.coins,
    required this.isMiniGame1Unlocked,
    required this.isMiniGame2Unlocked,
    required this.currentSteps,
    required this.miniGame1UnlockSteps,
    required this.miniGame2UnlockSteps,
    required this.onCoinsUpdated,
  });

  @override
  _SidePanelState createState() => _SidePanelState();
}

class _SidePanelState extends State<SidePanel> {
  bool isMiniGamesExpanded = false;

  // Navigate to the community page based on the group user joined
  Future<void> _navigateToCommunity(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data()?['groupName'] != null && userDoc.data()?['groupName'] != '') {
        final groupName = userDoc.data()?['groupName'];

        // Navigate to the Community page with default values
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Community(
              groupName: groupName,
              groupImage: 'assets/images/community_g1.png',
              membersCount: '20',
              groupLevel: 1,
            ),
          ),
        );
      } else {
        // Navigate to the community group page if user not joining any group
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CommunityGroups()),
        );
      }
    }
  }

  // Interface
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 30.0, right: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildUserDetails(),
            SizedBox(height: 15),

            // Leaderboard button
            _buildImageButton(
              imagePath: 'assets/images/leaderboard.png',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Leaderboard())),
            ),
            SizedBox(height: 10),

            // Community button
            _buildImageButton(
              imagePath: 'assets/images/friends.png',
              onPressed: () => _navigateToCommunity(context),
            ),
            SizedBox(height: 10),

            // Mini games button
            _buildImageButton(
              imagePath: 'assets/images/mini_game.png',
              onPressed: () {
                setState(() {
                  // Toggle mini games section visibility
                  isMiniGamesExpanded = !isMiniGamesExpanded;
                });
              },
            ),
            // Show mini-games if expanded
            if (isMiniGamesExpanded) ..._buildMiniGameButtons(),
          ],
        ),
      ),
    );
  }

  // Widget to display user details
  Widget _buildUserDetails() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/user_icon.png', width: 40, height: 40),
          SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.username,
                style: TextStyle(
                  fontFamily: 'Asap',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  Image.asset('assets/images/coins.png', width: 30, height: 30),
                  SizedBox(width: 5),
                  Text(
                    '${widget.coins}',
                    style: TextStyle(
                      fontFamily: 'Asap',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Create image buttons
  Widget _buildImageButton({required String imagePath, required VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onPressed,
        child: Image.asset(imagePath, width: 50, height: 50),
      ),
    );
  }

  // Build the mini game buttons
  List<Widget> _buildMiniGameButtons() {
    return [
      // Mini game 1 button
      _buildImageButton(
        imagePath: widget.isMiniGame1Unlocked
            ? 'assets/images/catch_ball.png' // Unlock icon
            : 'assets/images/locked.png', // Lock icon
        onPressed: widget.isMiniGame1Unlocked
            ? () => _playMiniGame(context, CatchTheBall(onCoinsUpdated: widget.onCoinsUpdated))
            : () {
          if (widget.currentSteps < widget.miniGame1UnlockSteps) {
            _showLockedDialog(context, widget.miniGame1UnlockSteps - widget.currentSteps);
          }
        },
      ),
      SizedBox(height: 10),

      // Mini game 2 button
      _buildImageButton(
        imagePath: widget.isMiniGame2Unlocked
            ? 'assets/images/memory_game.png' // Unlock icon
            : 'assets/images/locked.png', // Lock icon
        onPressed: widget.isMiniGame2Unlocked
            ? () => _playMiniGame(context, MemorySequenceGame())
            : () {
          if (widget.currentSteps < widget.miniGame2UnlockSteps) {
            _showLockedDialog(context, widget.miniGame2UnlockSteps - widget.currentSteps);
          }
        },
      ),
    ];
  }

  // Show a dialog when mini game is locked
  void _showLockedDialog(BuildContext context, int remainingSteps) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mini-Game Locked',
                  style: TextStyle(
                    fontFamily: 'Asap',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'You still need $remainingSteps steps to unlock this mini-game.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Asap',
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontFamily: 'Asap',
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Play the selected mini game and refresh coins
  void _playMiniGame(BuildContext context, Widget miniGame) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => miniGame),
    ).then((_) {
      // This callback is triggered when returning from the mini-game
      _refreshCoinsAfterMiniGame();
    });
  }

  // Refresh the coin balance after playing mini game
  void _refreshCoinsAfterMiniGame() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          widget.onCoinsUpdated(); // Call the parent's update function
        });
      }
    }
  }
}
