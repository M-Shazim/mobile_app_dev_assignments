import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Make sure to add this package to pubspec.yaml

class SettingsScreen extends StatelessWidget {
  final List<Color> colors;
  final List<int> soundNumbers;
  final Function(int, Color) onUpdateColors; // Update to use proper type
  final Function(int, int) onUpdateSoundNumbers; // Update to use proper type

  SettingsScreen({
    required this.colors,
    required this.soundNumbers,
    required this.onUpdateColors,
    required this.onUpdateSoundNumbers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customize Xylophone'),
      ),
      body: ListView.builder(
        itemCount: colors.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  color: colors[index],
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Block:  ${colors[index]}'),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.color_lens),
              onPressed: () async {
                Color? pickedColor = await showDialog<Color>(
                  context: context,
                  builder: (BuildContext context) {
                    Color tempColor = colors[index]; // Use the current color
                    return AlertDialog(
                      title: Text('Pick a color'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: tempColor,
                          onColorChanged: (Color color) {
                            tempColor = color; // Change color to picked color
                          },
                          showLabel: true,
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Select'),
                          onPressed: () {
                            Navigator.of(context).pop(tempColor);
                          },
                        ),
                      ],
                    );
                  },
                );

                if (pickedColor != null) {
                  onUpdateColors(index, pickedColor); // Call the update function to change the color
                }
              },
            ),
            subtitle: DropdownButton<int>(
              value: soundNumbers[index],
              items: List.generate(7, (soundIndex) {
                return DropdownMenuItem<int>(
                  value: soundIndex + 1,
                  child: Text('Sound ${soundIndex + 1}'),
                );
              }),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  onUpdateSoundNumbers(index, newValue); // Call the update function to change the sound number
                }
              },
            ),
          );
        },
      ),
    );
  }
}
