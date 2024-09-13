import 'package:flutter/material.dart';
import 'dart:math'; //for sqrt function in quadratic calculator

void main() => runApp(UltimateCalculatorApp());

class UltimateCalculatorApp extends StatelessWidget {
  const UltimateCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MultiToolHome(),
    );
  }
}

class MultiToolHome extends StatefulWidget {
  const MultiToolHome({super.key});

  @override
  State<MultiToolHome> createState() => _MultiToolHomeState();
}

class _MultiToolHomeState extends State<MultiToolHome> {
  String currentTool = "BMI";
  // Normal Calculator Controllers
  TextEditingController controller_1 = TextEditingController();
  TextEditingController controller_2 = TextEditingController();

  // BMI Calculator Controllers
  TextEditingController bmiWeightController = TextEditingController();
  TextEditingController bmiHeightController = TextEditingController();

  // Tip Calculator Controllers
  TextEditingController billController = TextEditingController();
  TextEditingController tipController = TextEditingController();

  // Age Calculator Controllers
  TextEditingController birthYearController = TextEditingController();

  // Currency Converter Controllers
  TextEditingController amountController = TextEditingController();

  // Quadratic Solver Controllers
  TextEditingController aController = TextEditingController();
  TextEditingController bController = TextEditingController();
  TextEditingController cController = TextEditingController();

  // Temperature Converter Controllers
  TextEditingController tempController = TextEditingController();

  // Speed/Distance/Time Calculator Controllers
  TextEditingController speedController = TextEditingController();
  TextEditingController distanceController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  // Discount Calculator Controllers
  TextEditingController originalPriceController = TextEditingController();
  TextEditingController discountController = TextEditingController();

  // Fuel Efficiency Calculator Controllers
  TextEditingController distanceFuelController = TextEditingController();
  TextEditingController fuelConsumedController = TextEditingController();

  // To-Do List Variables
  List<String> tasks = [];
  TextEditingController taskController = TextEditingController();
  List<bool> taskCompleted = [];

  double result = 0;
  String resultMessage = "Result will appear here";

  // Simple Calculator Functions
  void addNumbers() {
    double num1 = double.parse(controller_1.text);
    double num2 = double.parse(controller_2.text);
    setState(() {
      result = num1 + num2;
      resultMessage = "Result: $result";
    });
  }

  void subtractNumbers() {
    double num1 = double.parse(controller_1.text);
    double num2 = double.parse(controller_2.text);
    setState(() {
      result = num1 - num2;
      resultMessage = "Result: $result";
    });
  }

  void multiplyNumbers() {
    double num1 = double.parse(controller_1.text);
    double num2 = double.parse(controller_2.text);
    setState(() {
      result = num1 * num2;
      resultMessage = "Result: $result";
    });
  }

  void divideNumbers() {
    double num1 = double.parse(controller_1.text);
    double num2 = double.parse(controller_2.text);
    setState(() {
      if (num2 != 0) {
        result = num1 / num2;
        resultMessage = "Result: $result";
      } else {
        resultMessage = "Cannot divide by zero!";
      }
    });
  }

  // BMI Calculator Function
  void calculateBMI() {
    double weight = double.parse(bmiWeightController.text);
    double height = double.parse(bmiHeightController.text) / 100;
    setState(() {
      result = weight / (height * height);
      resultMessage = "Your BMI: ${result.toStringAsFixed(2)}";
    });
  }

  // Tip Calculator Function
  void calculateTip() {
    double bill = double.parse(billController.text);
    double tipPercentage = double.parse(tipController.text);
    setState(() {
      result = bill + (bill * tipPercentage / 100);
      resultMessage = "Total Amount: \$${result.toStringAsFixed(2)}";
    });
  }

  // Age Calculator Function
  void calculateAge() {
    int birthYear = int.parse(birthYearController.text);
    int currentYear = DateTime.now().year;
    setState(() {
      result = (currentYear - birthYear).toDouble();
      resultMessage = "Your Age: $result years";
    });
  }

