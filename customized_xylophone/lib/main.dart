import 'package:flutter/material.dart';
import 'settings_screen.dart'; // Ensure this file exists and is correctly named
import 'xylophone_key.dart';
import 'sound_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(XylophoneApp());
}

class XylophoneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xylophone',
      home: XylophoneHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class XylophoneHome extends StatefulWidget {
  @override
  _XylophoneHomeState createState() => _XylophoneHomeState();
}

class _XylophoneHomeState extends State<XylophoneHome> {
  final SoundManager soundManager = SoundManager(); // Initialize SoundManager here
  List<Color> colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.teal,
    Colors.blue,
    Colors.purple,
  ];

  List<int> soundNumbers = [1, 2, 3, 4, 5, 6, 7];

  // Update color method
  void updateColor(int index, Color newColor) {
    setState(() {
      colors[index] = newColor; // Update color in the main page state
    });
  }

  // Update sound number method
  void updateSoundNumber(int index, int newSoundNumber) {
    setState(() {
      soundNumbers[index] = newSoundNumber; // Update sound number in the main page state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customizable Xylophone'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    colors: colors,
                    soundNumbers: soundNumbers,
                    onUpdateColors: updateColor,
                    onUpdateSoundNumbers: updateSoundNumber,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.teal.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(7, (index) {
              return XylophoneKey(
                color: colors[index],
                soundNumber: soundNumbers[index],
                soundManager: soundManager, // Pass soundManager here
              );
            }),
          ),
        ),
      ),
    );
  }
}
