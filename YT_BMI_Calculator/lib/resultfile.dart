import 'package:flutter/material.dart';
import 'package:yt_bmi_calculator/container_file.dart';
import 'constantFile.dart';
import 'input_page.dart';

class ResultScreen extends StatelessWidget {

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
                    "Normal",
                    style: klabelstyle,
                  ),
                  Text(
                    "20.6",
                    style: kTitleStyleS2,

                  ),
                  Text(
                    "BMI is low",
                    style: klabelstyle2,

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
