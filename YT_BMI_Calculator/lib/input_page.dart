import 'package:flutter/material.dart';

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
                          Expanded(child: RepeatContainerCode()),
                          Expanded(child: RepeatContainerCode()),
                  ],
                )
                ),
                Expanded(child: RepeatContainerCode()),
                Expanded(child: Row(
                  children: [
                    Expanded(child: RepeatContainerCode()),
                    Expanded(child: RepeatContainerCode())
                  ],
                )),
              ],
            )
          );
    }
}

class RepeatContainerCode extends StatelessWidget {
  const RepeatContainerCode({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}