  // Currency Converter Function (Fixed Exchange Rate for demo)
  void convertCurrency() {
    double amount = double.parse(amountController.text);
    const double exchangeRate = 1.1; // Example: USD to EUR
    setState(() {
      result = amount * exchangeRate;
      resultMessage = "Converted Amount: €${result.toStringAsFixed(2)}";
    });
  }

// Quadratic Equation Solver Function
  void solveQuadratic() {
    double a = double.parse(aController.text);
    double b = double.parse(bController.text);
    double c = double.parse(cController.text);
    double discriminant = (b * b) - (4 * a * c);

    setState(() {
      if (discriminant > 0) {
        double root1 =
            (-b + sqrt(discriminant)) / (2 * a);
        double root2 =
            (-b - sqrt(discriminant)) / (2 * a);
        resultMessage = "Roots: $root1, $root2";
      } else if (discriminant == 0) {
        double root = -b / (2 * a);
        resultMessage = "Root: $root";
      } else {
        resultMessage = "No real roots";
      }
    });
  }

  // Temperature Converter Function
  void convertTemperature() {
    double temp = double.parse(tempController.text);
    setState(() {
      result = (temp * 9 / 5) + 32; // Celsius to Fahrenheit
      resultMessage = "$temp°C = $result°F";
    });
  }

  // Speed/Distance/Time Calculator Function
  void calculateSDT(String calculationType) {
    double speed = double.parse(speedController.text);
    double distance = double.parse(distanceController.text);
    double time = double.parse(timeController.text);
    setState(() {
      if (calculationType == "Speed") {
        result = distance / time;
        resultMessage = "Speed: $result units/time";
      } else if (calculationType == "Distance") {
        result = speed * time;
        resultMessage = "Distance: $result units";
      } else if (calculationType == "Time") {
        result = distance / speed;
        resultMessage = "Time: $result time";
      }
    });
  }

  // Discount Calculator Function
  void calculateDiscount() {
    double originalPrice = double.parse(originalPriceController.text);
    double discountPercentage = double.parse(discountController.text);
    setState(() {
      result = originalPrice - (originalPrice * discountPercentage / 100);
      resultMessage = "Final Price: \$${result.toStringAsFixed(2)}";
    });
  }

  // Fuel Efficiency Calculator Function
  void calculateFuelEfficiency() {
    double distance = double.parse(distanceFuelController.text);
    double fuelUsed = double.parse(fuelConsumedController.text);
    setState(() {
      result = distance / fuelUsed;
      resultMessage = "Fuel Efficiency: $result km/l";
    });
  }

  void addTask() {
    String newTask = taskController.text;
    if (newTask.isNotEmpty) {
      setState(() {
        tasks.add(newTask);
        taskCompleted.add(false);
      });
      taskController.clear();
    }
  }

