import 'package:flutter/material.dart';
import 'reward.dart';
import 'mini_game.dart';
import 'tips_n_suggestion.dart';

// Represent different types of checkpoints
enum CheckpointType { normal, reward, rewardNSuggestion, miniGame, nextMap }

class Checkpoint {
  final String name;
  final double positionX;
  final int stepsRequired;
  final CheckpointType type;

  Checkpoint({
    required this.name,
    required this.positionX,
    required this.stepsRequired,
    this.type = CheckpointType.normal,
  });
}

// Manages the checkpoints list and triggers checkpoint actions
class CheckpointManager {
  final List<Checkpoint> checkpoints;
  int currentCheckpointIndex = 0;

  CheckpointManager(this.checkpoints);

  // Get the current checkpoint
  Checkpoint getCurrentCheckpoint() {
    return checkpoints[currentCheckpointIndex];
  }

  // Trigger the checkpoint action
  void triggerCheckpointAction(
      BuildContext context,
      Checkpoint checkpoint, {
        required VoidCallback onDialogClosed, // Callback when dialog closes
        required VoidCallback onCoinsUpdated, // Callback when coins are updated
      }) {
    // Action if the checkpoint type is reward
    if (checkpoint.type == CheckpointType.reward) {
      Reward reward = Reward.forCheckpoint();
      reward.showRewardPopup(context).then((_) {
        onDialogClosed();
      });
      // Action if the checkpoint type is reward & suggestion
    } else if (checkpoint.type == CheckpointType.rewardNSuggestion) {
      TipsNSuggestion rewardNSuggestion;
      if (checkpoint.name == 'Fitness Center') {
        rewardNSuggestion = TipsNSuggestion.forCheckpointFC();
      } else if (checkpoint.name == 'Bakery House') {
        rewardNSuggestion = TipsNSuggestion.forCheckpointBH();
      } else {
        // Fallback if no specific factory is defined
        rewardNSuggestion = TipsNSuggestion.forCheckpointFC();
      }
      rewardNSuggestion.showRewardNSuggestionPopup(context).then((_) {
        onDialogClosed();
      });
      // Action if the checkpoint type is mini-game
    } else if (checkpoint.type == CheckpointType.miniGame) {
      MiniGame? miniGame;
      // Assign specific mini-games based on checkpoint name
      if (checkpoint.name == 'Playground') {
        miniGame = MiniGame(
          name: 'Catch The Ball!',
          description: 'Catch the ball with the glove before time runs out!',
          rewardCoins: 10,
        );
      } else if (checkpoint.name == 'Shopping Center') {
        miniGame = MiniGame(
          name: 'Memory Challenge!',
          description: 'Remember the sequence and challenge your memory!',
          rewardCoins: 15,
        );
      }
      if (miniGame != null) {
        // Show mini-game option popup
        miniGame.showMiniGameOption(context, () {
          miniGame?.startMiniGame(context, onCoinsUpdated).then((_) {
            onDialogClosed();
          });
        }, () {
          onDialogClosed();
        });
      }
      // Action if checkpoint type is move to next map
    } else if (checkpoint.type == CheckpointType.nextMap) {
      _showNextMapDialog(context, onDialogClosed);
    }
  }

  // The pop up dialog for move to next map
  void _showNextMapDialog(BuildContext context, VoidCallback onDialogClosed) {
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
          content: Text(
            "You have finished the current map!\nLet's move on to the next map:\n\n**Snow World**",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Asap',
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDialogClosed(); // Continue to handle transitioning logic in game.dart
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Asap',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
