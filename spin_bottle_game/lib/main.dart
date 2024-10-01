import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: SpinTheBottleGame(),
    );
  }
}

class SpinTheBottleGame extends StatefulWidget {
  @override
  _SpinTheBottleGameState createState() => _SpinTheBottleGameState();
}

class _SpinTheBottleGameState extends State<SpinTheBottleGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<String> playerNames = [];
  String? selectedPlayer;
  bool _isSpinning = false;

  final TextEditingController nameController = TextEditingController();
  final List<String> challenges = [
    "Do 10 push-ups",
    "Sing a song",
    "Tell a funny joke",
    "Do a silly dance",
    "Share a secret"
  ];

  // Fixed angles for 10 names
  final List<double> nameAngles = [0, 36, 72, 108, 144, 180, 216, 252, 288, 324];

  // List of bottle images
  List<String> bottleImages = ['bottle1.png', 'bottle2.png', 'bottle3.png'];
  String selectedBottle = 'bottle1.png'; // Default bottle

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3), // Consistent spin duration
    );

    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          _selectExactPlayer();
        });
      }
    });
  }

  void _addPlayerName() {
    if (playerNames.length < 10 && nameController.text.isNotEmpty) {
      setState(() {
        playerNames.add(nameController.text);
        nameController.clear();
      });
    }
  }

  void _selectExactPlayer() {
    if (playerNames.isNotEmpty) {
      // Calculate the final angle the bottle stops at
      double bottleAngle = _controller.value * 360; // Convert controller value to angle
      double selectedAngle = bottleAngle % 360; // Normalize to 360 degrees

      // Round the selected angle to the nearest predefined angle
      int selectedPlayerIndex = nameAngles.indexWhere((angle) =>
          (selectedAngle - angle).abs() < 5); // Allow a small margin of error

      if (selectedPlayerIndex != -1 && selectedPlayerIndex < playerNames.length) {
        selectedPlayer = playerNames[selectedPlayerIndex];
        String randomChallenge = challenges[Random().nextInt(challenges.length)];
        _showResultDialog(selectedPlayer!, randomChallenge);
      } else {
        // If no valid player was found, prompt to spin again
        _retrySpin();
      }
    }
  }

  void _retrySpin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Try Again'),
        content: Text('The bottle didn’t land on a player. Spin again!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(String playerName, String challenge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Selected Player: $playerName'),
        content: Text('Challenge: $challenge'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spin the Bottle Game'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Enter player name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addPlayerName,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          if (playerNames.isNotEmpty)
            Container(
              width: 300,
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ..._buildCircularNames(), // Build names in a circle around the bottle
                  RotationTransition(
                    turns: _animation,
                    child: Image.asset('images/$selectedBottle', width: 100),
                  ),
                ],
              ),
            ),
          SizedBox(height: 20),
          DropdownButton<String>(
            value: selectedBottle,
            items: bottleImages.map((bottle) {
              return DropdownMenuItem<String>(
                value: bottle,
                child: Text(bottle),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedBottle = newValue!;
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSpinning
                ? null
                : () {
                    setState(() {
                      _isSpinning = true;
                      selectedPlayer = null;

                      // Randomly choose one of the angles where the bottle will stop
                      int randomAngleIndex = Random().nextInt(playerNames.length);
                      double selectedAngle = nameAngles[randomAngleIndex];

                      // Set the animation to spin to the chosen angle
                      _animation = Tween<double>(begin: 0, end: selectedAngle * (pi / 180)).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Curves.easeOut,
                        ),
                      );
                      _controller.reset();
                      _controller.forward();
                    });
                  },
            child: Text('Spin the Bottle'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCircularNames() {
    double radius = 140; // Radius of the circle
    List<Widget> nameWidgets = [];
    int totalPlayers = 10; // Maximum number of players

    for (int i = 0; i < totalPlayers; i++) {
      if (i < playerNames.length) {
        double angle = nameAngles[i] * (pi / 180); // Convert to radians
        double x = radius * cos(angle);
        double y = radius * sin(angle);

        nameWidgets.add(
          Positioned(
            left: 150 + x - 30, // Adjust for centering
            top: 150 + y - 15, // Adjust for centering
            child: Text(
              playerNames[i],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    }
    return nameWidgets;
  }
}