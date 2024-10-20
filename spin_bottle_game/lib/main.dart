import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const SpinTheBottleApp());
}

class SpinTheBottleApp extends StatelessWidget {
  const SpinTheBottleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spin the Bottle',
      home: PlayerInputPage(),
    );
  }
}

class BottleSelectionPage extends StatefulWidget {
  final List<String> playerNames;
  const BottleSelectionPage({super.key, required this.playerNames});

  @override
  _BottleSelectionPageState createState() => _BottleSelectionPageState();
}

class _BottleSelectionPageState extends State<BottleSelectionPage> {
  int selectedBottleIndex = 0;
  final List<String> bottleAssets = [
    'images/bottle1.png',
    'images/bottle2.png',
    'images/bottle3.png',
    'images/bottle.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Your Bottle'),
        backgroundColor: const Color(0xFF8A2BE2), // New dark purple color
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6E6FA), Color(0xFFD8BFD8)], // Lavender gradient
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: bottleAssets.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedBottleIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedBottleIndex == index
                            ? Colors.deepPurple
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset(bottleAssets[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple, // Dark purple
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SpinBottlePage(
                      playerNames: widget.playerNames,
                      bottleImage: bottleAssets[selectedBottleIndex],
                    ),
                  ),
                );
              },
              child: const Text('Start Game', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class PlayerInputPage extends StatefulWidget {
  const PlayerInputPage({super.key});

  @override
  _PlayerInputPageState createState() => _PlayerInputPageState();
}

class _PlayerInputPageState extends State<PlayerInputPage> {
  final List<String> playerNames = List.filled(10, '');
  int selectedPlayerCount = 2; // Default to 2 players
  final TextEditingController playerCountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Players'),
        backgroundColor: const Color(0xFF8A2BE2), // Dark purple
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.85,
            colors: [Color(0xFFFFE4E1), Color(0xFFF08080)], // Light pink
          ),
        ),
        child: Column(
          children: [
            TextField(
              controller: playerCountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Number of Players',
                hintText: '2-10',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                int? count = int.tryParse(value);
                if (count != null && count >= 2 && count <= 10) {
                  setState(() {
                    selectedPlayerCount = count;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: selectedPlayerCount,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Player ${index + 1}',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        playerNames[index] = value;
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent, // Deep pink button
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              onPressed: () {
                if (playerNames.where((name) => name.isNotEmpty).length >= 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BottleSelectionPage(playerNames: playerNames),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter at least 2 players')),
                  );
                }
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class SpinBottlePage extends StatefulWidget {
  final List<String> playerNames;
  final String bottleImage;

  const SpinBottlePage({super.key, required this.playerNames, required this.bottleImage});

  @override
  _SpinBottlePageState createState() => _SpinBottlePageState();
}

class _SpinBottlePageState extends State<SpinBottlePage> with TickerProviderStateMixin {
  late AnimationController _finalRotationController;
  double _angle = 0.0;
  int selectedPlayerIndex = -1;
  String currentChallenge = "";
  final random = Random();
  final List<String> challenges = [
    'Sing a song',
    'Do 10 push-ups',
    'Tell a funny story',
    'Dance for 30 seconds',
    'Act like an animal for 1 minute',
  ];

  final double _spinSpeed = 0.3; // Constant spin speed

  @override
  void initState() {
    super.initState();
    _finalRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  void spinBottle() {
    final numPlayers = widget.playerNames.where((name) => name.isNotEmpty).length;
    if (numPlayers == 0) return;

    // Select a player randomly
    selectedPlayerIndex = random.nextInt(numPlayers);

    // Random number of spins before aligning to the selected player
    final randomSpins = random.nextInt(5) + 5;

    // Calculate the angle to align with the selected player
    final double playerAngle = 2 * pi * selectedPlayerIndex / numPlayers;

    // Total angle including random spins
    final double totalAngle = (randomSpins * 2 * pi) + playerAngle;

    // Reset and start the final rotation animation
    _finalRotationController.reset();

    // Adjust the duration based on the constant spin speed
    final duration = const Duration(seconds: 2);

    // Create a tween for the final rotation
    Tween<double> tween = Tween<double>(begin: _angle, end: totalAngle);

    // Use a CurvedAnimation for smoother transition
    final curvedAnimation = CurvedAnimation(
      parent: _finalRotationController,
      curve: Curves.easeOut,
    );

    // Update duration
    _finalRotationController.duration = duration;

    // Update the current challenge only when the bottle is spun
    currentChallenge = getChallenge();

    // Add listener to update angle during the final rotation
    curvedAnimation.addListener(() {
      setState(() {
        _angle = tween.evaluate(curvedAnimation);
      });
    });

    // Start the final rotation animation
    _finalRotationController.forward();
  }

  String getChallenge() {
    return challenges[random.nextInt(challenges.length)];
  }

  void _addCustomChallenge() {
    String customChallenge = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Custom Challenge'),
          content: TextField(
            onChanged: (value) {
              customChallenge = value;
            },
            decoration: const InputDecoration(hintText: 'Enter your challenge here'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (customChallenge.isNotEmpty) {
                  setState(() {
                    challenges.add(customChallenge);
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int numPlayers = widget.playerNames.where((name) => name.isNotEmpty).length;
    const double radius = 150;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spin the Bottle'),
        backgroundColor: const Color(0xFF8A2BE2),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCustomChallenge,
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFE4E1), // Constant background
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Show player names around the bottle
            for (int i = 0; i < numPlayers; i++)
              Positioned(
                left: MediaQuery.of(context).size.width / 2 +
                    radius * cos(2 * pi * (i / numPlayers) - pi / 2) - 5,
                top: MediaQuery.of(context).size.height / 2 +
                    radius * sin(2 * pi * (i / numPlayers) - pi / 2) - 40,
                child: Text(
                  widget.playerNames[i],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),

            // The bottle in the center
            Center(
              child: Transform.rotate(
                angle: _angle,
                child: Image.asset(
                  widget.bottleImage,
                  height: 200,
                  width: 200,
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              child: Column(
                children: [
                  selectedPlayerIndex != -1
                      ? Text(
                    'It\'s ${widget.playerNames[selectedPlayerIndex]}\'s turn!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 10),
                  selectedPlayerIndex != -1
                      ? Text(
                    'Challenge: $currentChallenge',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.deepPurple,
                    ),
                  )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: spinBottle,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.rotate_right),
      ),
    );
  }

  @override
  void dispose() {
    _finalRotationController.dispose();
    super.dispose();
  }
}
