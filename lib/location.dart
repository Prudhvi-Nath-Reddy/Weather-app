import 'package:flutter/material.dart';

class Location extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Favorite Locations',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FavoriteLocationsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FavoriteLocationsScreen extends StatefulWidget {
  @override
  _FavoriteLocationsScreenState createState() => _FavoriteLocationsScreenState();
}

class _FavoriteLocationsScreenState extends State<FavoriteLocationsScreen> {
  List<FavoriteLocation> favoriteLocations = []; // List to store favorite locations

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Locations'),
      ),
      body: ListView.builder(
        itemCount: favoriteLocations.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.all(8.0), // Adding margin on all four sides
            color: Colors.grey[100], // Light blue color
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Padding for ListTile content
              leading: Icon(Icons.location_on),
              title: Text(favoriteLocations[index].cityName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text('Temperature: ${favoriteLocations[index].temperature}°C'),
                  Text('Comfort Level: ${favoriteLocations[index].comfortLevel}'),
                  Text('Humidity: ${favoriteLocations[index].humidity}%'),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    favoriteLocations.removeAt(index);
                  });
                },
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddLocationScreen(context);
        },
        backgroundColor: Colors.blue[100],
        tooltip: 'Manage Locations',
        child: Icon(Icons.add),
      ),
    );
  }

  // Function to navigate to add location screen
  void _navigateToAddLocationScreen(BuildContext context) async {
    final newLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddLocationScreen()),
    );

    if (newLocation != null) {
      setState(() {
        favoriteLocations.add(newLocation);
      });
    }
  }
}

class AddLocationScreen extends StatefulWidget {
  @override
  _AddLocationScreenState createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  List<String> suggestions = ['New York', 'London', 'Paris', 'Tokyo']; // Sample suggestions

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Location'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter Location Name',
              ),
              onChanged: (value) {
                // Filter suggestions based on user input
                setState(() {
                  suggestions = [
                    'New York',
                    'London',
                    'Paris',
                    'Tokyo'
                  ].where((location) => location.toLowerCase().startsWith(value.toLowerCase())).toList();
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(suggestions[index]),
                    onTap: () {
                      // Handle selection of location
                      Navigator.pop(context, FavoriteLocation(cityName: suggestions[index], temperature: 25, comfortLevel: 'High', humidity: 60));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteLocation {
  final String cityName;
  final int temperature;
  final String comfortLevel;
  final int humidity;

  FavoriteLocation({required this.cityName, required this.temperature, required this.comfortLevel, required this.humidity});
}
