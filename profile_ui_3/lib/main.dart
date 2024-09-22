import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                // Simple Profile Image Section without any clipping
                Image.network(
                  'https://images.pexels.com/photos/255379/pexels-photo-255379.jpeg?cs=srgb&dl=pexels-padrinan-255379.jpg&fm=jpg',
                  height: 400,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Upper Buttons (Back and Options)
                Positioned(
                  top: 20,
                  left: 20,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      // Back button action
                    },
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {
                      // Options button action
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Profile Name and Location
            Text(
              'Tanya Nguyen',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.grey,
                  size: 20,
                ),
                SizedBox(width: 4),
                Text(
                  'London, UK',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Description Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Hashtag Buttons
            Wrap(
              spacing: 10,
              children: [
                Chip(
                  label: Text('#photography'),
                  backgroundColor: Colors.grey[200],
                ),
                Chip(
                  label: Text('#fashion'),
                  backgroundColor: Colors.grey[200],
                ),
              ],
            ),
            Spacer(),

            // Bottom Icons (Navigation or action icons)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.home),
                  color: Colors.grey,
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  color: Colors.grey,
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.person),
                  color: Colors.grey,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
