// import 'package:app1/constant.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_place/google_place.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'webview.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({Key? key}) : super(key: key);

//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   TextEditingController _searchController = TextEditingController();
//   List<String> _suggestions = []; // List to hold the suggestions
//   bool _isSearchFocused = false;

//   late GooglePlace googlePlace;
//   List<AutocompletePrediction> predictions = [];

//   @override
//   void initState() {
//     super.initState();
//     String apiKey = PLACES_API_KEY;
//     googlePlace = GooglePlace(apiKey);
//     _searchController.addListener(_onSearchChanged);
//   }

//   void autoCompleteSearch(String value) async {
//     var result = await googlePlace.autocomplete.get(value);
//     if (result != null && result.predictions != null && mounted) {
//       print(result.predictions!.first.description);
//       setState(() {
//         predictions = result.predictions!;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     String searchText = _searchController.text;
//     if (searchText.length >= 1) {
//       setState(() {
//         // _suggestions = _getSuggestions(searchText);
//         autoCompleteSearch(searchText);
//       });
//     } else {
//       setState(() {
//         _suggestions.clear();
//       });
//     }
//   }

//   List<String> _getSuggestions(String searchText) {
//     // Dummy logic to generate suggestions. You can replace it with your own logic.
//     List<String> cities = [
//       'New York',
//       'Los Angeles',
//       'Chicago',
//       'Houston',
//       'Phoenix',
//       'Philadelphia',
//       'San Antonio',
//       'San Diego',
//       'Dallas',
//       'San Jose',
//     ];
//     return cities
//         .where((city) => city.toLowerCase().contains(searchText.toLowerCase()))
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           // Search bar
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search...',
//                 border: OutlineInputBorder(),
//               ),
//               onTap: () {
//                 setState(() {
//                   _isSearchFocused = true;
//                 });
//               },
//               onEditingComplete: () {
//                 setState(() {
//                   _isSearchFocused = false;
//                 });
//               },
//               onChanged: (value) {
//                 // Handle search text changes
//                 if (value.isEmpty) {
//                   setState(() {
//                     _isSearchFocused = false;
//                   });
//                 }
//               },
//             ),
//           ),
//           // Suggestions list
//           Visibility(
//             visible: _isSearchFocused && _suggestions.isNotEmpty,
//             child: Expanded(
//               child: ListView.builder(
//                 itemCount: _suggestions.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(_suggestions[index]),
//                     onTap: () {
//                       // Handle when a suggestion is tapped
//                       print('Selected suggestion: ${_suggestions[index]}');
//                       // autoCompleteSearch("Bang");
//                     },
//                   );
//                 },
//               ),
//             ),
//           ),
//           // WebView
//           Expanded(
//             child: MyWebView(
//               selectedUrl:
//                   "https://harsha-deep.github.io/projects/gee-humidity/map1.html",
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Handle the search button press
//           print('Search button pressed');
//         },
//         child: const Icon(Icons.search),
//         backgroundColor: Colors.blue,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//     );
//   }
// }

import 'package:app1/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_place/google_place.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'webview.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> _suggestions = []; // List to hold the suggestions
  bool _isSearchFocused = false;

  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];

  @override
  void initState() {
    super.initState();
    String apiKey = PLACES_API_KEY;
    googlePlace = GooglePlace(apiKey);
    _searchController.addListener(_onSearchChanged);
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String searchText = _searchController.text;
    if (searchText.length >= 1) {
      setState(() {
        autoCompleteSearch(searchText);
      });
    } else {
      setState(() {
        _suggestions.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: Column(
        children: [
          // Search bar
          Visibility(
            visible: _isSearchFocused,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Handle search text changes
                  if (value.isEmpty) {
                    setState(() {
                      _suggestions.clear();
                    });
                  }
                },
              ),
            ),
          ),
          // Suggestions list
          Visibility(
            visible: _isSearchFocused && _suggestions.isNotEmpty,
            child: Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_suggestions[index]),
                    onTap: () {
                      // Handle when a suggestion is tapped
                      print('Selected suggestion: ${_suggestions[index]}');
                    },
                  );
                },
              ),
            ),
          ),
          // WebView
          Expanded(
            child: MyWebView(
              selectedUrl:
                  "https://harsha-deep.github.io/projects/gee-humidity/map1.html",
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isSearchFocused = !_isSearchFocused;
          });
        },
        child: _isSearchFocused ? Icon(Icons.close) : Icon(Icons.search),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
