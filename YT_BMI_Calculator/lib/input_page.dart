import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yt_bmi_calculator/Icon_text_file.dart';
import 'package:yt_bmi_calculator/constantFile.dart';
import 'package:yt_bmi_calculator/resultfile.dart';
import 'container_file.dart';
import 'calculatorFile.dart';


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
  int sliderheight = 180;
  int sliderweight = 60;
  int sliderage = 20;

    @override
    Widget build(BuildContext context){
          return Scaffold(
            appBar: AppBar(
              title: Text("BMI Calculator"),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Expanded(
                    child: RepeatContainerCode(
                      colors : Color(0xFF1D1E33),
                      cardWidget: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Height",
                            style: klabelstyle,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                sliderheight.toString(),
                                style: klabelstyle2
                              ),
                              Text(
                                "cm",
                                style: klabelstyle,
                              ),

                            ],
                          ),
                          Slider(
                            value: sliderheight.toDouble(),
                            min : 120.0,
                            max : 220.0,
                            activeColor: Color(0xFFEB1555),
                            inactiveColor: Color(0xFF8D8E98),
                            onChanged: (double newValue){
                              setState(() {
                                sliderheight = newValue.round();
                              });
                            },
                          ),

                        ],
                      ),
                    )),
                Expanded(
                    child: Row(
                  children: [
                    Expanded(child: RepeatContainerCode(
                      colors : Color(0xFF1D1E33),
                      cardWidget: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "WEIGHT",
                            style: klabelstyle,
                          ),
                          Text(
                            sliderweight.toString(),
                            style: klabelstyle2,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RoundIcon(
                                iconData: Icons.remove,
                                onPress: (){
                                  setState(() {
                                    sliderweight--;
                                  });
                                },
                              ),
                              SizedBox(width:10.0),
                              RoundIcon(
                                iconData: Icons.add,
                                onPress: (){
                                  setState(() {
                                    sliderweight++;
                                  });
                                },
                              ),

                            ],
                          )
                        ],
                      ),

                    )),
                    Expanded(child: RepeatContainerCode(
                      colors : Color(0xFF1D1E33),
                      cardWidget: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "AGE",
                            style: klabelstyle,
                          ),
                          Text(
                            sliderage.toString(),
                            style: klabelstyle2,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RoundIcon(
                                iconData: Icons.remove,
                                onPress: (){
                                  setState(() {
                                    sliderage--;
                                  });
                                },
                              ),
                              SizedBox(width:10.0),
                              RoundIcon(
                                iconData: Icons.add,
                                onPress: (){
                                  setState(() {
                                    sliderage++;
                                  });
                                },
                              ),

                            ],
                          )
                        ],
                      ),

                    )),
                  ],
                )),
                GestureDetector(
                  onTap: (){
                    CalculatorBrain calc = CalculatorBrain(height: sliderheight, weight: sliderweight);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ResultScreen(
                      bmiResult: calc.calculateBMI(),
                      resultText: calc.getResult(),
                      interpretation: calc.getInterpretation(),

                    )));
                  },
                  child: Container(
                    child: Center(
                        child: Text(
                          "Calculate",
                          style: klargebuttonstyle,
                        )
                    ),
                    color: Color(0xFFEB1555),
                    margin: EdgeInsets.only(top: 10.0),
                    width: double.infinity,
                    height: 80.0,
                  ),
                )
              ],
            )
          );
    }
}


class RoundIcon extends StatelessWidget{
  RoundIcon({
    required this.iconData,
    required this.onPress,
});
  final IconData iconData;
  final VoidCallback? onPress;
  @override
  Widget build(BuildContext context){
    return RawMaterialButton(
      child: Icon(iconData),
      onPressed: onPress,
      elevation: 6.0,
      constraints: BoxConstraints.tightFor(
        height: 56.0,
        width: 56.0,
      ),
      shape: CircleBorder(),
      fillColor: Color(0xFF4C4F5E),
    );
  }
}
