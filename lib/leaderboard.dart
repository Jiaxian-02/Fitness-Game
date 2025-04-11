import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Leaderboard extends StatelessWidget {
  // Fetch leaderboard data from firestore
  Future<List<Map<String, dynamic>>> fetchLeaderboard() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('steps', descending: true)
        .get();

    // Avoid duplicate post
    final leaderboardData = querySnapshot.docs.map((doc) => {
      'uid': doc.id,
      'username': doc['username'] ?? 'Unknown',
      'steps': doc['steps'] ?? 0,
    }).toList();

    // Check if the current user achieved leaderboard rank
    checkLeaderboardRank(leaderboardData);

    return leaderboardData;
  }

  // Check the user rank on leaderboard
  void checkLeaderboardRank(List<Map<String, dynamic>> leaderboardData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final rank = leaderboardData.indexWhere((entry) => entry['uid'] == user.uid) + 1;

      if (rank == 1) {
        final username = leaderboardData.firstWhere((entry) => entry['uid'] == user.uid)['username'];
        final message = '$username achieved Rank #1 on the Leaderboard!';
        final existingPost = await FirebaseFirestore.instance
            .collection('community_feed')
            .where('username', isEqualTo: username)
            .where('message', isEqualTo: message)
            .limit(1)
            .get();

        if (existingPost.docs.isEmpty) {
          await FirebaseFirestore.instance.collection('community_feed').add({
            'username': username,
            'message': message,
            'likes': 0,
            'comments': [],
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      }
    }
  }

  // Interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text(
          'Leaderboard',
          style: TextStyle(
            fontFamily: 'Asap',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error fetching leaderboard.',
                style: TextStyle(
                    fontFamily: 'Asap',
                    fontSize: 18,
                    color: Colors.red,
                ),
              ),
            );
          }

          final leaderboardData = snapshot.data ?? [];
          final currentUserUID = FirebaseAuth.instance.currentUser?.uid;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                // Current player's ranking and steps
                _buildCurrentPlayerTile(leaderboardData, currentUserUID),
                SizedBox(height: 30),
                Text(
                  'Top Users',
                  style: TextStyle(
                    fontFamily: 'Asap',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: leaderboardData.length,
                    itemBuilder: (context, index) {
                      final user = leaderboardData[index];
                      return _buildLeaderboardTile(
                        rankIcon: index < 3 ? _getMedalIcon(index) : null,
                        rankNumber: index >= 3 ? index + 1 : null,
                        userName: user['username'],
                        steps: '${user['steps']}',
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Display the current user rank and step count
  Widget _buildCurrentPlayerTile(List<Map<String, dynamic>> leaderboardData, String? currentUserUID) {
    if (currentUserUID == null) {
      return Text(
        'You are not logged in.',
        style: TextStyle(
            fontFamily: 'Asap',
            fontSize: 18,
            color: Colors.black54,
        ),
      );
    }

    final currentUser = leaderboardData.firstWhere(
          (user) => user['uid'] == currentUserUID,
      orElse: () => {'username': 'Unknown', 'steps': 0},
    );

    if (currentUser['username'] == 'Unknown') {
      return Text(
        'You are not in the leaderboard.',
        style: TextStyle(
            fontFamily: 'Asap',
            fontSize: 18,
            color: Colors.black54,
        ),
      );
    }

    final rank = leaderboardData.indexOf(currentUser) + 1;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'My Ranking: $rank',
            style: TextStyle(
              fontFamily: 'Asap',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.orangeAccent,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Steps: ${currentUser['steps']}',
            style: TextStyle(
              fontFamily: 'Asap',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // Build a tile for each leaderboard entry
  Widget _buildLeaderboardTile({
    String? rankIcon,
    int? rankNumber,
    required String userName,
    required String steps,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: rankIcon != null
            ? Image.asset(rankIcon, width: 40, height: 40)
            : CircleAvatar(
          backgroundColor: Colors.grey.shade300,
          child: Text(
            '$rankNumber',
            style: TextStyle(
              fontFamily: 'Asap',
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        title: Text(
          userName,
          style: TextStyle(
            fontFamily: 'Asap',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: Text(
          steps,
          style: TextStyle(
            fontFamily: 'Asap',
            fontSize: 16,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      ),
    );
  }

  // Return the medal icon path based on the rank
  String _getMedalIcon(int index) {
    switch (index) {
      case 0:
        return 'assets/images/goldmedal.png';
      case 1:
        return 'assets/images/silvermedal.png';
      case 2:
        return 'assets/images/bronzemedal.png';
      default:
        return '';
    }
  }
}
