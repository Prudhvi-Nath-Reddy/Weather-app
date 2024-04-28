import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'mainpage.dart';
import 'mongodb.dart';

String collectionName = "Assam";
var data; // Specify the collection name

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();  // Ensure Flutter bindings are initialized
  // var location = await fetchLocation();
  // location ??= "Delhi";
  // collectionName = location ;
  // var mongo = MongoDatabase(location);
  // data = await mongo.connect();
  // // print(data);
  runApp(MyApp());
}

// Future<String?> fetchLocation() async {
//   bool serviceEnabled;
//   LocationPermission permission;
//
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     return 'Location services are disabled.';
//   }
//
//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       return 'Location permissions are denied';
//     }
//   }
//   if (permission == LocationPermission.deniedForever) {
//     return 'Location permissions are permanently denied, we cannot request permissions.';
//   }
//
//   try {
//     Position position = await Geolocator.getCurrentPosition();
//     List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
//     Placemark place = placemarks[0];
//     return place.administrativeArea; // or any other location detail you need
//   } catch (e) {
//     return "Failed to get location";
//   }
// }

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
