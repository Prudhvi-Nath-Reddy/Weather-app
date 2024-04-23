import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:lat-long/lat-long.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
class Map extends StatelessWidget {
  const Map({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: const HelpScreen(),
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

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    _controller.loadFlutterAsset('lib/map1.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: _controller),
    );
  }
}