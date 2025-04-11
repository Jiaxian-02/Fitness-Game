import 'package:pedometer/pedometer.dart';

class StepTracker {
  Stream<StepCount>? _stepCountStream;
  int steps = 0;
  final Function(int) onStepsUpdated;

  StepTracker({required this.onStepsUpdated});

  // Start tracking real steps using the pedometer
  void startStepTracking() {
    try {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream?.listen(onStepCount).onError(onStepError);
    } catch (e) {
      print('Error starting pedometer: $e');
    }
  }

  void onStepCount(StepCount event) {
    steps = event.steps;
    onStepsUpdated(steps); // Notify the game of updated steps
  }

  void onStepError(error) {
    print('Pedometer error: $error');
  }
}
