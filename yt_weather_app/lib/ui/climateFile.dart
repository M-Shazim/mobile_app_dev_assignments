import 'package:flutter/material.dart';
import '../utils/apiFile.dart' as util;
import 'package:http/http.dart' as http;
import 'dart:convert';

class Climate extends StatefulWidget {
  @override
  State<Climate> createState() => _ClimateState();
}

class _ClimateState extends State<Climate> {

  bool isFahrenheit = true;

  // Function to convert temperature from Kelvin to Celsius
// Function to convert temperature from Kelvin to Celsius with rounding
  double kelvinToCelsius(double kelvin) {
    return (kelvin - 273.15); // Return as double
  }

// Function to convert temperature from Kelvin to Fahrenheit with rounding
  double kelvinToFahrenheit(double kelvin) {
    return (kelvin - 273.15) * 9 / 5 + 32; // Return as double
  }

  // Function to toggle between Fahrenheit and Celsius
  void toggleUnit() {
    setState(() {
      isFahrenheit = !isFahrenheit;
    });
  }

  void showStuff() async {
    Map data = await getWeather(util.appId, util.defaultCity);
    print(data.toString());
  }


  String selectedCity = util.defaultCity; // Default city
  TextEditingController searchController = TextEditingController();
  List<String> allCities = [
    "London", "New York", "Tokyo", "Delhi", "Paris", "Sydney", "Vehari",
    "Lahore", "Karachi", "Beijing", "Moscow", "Berlin", "Madrid", "Rome",
    "San Francisco", "Los Angeles", "Chicago", "Houston", "Miami", "Dubai",
    "Bangkok", "Seoul", "Istanbul", "Singapore", "Johannesburg", "Nairobi",
    "Toronto", "Vancouver", "Mexico City", "Rio de Janeiro", "Buenos Aires",
  ]; // Complete list of cities
  List<String> filteredCities = [];
  ScrollController _scrollController = ScrollController(); // ScrollController

  @override
  void initState() {
    super.initState();
    filteredCities = allCities; // Initialize filtered list
  }

  void _filterCities(String query) {
    setState(() {
      filteredCities = allCities
          .where((city) => city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectCity(String city) {
    setState(() {
      selectedCity = city;
    });
    Navigator.pop(context); // Close the drawer
  }

  Future<Map> getWeather(String appId, String city) async {
    String apiUrl =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$appId";

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
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          Map content = snapshot.data ?? {};

          double tempKelvin = content["main"]?["temp"] ?? 0.0;
          double temp = isFahrenheit
              ? kelvinToFahrenheit(tempKelvin)
              : kelvinToCelsius(tempKelvin);
          int humidity = content["main"]?["humidity"] ?? 0;
          double tempMin = isFahrenheit
              ? kelvinToFahrenheit(content["main"]?["temp_min"] ?? 0.0)
              : kelvinToCelsius(content["main"]?["temp_min"] ?? 0.0);
          double tempMax = isFahrenheit
              ? kelvinToFahrenheit(content["main"]?["temp_max"] ?? 0.0)
              : kelvinToCelsius(content["main"]?["temp_max"] ?? 0.0);

          return Container(
            margin: const EdgeInsets.fromLTRB(30.0, 250.0, 0.0, 0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListTile(
                  title: Text(
                    "${temp.toStringAsFixed(1)}${isFahrenheit ? '°F' : '°C'}",
                    // Format temperature with one decimal place
                    style: tempStyle(),
                  ),
                  subtitle: ListTile(
                    title: Text(
                      "Humidity: $humidity\n"
                          "Min: ${tempMin.toStringAsFixed(1)}${isFahrenheit
                          ? '°F'
                          : '°C'}\n"
                          "Max: ${tempMax.toStringAsFixed(1)}${isFahrenheit
                          ? '°F'
                          : '°C'}",
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


  @override



  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Weather App",
          style: TextStyle(
            fontFamily: 'Poppins', // Modern, clean font
            fontWeight: FontWeight.w700, // Bold for better visibility
            fontSize: 28.0,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent, // Gradient from blue to blueAccent
        elevation: 6.0, // Slight elevation for a sleek look
        actions: [
          IconButton(
            icon: Icon(Icons.thermostat, color: Colors.white), // Icon color to match app bar
            onPressed: toggleUnit,
            tooltip: 'Toggle Temperature Unit',
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlue], // Soft gradient for the header
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Center(
                child: Text(
                  "Select a City",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search city...",
                  prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                onChanged: _filterCities,
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: _scrollController, // Attach ScrollController
                thumbVisibility: true, // Always show scrollbar
                child: ListView.builder(
                  controller: _scrollController, // Attach the ScrollController
                  itemCount: filteredCities.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        filteredCities[index],
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      onTap: () => _selectCity(filteredCities[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image(
              image: AssetImage("images/moderate.jpg"),
              fit: BoxFit.cover,
              opacity: AlwaysStoppedAnimation(0.5), // Set opacity to 0.5 for better visibility
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.fromLTRB(0.0, 30.0, 20.0, 0.0),
            child: Text(
              selectedCity,
              style: TextStyle(
                fontSize: 34.0, // Larger text for better visibility
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(offset: Offset(1, 1), blurRadius: 5, color: Colors.black38),
                ], // Shadow for contrast
              ),
            ),
          ),
          Center(
            child: Image(
              image: AssetImage("images/raining.png"),
              height: 200.0,
              width: 200.0, // Slightly larger image
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: updateTempWidget(selectedCity),
            ),
          ),
        ],
      ),
    );
  }




  TextStyle cityStyle() {
    return TextStyle(
      color: Colors.white,
      fontSize: 28.0,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
      letterSpacing: 1.2,
    );
  }

  TextStyle tempStyle() {
    return TextStyle(
      color: Colors.white,
      fontSize: 50.0,
      fontWeight: FontWeight.w700,
      fontFamily: 'Roboto',
    );
  }

  TextStyle extraData() {
    return TextStyle(
      color: Colors.white70,
      fontStyle: FontStyle.normal,
      fontSize: 18.0,
      fontWeight: FontWeight.w400,
    );
  }
}
