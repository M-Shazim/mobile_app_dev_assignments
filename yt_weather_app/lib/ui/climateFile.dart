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
              image: AssetImage("Images/freezy.jpg"),
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
          )
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
  )
}