import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:lat-long/lat-long.dart';

class Map extends StatelessWidget {
  const Map({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Text('Back', style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
      body: Center(
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your search functionality here
          print('Search button pressed');
        },

        child: Icon(Icons.search),
        backgroundColor: Colors.white, // Customize button color if needed
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,



    );
  }
}
