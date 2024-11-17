import 'dart:math';

class CalculatorBrain {
  CalculatorBrain({required this.height, required this.weight});

  final int height;
  final int weight;

  double bmi = 0;

  String calculateBMI() {
    bmi = weight / pow(height / 100, 2);
    return bmi.toStringAsFixed(1);
  }

  String getResult() {
    if (bmi >= 25) {
      return "Overweight";
    } else if (bmi > 18.5) {
      return "Normal";
    } else {
      return "under-weight";
    }
  }

  String getInterpretation() {
    if (bmi >= 25) {
      return "You have higher BMI than a normal human being, try exercising regularly!";
    } else if (bmi > 18.5) {
      return "You have a good BMI, try to stay fit!";
    } else {
      return "You have lower BMI, try eating healthy stuff!";
    }
  }


}