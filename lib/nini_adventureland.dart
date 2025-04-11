import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'character.dart';
import 'map.dart';
import 'checkpoint.dart';
import 'ui_display.dart';
import 'step_tracker.dart';
import 'side_panel.dart';
import 'package:flame_audio/flame_audio.dart';

class NiniAdventure extends FlameGame {
  BuildContext? _gameContext;
  late GameMap background;
  late GameCharacter character;
  late CameraComponent cameraComponent;
  late CheckpointManager checkpointManager;
  late StepText stepText;
  late BackwardButton backwardButton;
  late StepTracker stepTracker;

  String username = 'Player';
  int coins = 0;
  int currentSteps = 0;
  bool isMiniGame1Unlocked = false;
  bool isMiniGame2Unlocked = false;
  String groupName = '';
  bool isMoving = false;
  double targetPositionX = 0;
  double movementSpeed = 100;
  bool dialogOpen = false;
  bool usePedometer = false; // CHANGE HERE FOR PEDOMETER
  bool testingMode = true;
  DateTime lastFirestoreUpdate = DateTime.now();

  void setGameContext(BuildContext context) {
    _gameContext = context;
  }

  BuildContext? getGameContext() {
    return _gameContext;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Fetch user data from Firestore
    await _fetchUserData();

    // Initialize the checkpoint buildings
    _initializeCheckpoints();

    // Load the game map and character
    background = GameMap(Vector2(6000, size.y))..sprite = await loadSprite('background.png');
    character = GameCharacter()..sprite = await loadSprite('character.png');

    // add background map and character to the game
    add(background);
    add(character);

    // Initialize camera, stepText, and backward button
    cameraComponent = CameraComponent();
    add(cameraComponent);
    stepText= StepText();
    add(stepText);
    backwardButton = BackwardButton(onBackPressed: () {
      Navigator.of(_gameContext!).pushReplacementNamed('/home');
    });
    add(backwardButton);

    // Initialize pedometer
    stepTracker = StepTracker(onStepsUpdated: addSteps);

    // Initialize side panel
    _initializeSidePanel();

    // Initialize character position based on current step counts
    initializePosition(currentSteps);

    // Step tracking using pedometer or simulate for development purpose
    if (usePedometer) {
      stepTracker.startStepTracking();
    } else if (testingMode) {
      simulateSteps(50000); // Simulate HERE for TESTING
    }
  }

  // Fetch and initialize user data from Cloud Firestore
  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          username = data['username'] ?? 'Player';
          coins = data['coins'] ?? 0;
          currentSteps = data['steps'] ?? 0;
          isMiniGame1Unlocked = data['isMiniGame1Unlocked'] ?? false; // Fetch mini-game 1 state
          isMiniGame2Unlocked = data['isMiniGame2Unlocked'] ?? false; // Fetch mini-game 2 state
          groupName = data['groupName'] ?? '';

