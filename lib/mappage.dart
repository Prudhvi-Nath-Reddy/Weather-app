import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:webview_flutter/webview_flutter.dart';
import 'webview.dart';
import 'func.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> _suggestions = [];
  bool _isLoading = false;
  bool _isSearchFocused = false;
  late String _mapUrl;

  @override
  void initState() {
    super.initState();
    _mapUrl = Singleton().mapurl2; // Initial URL if needed
  }

  void setUrl(start, end, long, lat, hour, zoom) {
    setState(() {
      _mapUrl = "https://prudhvi.pythonanywhere.com/get_map?start=$start&end=$end&longitude=$long&latitude=$lat&hour=$hour&zoom=$zoom";
    });
  }

  Future<void> _fetchAutoComplete(String searchTerm) async {
    setState(() => _isLoading = true);
    String apiUrl = 'https://api.locationiq.com/v1/autocomplete?key=pk.e9c26940466d145644091d82289a570d&q=$searchTerm&limit=5';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<String> suggestions = [];
        for (var item in jsonData) {
          suggestions.add(item['display_place']);
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
    if (value.length >= 1) {
      _fetchAutoComplete(value);
    } else {
      setState(() {
        _suggestions.clear();
      });
    }
  }

  void _onSubmitted(String value) async {
    setState(() => _isLoading = true);
    List<geocoding.Location> locations = await geocoding.locationFromAddress(value);
    String end = today();
    String start = befday(end);
    DateTime now = DateTime.now();
    int hour = now.hour;
    for (var location in locations) {
      var long = location.longitude;
      var lat = location.latitude;
      setUrl(start, end, long, lat, hour, 8);
      print('Latitude: $lat, Longitude: $long');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _isSearchFocused ? 80.0 : 0.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                ),
                style: TextStyle(fontSize: 18.0),
                onChanged: _onSearchChanged,
                onSubmitted: _onSubmitted,
              ),
            ),
          ),
          Visibility(
            visible: _isSearchFocused && _suggestions.isNotEmpty,
            child: Expanded(
              child: ListView.builder(
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
          ),
          if (_isLoading)
            Expanded(child: Center(child: CircularProgressIndicator())),
          if (!_isLoading)
            Expanded(
              child: MyWebView(
                selectedUrl: _mapUrl,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isSearchFocused = !_isSearchFocused;
            if (!_isSearchFocused) {
              _searchController.clear();
              _suggestions.clear();
            }
          });
        },
        child: _isSearchFocused ? Icon(Icons.close) : Icon(Icons.search),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
