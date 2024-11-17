import 'package:flutter/material.dart';
import 'package:yt_bmi_calculator/constantFile.dart';

class card_widget extends StatelessWidget {
  card_widget({required this.iconData, required this.label});
  final IconData iconData;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(
        iconData,
        size: 80.0,
      ),
      SizedBox(
        height: 15.0,
      ),
      Text(
        label,
        style: klabelstyle,
      )
    ]);
  }
}
