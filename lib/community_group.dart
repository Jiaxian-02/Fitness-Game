import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'community_page.dart';

class CommunityGroups extends StatelessWidget {
  const CommunityGroups({Key? key}) : super(key: key);

  // Join a community group and navigate to the community page
  Future<void> joinGroup(BuildContext context, String groupName, String groupImage, String membersCount, int groupLevel) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'groupName': groupName, // Save the group name to Firestore
      });
      // Navigate to the Community page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Community(
            groupName: groupName,
            groupImage: groupImage,
            membersCount: membersCount,
            groupLevel: groupLevel,
          ),
        ),
      );
    }
  }

  // Interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text(
          'Community Groups',
          style: TextStyle(
            fontFamily: 'Asap',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);

          },
        ),

      ),
      // List of community groups
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildGroupBox(context, 'Let\'s Walk Together', '20', 'assets/images/community_g1.png', 2),
          _buildGroupBox(context, 'Walkie Power', '50', 'assets/images/community_g2.png', 4),
          _buildGroupBox(context, 'Morning Joggers', '34', 'assets/images/community_g3.png', 3),
          _buildGroupBox(context, 'Evening Strollers', '36', 'assets/images/community_g4.png', 3),
          _buildGroupBox(context, 'Night Owls', '65', 'assets/images/community_g5.png', 5),
        ],
      ),
    );
  }

  // Widget to build the group box
  Widget _buildGroupBox(BuildContext context, String groupName, String membersCount, String imagePath, int level) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Tribe Logo
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Community Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupName,
                    style: TextStyle(
                      fontFamily: 'Asap',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Level $level',
                    style: TextStyle(
                      fontFamily: 'Asap',
                      fontSize: 16,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  Text(
                    '$membersCount members',
                    style: TextStyle(
                      fontFamily: 'Asap',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Join Group Button
            ElevatedButton(
              onPressed: () => joinGroup(context, groupName, imagePath, membersCount, level),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Join Group',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Asap',
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}