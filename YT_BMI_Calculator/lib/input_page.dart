import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InputPage extends StatefulWidget{
    @override
    _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
    @override
    Widget build(BuildContext context){
          return Scaffold(
            appBar: AppBar(
              title: Text("BMI Calculator"),
            ),
            body: Column(
              children: [
                Expanded(
                    child: Row(
                      children: [
                          Expanded(child: RepeatContainerCode(
                              colors : Color(0xFF1D1E33),
                            cardWidget: card_widget(
                              iconData: Icons.male,
                              label: "MALE",
                            ),
                          ),),
                          Expanded(child: RepeatContainerCode(
                            colors : Color(0xFF1D1E33),
                            cardWidget: card_widget(
                              iconData: Icons.female,
                              label: "FEMALE",
                            ),

                          ),),
                  ],
                )
                ),
                Expanded(child: RepeatContainerCode(colors : Color(0xFF1D1E33))),
                Expanded(child: Row(
                  children: [
                    Expanded(child: RepeatContainerCode(colors : Color(0xFF1D1E33))),
                    Expanded(child: RepeatContainerCode(colors : Color(0xFF1D1E33)))
                  ],
                )),
              ],
            )
          );
    }
}

class card_widget extends StatelessWidget {
  card_widget({required this.iconData,required this.label});
  final IconData iconData;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          iconData,
          size: 80.0,
        ),
        SizedBox(
          height: 15.0,
        ),
        Text(label,style: TextStyle(
          fontSize: 18.0
        ),)
      ]


    );
  }
}

class RepeatContainerCode extends StatelessWidget {
  RepeatContainerCode({required this.colors, this.cardWidget});
  final Color colors;
  final Widget? cardWidget;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15.0),
      child: cardWidget,
      decoration: BoxDecoration(
        color: colors,
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}