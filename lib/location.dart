import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' as geocoding;

const String apiKey = 'pk.e9c26940466d145644091d82289a570d';

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
  _FavoriteLocationsScreenState createState() =>
      _FavoriteLocationsScreenState();
}

class _FavoriteLocationsScreenState extends State<FavoriteLocationsScreen> {
  List<FavoriteLocation> favoriteLocations =
      []; // List to store favorite locations

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
              contentPadding: EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0), // Padding for ListTile content
              leading: Icon(Icons.location_on),
              title: Text(favoriteLocations[index].cityName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Comfort Level: ${favoriteLocations[index].comfortLevel}'),
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
  TextEditingController _searchController = TextEditingController();
  List<String> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;

  Future<void> _fetchAutoComplete(String searchTerm) async {
    setState(() => _isLoading = true);
    String apiUrl =
        'https://api.locationiq.com/v1/autocomplete.php?key=$apiKey&q=$searchTerm&limit=5';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<String> suggestions = [];
        for (var item in jsonData) {
          suggestions.add(item['display_name']);
        }
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load suggestions');
      }
    } catch (error) {
      print('Error: $error');
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.length >= 1) {
        _fetchAutoComplete(value);
      } else {
        setState(() {
          _suggestions.clear();
        });
      }
    });
  }

  void _onSubmitted(String value) async {
    FocusScope.of(context).unfocus(); // Close the keyboard
    setState(() => _isLoading = true);
    List<geocoding.Location> locations =
        await geocoding.locationFromAddress(value);
    for (var location in locations) {
      var cityName = value;
      var lat = location.latitude;
      var long = location.longitude;
      // You can add more fields as necessary
      Navigator.pop(
          context,
          FavoriteLocation(
              cityName: cityName,
              temperature: 25,
              comfortLevel: 'High',
              humidity: 60));
      print('Latitude: $lat, Longitude: $long');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Location'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Enter Location Name',
                  suffixIcon: _isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        )
                      : null,
                ),
                onChanged: _onSearchChanged,
                onSubmitted: _onSubmitted,
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_suggestions[index]),
                            onTap: () {
                              _searchController.text = _suggestions[index];
                              _onSubmitted(_suggestions[index]);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}

class FavoriteLocation {
  final String cityName;
  final int temperature;
  final String comfortLevel;
  final int humidity;

  FavoriteLocation(
      {required this.cityName,
      required this.temperature,
      required this.comfortLevel,
      required this.humidity});
}

void main() => runApp(Location());
