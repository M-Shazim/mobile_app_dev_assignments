import 'package:flutter/material.dart';
import '../utils/apiFile.dart' as util;
import 'package:http/http.dart' as http;
import "dart:convert";


class Climate extends StatefulWidget {

  @override
  State<Climate> createState() => _ClimateState();
}

class _ClimateState extends State<Climate> {
  void showStuff() async{
    Map data = await getWeather(util.appId,  util.defaultCity);
    print(data.toString());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather App"),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: ()=> showStuff(),
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
              util.defaultCity,
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
            alignment: Alignment.center,
            // margin: EdgeInsets.fromLTRB(100.0, 420.0, 0.0, 0.0),
            child: updateTempWidget(util.defaultCity),
          ),
        ],
      ),
    );
  }

  Future<Map> getWeather(String appId, String city) async {
    String apiUrl = "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$appId";
    // String apiUrl = "https://api.openweathermap.org/data/2.5/weather?lat=30.045246&lon=72.348869&appid=${util.appId}";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {"error": "Error: ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": e.toString()};
    }
  }




  Widget updateTempWidget(String city) {
    return FutureBuilder(
      future: getWeather(util.appId, city ?? util.defaultCity),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while waiting for data
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          // Provide a default empty map if data is null
          Map content = snapshot.data ?? {};

          // Safely access keys with null-aware operators
          double temp = content["main"]?["temp"] ?? 0.0;
          int humidity = content["main"]?["humidity"] ?? 0;
          double tempMin = content["main"]?["temp_min"] ?? 0.0;
          double tempMax = content["main"]?["temp_max"] ?? 0.0;

          return Container(
            margin: const EdgeInsets.fromLTRB(30.0, 250.0, 0.0, 0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListTile(
                  title: Text(
                    "$temp F",
                    style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontSize: 49.9,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: ListTile(
                    title: Text(
                      "Humidity: $humidity\n"
                          "Min: $tempMin F\n"
                          "Max: $tempMax F",
                      style: extraData(),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        } else {
          return Center(
            child: Text(
              "No data available",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }
      },
    );
  }


// Widget updateTempWidget(String city){
  //   return FutureBuilder(
  //     future: getWeather(util.appId, city == null ? util.defaultCity:city),
  //     builder: (BuildContext context, AsyncSnapshot<Map> snapshot){
  //       if(snapshot.hasData){
  //         Map content = snapshot.data;
  //         return new Container(
  //           margin: const EdgeInsets.fromLTRB(30.0, 250.0, 0.0, 0.0),
  //           child: new Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               new ListTile(
  //                 title: new Text(
  //                   content["main"]["temp"].toString() + "F",
  //                   style: new TextStyle(
  //                     fontStyle: FontStyle.normal,
  //                     fontSize: 49.9,
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //                 subtitle: new ListTile(
  //                   title: new Text(
  //                     "Humidity: ${content["main"]["humidity"].toString()}\n"
  //                     "Min: ${content["main"]["temp_min"].toString()} F\n"
  //                     "Max: ${content["main"]["temp_max"].toString()} F",
  //
  //                     style: extraData(),
  //                   ),
  //                 ),
  //               )
  //             ],
  //           ),
  //         );
  //
  //       }
  //       else{
  //         return Container();
  //       }
  //     }
  //   );
  // }
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

TextStyle extraData(){
  return TextStyle(
    color: Colors.white70, fontStyle: FontStyle.normal, fontSize: 17.0,
  );
}



