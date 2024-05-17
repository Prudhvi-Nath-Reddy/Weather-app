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
  late String _currentDate; // yyyy-mm-dd format

  @override
  void initState() {
    super.initState();
    _mapUrl = Singleton().mapurl2;
    _currentDate = Singleton().bardate;
  }

  void setUrl(start, end, long, lat, hour, zoom) {
    setState(() {
      Singleton().mapurl2 =
          "https://prudhvi.pythonanywhere.com/get_map?start=$start&end=$end&longitude=$long&latitude=$lat&hour=$hour&zoom=$zoom";
      _mapUrl =
          "https://prudhvi.pythonanywhere.com/get_map?start=$start&end=$end&longitude=$long&latitude=$lat&hour=$hour&zoom=$zoom";
    });
  }

  Future<void> _fetchAutoComplete(String searchTerm) async {
    setState(() => _isLoading = true);
    String apiUrl =
        'https://api.locationiq.com/v1/autocomplete?key=pk.e9c26940466d145644091d82289a570d&q=$searchTerm&limit=5';

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
    FocusScope.of(context).unfocus(); // Close the keyboard
    setState(() => _isLoading = true);
    List<geocoding.Location> locations =
        await geocoding.locationFromAddress(value);
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
    _toggleSearch(); // Close search bar after submitting
  }

  void _toggleSearch() {
    setState(() {
      _isSearchFocused = !_isSearchFocused;
      if (!_isSearchFocused) {
        _searchController.clear();
        _suggestions.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: Stack(
        children: [
          Column(
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
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 20.0),
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
                  child: KeyedSubtree(
                    key: ValueKey<String>(_mapUrl),
                    child: MyWebView(
                      selectedUrl: _mapUrl,
                    ),
                  ),
                ),
            ],
          ),
          Positioned(
            bottom: 60, // Raises the buttons up from the bottom
            left: 50, // Start further in from the left edge
            right: 50, // End further in from the right edge
            child: Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceAround, // Centers and reduces the space around
              children: [
                FloatingActionButton.small(
                  onPressed: () {
                    setState(() {
                      Singleton().bardate = befday(_currentDate);
                      _currentDate = Singleton().bardate;
                      var end = _currentDate;
                      var start = befday(_currentDate);
                      DateTime now = DateTime.now();
                      int hour = now.hour;
                      setUrl(start, end, 78.9629, 20.5937, hour, 5);
                    });
                  },
                  child: Icon(Icons.arrow_left),
                ),
                Text(_currentDate),
                FloatingActionButton.small(
                  onPressed: () {
                    String todayDate =
                        today(); // Ensure this returns the date in "yyyy-mm-dd" format
                    if (_currentDate != todayDate) {
                      setState(() {
                        Singleton().bardate = nexday(
                            _currentDate); // Assume nexday() correctly calculates the next day
                        _currentDate = Singleton().bardate;
                        var end = _currentDate;
                        var start = befday(_currentDate);
                        DateTime now = DateTime.now();
                        int hour = now.hour;
                        setUrl(start, end, 78.9629, 20.5937, hour, 5);
                      });
                    }
                  },
                  child: Icon(Icons.arrow_right),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleSearch,
        child: _isSearchFocused ? Icon(Icons.close) : Icon(Icons.search),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
