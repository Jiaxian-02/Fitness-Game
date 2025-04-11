import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

// Class to display the current step count and the steps needed for the next checkpoint
class StepText extends PositionComponent {
  late TextComponent boldText;
  late TextComponent lightText;

  StepText() {
    boldText = TextComponent(
      text: 'Steps: 0',
      textRenderer: TextPaint(
        style: TextStyle(
          fontFamily: 'Asap',
          fontWeight: FontWeight.w700,
          color: Colors.orange.shade800,
          fontSize: 33.0,
        ),
      ),
    );

    lightText = TextComponent(
      text: 'Next point: 0',
      textRenderer: TextPaint(
        style: TextStyle(
          fontFamily: 'Asap',
          fontWeight: FontWeight.w500,
          color: Colors.orange.shade800,
          fontSize: 28.0,
        ),
      ),
    );

    // Positions for both texts
    boldText.position = Vector2(10, 0);
    lightText.position = Vector2(0, 40);

    // Add both text components
    add(boldText);
    add(lightText);

    anchor = Anchor.center;
    position = Vector2(120, 150);
  }

  // Update the displayed text for both lines
  void updateText(int currentSteps, int nextSteps) {
    boldText.text = 'Steps: $currentSteps';
    lightText.text = 'Next point: $nextSteps';
  }
}

// Class to create a backward navigation button
class BackwardButton extends PositionComponent {
  final void Function() onBackPressed; // Callback function when the button is pressed

  BackwardButton({required this.onBackPressed}) {
    _addBackwardButton();
  }

  //Create the backward button
  Future<void> _addBackwardButton() async {
    final sprite = await Sprite.load('backward.png');

    final button = ButtonComponent(
      button: SpriteComponent(
        sprite: sprite,
        size: Vector2(50, 50),
      ),
      onPressed: onBackPressed,
      position: Vector2(20, 20),
    );

    // Add the button component to this parent component
    add(button);
  }
}
