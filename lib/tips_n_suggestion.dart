import 'package:flutter/material.dart';

class TipsNSuggestion {
  final String name;
  final String suggestion;
  final String rewardType;
  final int coins; // For coin rewards
  final String productName;
  final String productImagePath;

  TipsNSuggestion({
    required this.name,
    required this.suggestion,
    required this.rewardType,
    required this.coins,
    required this.productName,
    required this.productImagePath,
  });

  // Initialized reward & suggestion for Fitness Club checkpoint
  factory TipsNSuggestion.forCheckpointFC() {
    return TipsNSuggestion(
      name: "Reward!",
      suggestion: "At least 30 minutes of moderate exercise every week.",
      rewardType: "coins",
      coins: 10,
      productName: "Dumbbell",
      productImagePath: 'assets/images/product_1.png',
    );
  }

  // Initialized reward & suggestion for Bakery House checkpoint
  factory TipsNSuggestion.forCheckpointBH() {
    return TipsNSuggestion(
      name: "Reward!",
      suggestion: "Do 10 squats before eating to improve digestion.",
      rewardType: "coins",
      coins: 10,
      productName: "Skipping Rope",
      productImagePath: 'assets/images/product_2.png',
    );
  }

  // Display the reward & suggestion pop up dialog
  Future<void> showRewardNSuggestionPopup(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Asap',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                SizedBox(height: 10),

                // Suggestion Text with Health Tips
                Text(
                  'Health Tips: $suggestion',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Asap',
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 20),

                // Product Suggestion Box
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      // Product Image (Bigger Size)
                      Image.asset(
                        productImagePath,
                        width: 60,
                        height: 60,
                      ),
                      SizedBox(width: 10),

                      // Product Name
                      Expanded(
                        child: Text(
                          productName,
                          style: TextStyle(
                            fontFamily: 'Asap',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Visit Button
                      TextButton(
                        onPressed: () => _navigateToProduct(context),
                        child: Text(
                          'Visit >',
                          style: TextStyle(
                            fontFamily: 'Asap',
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Reward display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '+$coins',
                      style: TextStyle(
                        fontFamily: 'Asap',
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 5),
                    Image.asset(
                      'assets/images/coins.png',
                      width: 30,
                      height: 30,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
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
            ),
          ),
        );
      },
    );
  }

  // Navigate to the product page
  void _navigateToProduct(BuildContext context) {
    if (productName == 'Dumbbell') {
      Navigator.of(context).pushNamed('/product1');
    } else if (productName == 'Skipping Rope') {
      Navigator.of(context).pushNamed('/product2');
    }
  }

}