          refreshSidePanel();
        }
      }
    }
  }

  // Create a checkpoints list
  void _initializeCheckpoints() {
    checkpointManager = CheckpointManager([
      Checkpoint(name: 'Start', positionX: 10, stepsRequired: 0, type: CheckpointType.normal),
      Checkpoint(name: 'Store', positionX: 300, stepsRequired: 3000, type: CheckpointType.reward),
      Checkpoint(name: 'Taco Truck', positionX: 670, stepsRequired: 6000, type: CheckpointType.reward),
      Checkpoint(name: 'Fitness Center', positionX: 1180, stepsRequired: 9000, type: CheckpointType.rewardNSuggestion),
      Checkpoint(name: 'Police Station', positionX: 1650, stepsRequired: 12000, type: CheckpointType.reward),
      Checkpoint(name: 'Playground', positionX: 2200, stepsRequired: 16000, type: CheckpointType.miniGame),
      Checkpoint(name: 'Blue Building', positionX: 2850, stepsRequired: 23000, type: CheckpointType.reward),
      Checkpoint(name: 'Bakery House', positionX: 3400, stepsRequired: 29000, type: CheckpointType.rewardNSuggestion),
      Checkpoint(name: 'Fountain', positionX: 4100, stepsRequired: 34000, type: CheckpointType.reward),
      Checkpoint(name: 'Shopping Center', positionX: 4670, stepsRequired: 40000, type: CheckpointType.miniGame),
      Checkpoint(name: 'Hot Dog Truck', positionX: 5100, stepsRequired: 45000, type: CheckpointType.reward),
      Checkpoint(name: 'Bus Station', positionX: 5600, stepsRequired: 50000, type: CheckpointType.nextMap),
    ]);
  }

  // Define the information in side panel
  void _initializeSidePanel() {
    overlays.addEntry(
      'SidePanel',
          (_, __) => SidePanel(
        username: username,
        coins: coins,
        isMiniGame1Unlocked: isMiniGame1Unlocked,
        isMiniGame2Unlocked: isMiniGame2Unlocked,
        currentSteps: currentSteps,
        miniGame1UnlockSteps: 16000,
        miniGame2UnlockSteps: 40000,
        onCoinsUpdated: refreshCoinsAfterMiniGame, // Pass the function
      ),
    );
    // Add side panel
    overlays.add('SidePanel');
  }

  // Initializes the character position based on the current step count.
  void initializePosition(int steps) {
    currentSteps = steps;

    // Find the correct checkpoint
    for (int i = 0; i < checkpointManager.checkpoints.length - 1; i++) {
      final currentCheckpoint = checkpointManager.checkpoints[i];
      final nextCheckpoint = checkpointManager.checkpoints[i + 1];

      // Set character position to checkpoint
      if (steps >= currentCheckpoint.stepsRequired && steps < nextCheckpoint.stepsRequired) {
        checkpointManager.currentCheckpointIndex = i;
        targetPositionX = -currentCheckpoint.positionX;
        background.position.x = targetPositionX;
        stepText.updateText(steps, nextCheckpoint.stepsRequired);
        return;
      }
    }

    // If the steps exceed the last checkpoint, set the position to the last checkpoint
    if (steps >= checkpointManager.checkpoints.last.stepsRequired) {
      final lastCheckpoint = checkpointManager.checkpoints.last;
      checkpointManager.currentCheckpointIndex = checkpointManager.checkpoints.length - 1;
      targetPositionX = -lastCheckpoint.positionX;
      background.position.x = targetPositionX;
      stepText.updateText(steps, 0);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move the background if character "moving"
    if (isMoving) {
      smoothMoveBackground(dt);
    } else if (!dialogOpen) {
      moveToCorrectCheckpoint();
    }

    // Update the firestore periodically
    if (DateTime.now().difference(lastFirestoreUpdate) > Duration(seconds: 5)) {
      updateFirestoreData();
    }
  }

  // Update the firestore with user step counts and coins amount
  void updateFirestoreData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'steps': currentSteps,
        'coins': coins,
      });
      lastFirestoreUpdate = DateTime.now();
    }
  }

  // Add steps counts to current step counts balance
  void addSteps(int steps) {
    currentSteps += steps;
    moveToCorrectCheckpoint(); //move the character to correct checkpoint
    refreshSidePanel(); // refresh the side panel
    updateFirestoreData(); // store the step counts to firestore
    checkAndCreateMilestonePosts(); // create the community feed
  }

  // Simulates step addition for testing purposes.
  void simulateSteps(int steps) {
    addSteps(steps);
  }

  // Refreshes the side panel to reflect updated data.
  void refreshSidePanel() {
    Future.microtask(() {
      overlays.remove('SidePanel');
      overlays.add('SidePanel');
    });
  }

  // Move the background map towards checkpoint
  void smoothMoveBackground(double dt) {
    double deltaX = targetPositionX - background.position.x;

    if (deltaX.abs() > 1) {
      double movementAmount = movementSpeed * dt;
      background.position.x += movementAmount * (deltaX > 0 ? 1 : -1);
    } else {
      // Stop moving once the target position is reached
      if (isMoving) {
        isMoving = false;
        // Trigger the checkpoint action only when the position matches
        final currentCheckpoint = checkpointManager.getCurrentCheckpoint();
        if (background.position.x.round() == targetPositionX.round() && !dialogOpen) {
          _triggerCheckpointAction(currentCheckpoint);
        }
      }
    }
    // Keep the character in sync with the background
    character.moveToTarget(dt, targetPositionX);
  }

  // Triggers actions when the character reaches the checkpoint.
  void _triggerCheckpointAction(Checkpoint checkpoint) {
    if (!dialogOpen) {
      final context = getGameContext();
      if (context != null) {
        dialogOpen = true;
        checkpointManager.triggerCheckpointAction(
          context,
          checkpoint,
          onDialogClosed: () async {
            dialogOpen = false;

            // The action if checkpoint type is reward
            if (checkpoint.type == CheckpointType.reward) {
              await _addCoinsToFirestore(10);
            }

            // The action if checkpoint type is reward & suggestion
            if (checkpoint.type == CheckpointType.rewardNSuggestion) {
              await _addCoinsToFirestore(10);
            }

            // The action if checkpoint type is mini-games
            if (checkpoint.type == CheckpointType.miniGame) {
              if (checkpoint.name == 'Playground') {
                await _unlockMiniGame(1);
              } else if (checkpoint.name == 'Shopping Center') {
                await _unlockMiniGame(2);
              }
              refreshCoinsAfterMiniGame();
              refreshSidePanel();
            }
            checkAndCreateMilestonePosts();
            moveToCorrectCheckpoint();
          },
          onCoinsUpdated: refreshCoinsAfterMiniGame,
        );
      }
    }
  }

  // Update the coin balance after a mini-game.
  void refreshCoinsAfterMiniGame() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        coins = userDoc['coins'] ?? 0;
        refreshSidePanel(); // Update the UI with the new coin count
      }
    }
  }

  // Move the character to the correct checkpoint based on steps.
  void moveToCorrectCheckpoint() {
    final nextCheckpointIndex = checkpointManager.currentCheckpointIndex + 1;

    // Stop processing if there are no more checkpoints
    if (nextCheckpointIndex >= checkpointManager.checkpoints.length) return;

    final nextCheckpoint = checkpointManager.checkpoints[nextCheckpointIndex];

    // Check if the steps are enough to move to the next checkpoint
    if (currentSteps >= nextCheckpoint.stepsRequired && !dialogOpen && !isMoving) {
      // Move towards the next checkpoint sequentially
      targetPositionX = -nextCheckpoint.positionX;
      isMoving = true;

      // Update the current checkpoint index
      checkpointManager.currentCheckpointIndex++;

      // Update the "Next point" text
      if (checkpointManager.currentCheckpointIndex + 1 < checkpointManager.checkpoints.length) {
        final nextNextCheckpoint = checkpointManager.checkpoints[checkpointManager.currentCheckpointIndex + 1];
        stepText.updateText(currentSteps, nextNextCheckpoint.stepsRequired);
      } else {
        stepText.updateText(currentSteps, 0); // No more checkpoints
      }
    }
  }

  // Add coins to the  Firestore.
  Future<void> _addCoinsToFirestore(int coinsToAdd) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);
        final currentCoins = snapshot['coins'] ?? 0;
        transaction.update(userDocRef, {'coins': currentCoins + coinsToAdd});
      });

      // Fetch the latest coin balance from firestore
      final latestSnapshot = await userDocRef.get();
      coins = latestSnapshot['coins'];
      refreshSidePanel();
    }
  }

  // Unlocks a mini-game for the user.
  Future<void> _unlockMiniGame(int gameNumber) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      // Unlock mini-game 1 if it hasn't been unlock & update firestore
      if (gameNumber == 1 && !isMiniGame1Unlocked) {
        isMiniGame1Unlocked = true;
        await userDocRef.update({'isMiniGame1Unlocked': true});
        // Unlock mini-game 2 if it hasn't been unlock & update firestore
      } else if (gameNumber == 2 && !isMiniGame2Unlocked) {
        isMiniGame2Unlocked = true;
        await userDocRef.update({'isMiniGame2Unlocked': true});
      }
    }
    refreshSidePanel();
  }

  //Creates community feed posts for milestone achievements.
  void checkAndCreateMilestonePosts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Define milestones dynamically
      final milestones = [
        {
          'condition': currentSteps >= 10000,
          'message': '$username reached 10,000 steps!',
        },
        {
          'condition': currentSteps >= 20000,
          'message': '$username reached 20,000 steps!',
        },
        {
          'condition': isMiniGame1Unlocked,
          'message': '$username unlocked Mini-Game 1!',
        },
        {
          'condition': isMiniGame2Unlocked,
          'message': '$username unlocked Mini-Game 2!',
        },
        {
          'condition': currentSteps >= 50000,
          'message': '$username achieved the weekly goal of 50,000 steps!',
        },
      ];

      // Loop through milestones and post if conditions are met
      for (final milestone in milestones) {
        if (milestone['condition'] == true) {
          final message = milestone['message'];

          // Avoid duplicate posts (check Firestore for existing messages)
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
  }

  // Stop the background music when exit the game
  @override
  void onRemove() {
    FlameAudio.bgm.stop();
    super.onRemove();
  }
}