import 'package:flutter/material.dart';


class Climate extends StatefulWidget {

  @override
  State<Climate> createState() => _ClimateState();
}

class _ClimateState extends State<Climate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather App"),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: ()=>print("Clicked"),
          )
        ],

      ),
      body: Stack(
        children: [
          Center(
            child: Image(
              image: AssetImage("images/moderate.jpg"),
              height: 1200.0,
              width: 600.0,
              fit: BoxFit.fill,
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 0.0),
            child: Text(
              "Vehari",
              style: cityStyle(),
            ),
          ),
          Center(
            child: Image(
              image: AssetImage("images/raining.png"),
              height: 200,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(100.0, 420.0, 0.0, 0.0),
            child: Text(
              "50.32F",
              style: tempStyle(),
            ),
          ),
        ],
      ),
    );
  }
}


TextStyle cityStyle(){
  return TextStyle(
    color: Colors.white,
    fontSize: 22.9,
    fontStyle: FontStyle.italic,
  );
}

TextStyle tempStyle(){
  return TextStyle(
    color: Colors.white,
    fontSize: 49.9,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w500,
  );
}