  void toggleTaskCompletion(int index) {
    setState(() {
      taskCompleted[index] = !taskCompleted[index];
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      taskCompleted.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ultimate Multi-Calculator"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownButton<String>(
              value: currentTool,
              items: [
                DropdownMenuItem(
                    value: "Simple", child: const Text("Simple Calculator")),
                DropdownMenuItem(
                    value: "BMI", child: const Text("BMI Calculator")),
                DropdownMenuItem(
                    value: "Tip", child: const Text("Tip Calculator")),
                DropdownMenuItem(
                    value: "Age", child: const Text("Age Calculator")),
                DropdownMenuItem(
                    value: "Currency", child: const Text("Currency Converter")),
                DropdownMenuItem(
                    value: "Quadratic", child: const Text("Quadratic Solver")),
                DropdownMenuItem(
                    value: "Temperature",
                    child: const Text("Temperature Converter")),
                DropdownMenuItem(
                    value: "SDT",
                    child: const Text("Speed/Distance/Time Calculator")),
                DropdownMenuItem(
                    value: "Discount",
                    child: const Text("Discount Calculator")),
                DropdownMenuItem(
                    value: "Fuel",
                    child: const Text("Fuel Efficiency Calculator")),
                DropdownMenuItem(
                    value: "Todo", child: const Text("To-do List")),
              ],
              onChanged: (value) {
                setState(() {
                  currentTool = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Different calculators UI
            if (currentTool == "Simple") ...[
              TextField(
                controller: controller_1,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Enter First Number"),
              ),
              TextField(
                controller: controller_2,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Enter Second Number"),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: addNumbers, child: const Text("Add")),
                  ElevatedButton(
                      onPressed: subtractNumbers,
                      child: const Text("Subtract")),
                  ElevatedButton(
                      onPressed: multiplyNumbers,
                      child: const Text("Multiply")),
                  ElevatedButton(
                      onPressed: divideNumbers, child: const Text("Divide")),
                ],
              ),
            ] else if (currentTool == "BMI") ...[
              TextField(
                controller: bmiWeightController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Enter Weight (kg)"),
              ),
              TextField(
                controller: bmiHeightController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Enter Height (cm)"),
              ),
              ElevatedButton(
                onPressed: calculateBMI,
                child: const Text("Calculate BMI"),
              ),
            ] else if (currentTool == "Tip") ...[
              TextField(
                controller: billController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Enter Bill Amount (\$)"),
              ),
              TextField(
                controller: tipController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Enter Tip Percentage (%)"),
              ),
              ElevatedButton(
                onPressed: calculateTip,
                child: const Text("Calculate Tip"),
              ),
            ] else if (currentTool == "Age") ...[
              TextField(
                controller: birthYearController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Enter Birth Year"),
              ),
              ElevatedButton(
                onPressed: calculateAge,
                child: const Text("Calculate Age"),
              ),
            ] else if (currentTool == "Currency") ...[
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Enter Amount (USD)"),
              ),
              ElevatedButton(
                onPressed: convertCurrency,
                child: const Text("Convert Currency"),
              ),
            ] else if (currentTool == "Quadratic") ...[
              TextField(
                controller: aController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Enter 'a' coefficient"),
              ),
              TextField(
                controller: bController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Enter 'b' coefficient"),
              ),
              TextField(
                controller: cController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Enter 'c' coefficient"),
              ),
              ElevatedButton(
                onPressed: solveQuadratic,
                child: const Text("Solve Equation"),
              ),
            ] else if (currentTool == "Temperature") ...[
              TextField(
                controller: tempController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Enter Temperature (Celsius)"),
              ),
              ElevatedButton(
                onPressed: convertTemperature,
                child: const Text("Convert Temperature"),
              ),
            ] else if (currentTool == "SDT") ...[
              TextField(
                controller: speedController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Enter Speed (units/time)"),
              ),
              TextField(
                controller: distanceController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Enter Distance (units)"),
              ),
              TextField(
                controller: timeController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Enter Time (time)"),
              ),
              ElevatedButton(
                onPressed: () => calculateSDT("Speed"),
                child: const Text("Calculate Speed"),
              ),
            ] else if (currentTool == "Discount") ...[
              TextField(
                controller: originalPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Enter Original Price (\$)"),
              ),
              TextField(
                controller: discountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Enter Discount Percentage (%)"),
              ),
              ElevatedButton(
                onPressed: calculateDiscount,
                child: const Text("Calculate Discount"),
              ),
            ] else if (currentTool == "Fuel") ...[
              TextField(
                controller: distanceFuelController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Enter Distance Traveled (km)"),
              ),
              TextField(
                controller: fuelConsumedController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Enter Fuel Consumed (liters)"),
              ),
              ElevatedButton(
                onPressed: calculateFuelEfficiency,
                child: const Text("Calculate Fuel Efficiency"),
              ),
            ] else if (currentTool == "Todo") ...[
              TextField(
                controller: taskController,
                decoration: const InputDecoration(labelText: "Enter Task"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: addTask, child: const Text("Add Task")),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        tasks[index],
                        style: TextStyle(
                            decoration: taskCompleted[index]
                                ? TextDecoration.lineThrough
                                : TextDecoration.none),
                      ),
                      leading: Checkbox(
                        value: taskCompleted[index],
                        onChanged: (bool? value) {
                          toggleTaskCompletion(index);
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          deleteTask(index);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(resultMessage, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
