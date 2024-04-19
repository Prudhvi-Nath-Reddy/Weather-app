import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove the debug tag
      title: 'Location Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorite Locations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                LocationCard(
                  locationName: 'Favorite Location 1',
                  humidityLevel: 'Humidity: 70%',
                ),
                LocationCard(
                  locationName: 'Favorite Location 2',
                  humidityLevel: 'Humidity: 65%',
                ),
              ],
            ),
          ),
          Center(
            child: SizedBox(
              width: 200,
              height: 42,
              child: ElevatedButton(
                onPressed: () {
                  // Add your manage location button logic here
                  print('Manage Location button pressed');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Adjust the radius value here
                  ),
                ),
                child: Text(
                  'Manage Locations',
                  style: TextStyle(
                    color: Color(0xFF1F1F1F),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    height: 0.10,
                    letterSpacing: 0.14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Locations',
          ),
        ],
      ),
    );
  }
}

class LocationCard extends StatelessWidget {
  final String locationName;
  final String humidityLevel;

  LocationCard({
    required this.locationName,
    required this.humidityLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.location_on),
        title: Text(locationName),
        subtitle: Text(humidityLevel),
      ),
    );
  }
}
