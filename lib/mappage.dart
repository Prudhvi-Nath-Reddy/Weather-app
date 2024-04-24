import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'webview.dart' ;
class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: MyWebView(
        selectedUrl: "https://harsha-deep.github.io/projects/gee-humidity/map1.html",
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {

          print('Search button pressed');
        },
        child: const Icon(Icons.search),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}


