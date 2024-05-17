import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'func.dart';
import 'mainpage.dart';
import 'mongodb.dart';

String collectionName = "Assam";
var data; // Specify the collection name

void main() async {
  DateTime now = DateTime.now();
  int hour = now.hour ;
  String end = today();
  String start = befday(end);
  Singleton().mapurl2 = "https://prudhvi.pythonanywhere.com/get_map?start=$start&end=$end&longitude=78.9629&latitude=20.5937&hour=$hour&zoom=5" ;
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primaryColor: Colors.white70,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      home: MainPage(),
    );
  }
}
