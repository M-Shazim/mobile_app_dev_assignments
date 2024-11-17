import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yt_bmi_calculator/Icon_text_file.dart';
import 'container_file.dart';
const activeColor = Color(0xFF1D1E33);
const de_activeColor = Color(0xFF111328);

enum Gender{
  male,
  female,
}

class InputPage extends StatefulWidget{
    @override
    _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  Gender? selectGender;

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
                          Expanded(
                              child: RepeatContainerCode(
                                onPressed: (){
                                  setState(() {
                                    selectGender=Gender.male;
                                  });
                                },
                                colors : selectGender==Gender.male?activeColor:de_activeColor,
                              cardWidget: card_widget(
                                iconData: Icons.male,
                                label: "MALE",
                              ),
                              ),
                          ),
                          Expanded(
                              child: RepeatContainerCode(
                                onPressed: (){
                                  setState(() {
                                    selectGender=Gender.female;
                                  });
                                },
                              colors : selectGender==Gender.female?activeColor:de_activeColor,
                              cardWidget: card_widget(
                                iconData: Icons.female,
                                label: "FEMALE",
                              ),
                              ),
                            ),
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
