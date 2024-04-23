import 'package:flutter/material.dart';
import 'mainpage.dart'; // Import MainPage
import 'mongodb.dart';
void main() async{
  MongoDatabase md = MongoDatabase();
  await md.connect();
  print(retval);
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
      home: MainPage(), // Pointing to MainPage as the home
    );
  }
}
