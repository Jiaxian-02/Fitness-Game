import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'community_group.dart';

class Community extends StatefulWidget {
  final String groupName;
  final String groupImage;
  final String membersCount;
  final int groupLevel;

  const Community({
    required this.groupName,
    required this.groupImage,
    required this.membersCount,
    required this.groupLevel,
    Key? key,
  }) : super(key: key);

  @override
  _CommunityState createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  bool isLoading = false;

  // Leave the current group
  Future<void> leaveGroup(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'groupName': '', // Clear the group name in the database
      });
    }
    // Navigate back to community group page if leave group
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CommunityGroups()),
    );
  }

  // Interface
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Set the icon color to white
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/game'));
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(widget.groupImage),
              radius: 20,
            ),
            SizedBox(width: 10),
            Text(
              widget.groupName,
              style: TextStyle(
                fontFamily: 'Asap',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _showLeaveConfirmationDialog(context),
            child: Text(
              'Leave',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Asap',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          _buildProgressBar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Member\'s Feeds',
                  style: TextStyle(
                    fontFamily: 'Asap',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.membersCount} Members',
                  style: TextStyle(
                    fontFamily: 'Asap',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: fetchCommunityPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading feed.',
                      style: TextStyle(fontFamily: 'Asap', fontSize: 18, color: Colors.red),
                    ),
                  );
                }

                final posts = snapshot.data ?? [];
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _buildPost(context, post['id'], post['username'], post['message'], post['likes']);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build progress bar
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Level ${widget.groupLevel}',
                style: TextStyle(
                  fontFamily: 'Asap',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showLevelUpRewardsPopup(context, widget.groupLevel),
                child: Image.asset(
                  'assets/images/gift.png', // Path to your gift icon
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          LinearProgressIndicator(
            value: 0.6,
            backgroundColor: Colors.grey[300],
            color: Colors.orangeAccent,
            minHeight: 10,
          ),
          SizedBox(height: 10),
          Text(
            '6000 / 80000 Steps to Level Up',
            style: TextStyle(fontFamily: 'Asap', fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Show the rewards for leveling up the community group
  void _showLevelUpRewardsPopup(BuildContext context, int currentLevel) {
    // Define rewards for each box
    final List<Map<String, dynamic>> rewards = [
      {'level': currentLevel + 1, 'type': 'coins', 'value': 5},
      {'level': currentLevel + 2, 'type': 'voucher'},
      {'level': currentLevel + 3, 'type': 'coins', 'value': 8},
      {'level': currentLevel + 4, 'type': 'voucher'},
      {'level': currentLevel + 5, 'type': 'coins', 'value': 8},
    ];
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
                  'Level Up Your Group!',
                  style: TextStyle(
                    fontFamily: 'Asap',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                  ),
                ),
                SizedBox(height: 16),

                // Reward Boxes
                Column(
                  children: rewards.map((reward) {
                    bool canRedeem = reward['level'] <= currentLevel;

                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: canRedeem ? Colors.white : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade400,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Level ${reward['level']}',
                            style: TextStyle(
                              fontFamily: 'Asap',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: canRedeem ? Colors.black : Colors.grey,
                            ),
                          ),
                          Row(
                            children: [
                              if (reward['type'] == 'coins') ...[
                                Image.asset('assets/images/coins.png', width: 24, height: 24),
                                SizedBox(width: 8),
                                Text(
                                  '${reward['value']} Coins',
                                  style: TextStyle(
                                    fontFamily: 'Asap',
                                    fontSize: 16,
                                    color: canRedeem ? Colors.black : Colors.grey,
                                  ),
                                ),
                              ] else ...[
                                Image.asset('assets/images/voucher.png', width: 24, height: 24),
                                SizedBox(width: 8),
                                Text(
                                  'Shipping Voucher x1',
                                  style: TextStyle(
                                    fontFamily: 'Asap',
                                    fontSize: 16,
                                    color: canRedeem ? Colors.black : Colors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontFamily: 'Asap',
                      color: Colors.white,
                      fontSize: 18,
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

  // Show a confirmation dialog when leaving the group
  void _showLeaveConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing the dialog unintentionally
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Leave Tribe',
                  style: TextStyle(
                    fontFamily: 'Asap',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 12),

                // Confirmation Text
                Text(
                  'Are you sure you want to leave?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Asap',
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 24),

                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Cancel Button
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Asap',
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),

                    // Exit Button
                    ElevatedButton(
                      onPressed: () {
                        leaveGroup(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: Text(
                        'Leave',
                        style: TextStyle(
                          fontFamily: 'Asap',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build a post for the community feed
  Widget _buildPost(BuildContext context, String id, String username, String message, int likes) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        title: Text(
          username,
          style: TextStyle(fontFamily: 'Asap', fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          message,
          style: TextStyle(fontFamily: 'Asap', fontSize: 16),
        ),
        trailing: StatefulBuilder(
          builder: (context, setState) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.thumb_up,
                    color: likes > 0 ? Colors.orangeAccent : Colors.grey,
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('community_feed').doc(id).update({
                      'likes': likes + 1,
                    });
                    setState(() {});
                  },
                ),
                Text(
                  '$likes',
                  style: TextStyle(fontFamily: 'Asap', fontSize: 16),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Fetch community posts from firestore
  Stream<List<Map<String, dynamic>>> fetchCommunityPosts() {
    return FirebaseFirestore.instance
        .collection('community_feed')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'username': doc['username'],
        'message': doc['message'],
        'likes': doc['likes'],
      };
    }).toList());
  }
}