import 'package:flutter/material.dart';
import 'package:yt_bmi_calculator/container_file.dart';
import 'constantFile.dart';
import 'input_page.dart';
import 'calculatorFile.dart';

class ResultScreen extends StatelessWidget {

  ResultScreen({required this.bmiResult,required this.resultText, required this.interpretation});

  final String bmiResult;
  final String resultText;
  final String interpretation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Result Screen"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              child: Center(
                child: Text(
                  "Your Result",
                  style: kTitleStyleS2,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: RepeatContainerCode(
              colors: activeColor,
              cardWidget: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    resultText.toUpperCase(),
                    style: klabelstyle,
                  ),
                  Text(
                    bmiResult,
                    style: kTitleStyleS2,

                  ),
                  Text(
                    interpretation,
                    style: klabelstyle,

                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context)=>InputPage()));
              },
              child: Container(
                child: Center(
                    child: Text(
                      "Re-Calculate",
                      style: klargebuttonstyle,
                    )
                ),
                color: Color(0xFFEB1555),
                margin: EdgeInsets.only(top: 10.0),
                width: double.infinity,
                height: 80.0,
              ),
            ),

          ),

        ],
      ),
    );
  }
}
