import 'package:flame/components.dart';

class GameCharacter extends SpriteComponent {
  double movementSpeed = 100;
  bool isMoving = false;
  double targetPositionX = 0;

  GameCharacter() {
    position = Vector2(140, 640);  // Initial position
    size = Vector2(110, 110);
  }

  // Update character position
  void moveToTarget(double dt, double targetX) {
    if ((targetX - position.x).abs() > 1) {
      double movementAmount = movementSpeed * dt;
      position.x += movementAmount * (targetX > position.x ? 1 : -1);
    } else {
      isMoving = false;
    }
  }

  // Start character movement
  void startMoving(double newTargetX) {
    targetPositionX = newTargetX;
    isMoving = true;
  }

  // Update character position
  @override
  void update(double dt) {
    super.update(dt);
    // If the character is moving, move it to the target position
    if (isMoving) {
      moveToTarget(dt, targetPositionX);
    }
    // Keep character at a fixed vertical position
    position.x = 140;
  }
}