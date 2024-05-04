import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CurrentLocDate(),
            CurrentWeatherSection(),
            DailyTips(),
            Expanded(child: WeeklyForecastList()),
          ],
        ),
      ),

    );
  }
}

class CurrentLocDate extends StatefulWidget {
  const CurrentLocDate({super.key});

  @override
  State<CurrentLocDate> createState() => _CurrentLocDateState();
}

class _CurrentLocDateState extends State<CurrentLocDate> {
  String _currentLocation = 'Fetching location...';
  Map<String, int> regionCodes = {
    'Andaman and Nicobar Islands': 1484,
    'Andhra Pradesh': 1485,
    'Assam': 1487,
    'Delhi': 1489,
    'Goa': 1490,
    'Gujarat': 1491,
    'Haryana': 1492,
    'Himachal Pradesh': 1493,
    'Karnataka': 1494,
    'Kerala': 1495,
    'Lakshadweep': 1496,
    'Maharashtra': 1498,
    'Manipur': 1500,
    'Meghalaya': 1501,
    'Mizoram': 1502,
    'Nagaland': 1503,
    'Orissa': 1504,
    'Punjab': 1505,
    'Rajasthan': 1506,
    'Sikkim': 1507,
    'Tamil Nadu': 1508,
    'Tripura': 1509,
    'West Bengal': 1511,
    'Arunachal Pradesh': 70072,
    'Bihar': 70073,
    'Chandigarh': 70074,
    'Chhattisgarh': 70075,
    'Dadra and Nagar Haveli': 70076,
    'Daman and Diu': 70077,
    'Jharkhand': 70078,
    'Madhya Pradesh': 70079,
    'Puducherry': 70080,
    'Uttar Pradesh': 70081,
    'Uttarakhand': 70082,
    'Telangana': 1485, // Note: Telangana has the same code as Andhra Pradesh.
  };

  @override
  void initState() {
    super.initState();
    _determinePosition();

  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentLocation = 'Location services are disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentLocation = 'Location permissions are denied';
        });
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      setState(() {
        _currentLocation = 'Location permissions are permanently denied, we cannot request permissions.';
      });
      return;
    }
    // When we reach here, permissions are granted and we can continue accessing the device's location.
    Position position = await Geolocator.getCurrentPosition();
    try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        Placemark place = placemarks[0];
        // print(place) ;
      // Use the geocoding package for reverse geocoding
      List<Map<String, String?>> locationAttributes = [
        // {'name': place.name},
        // {'street': place.street},
        {'sublocality': place.subLocality},
        {'locality': place.locality},
        {'subAdministrativeArea': place.subAdministrativeArea},
        {'administrativeArea': place.administrativeArea}
      ];

      // Sort the location attributes by their importance
      locationAttributes.sort((a, b) {
        if ((a.values.first ?? '').isEmpty && !(b.values.first ?? '').isEmpty) {
          return 1;
        } else if (!(a.values.first ?? '').isEmpty && (b.values.first ?? '').isEmpty) {
          return -1;
        } else {
          return 0;
        }
      });

      // Extract the top 2 non-empty attributes
      List<String> topAttributes = [];
      for (var attribute in locationAttributes) {
        if ((attribute.values.first ?? '').isNotEmpty) {
          topAttributes.add(attribute.values.first!);
        }
        if (topAttributes.length >= 2) {
          break;
        }
      }

      // Join the top attributes and update the state
      setState(() {
        _currentLocation = topAttributes.join(', ');
      });
    } catch (e) {
      setState(() {
        _currentLocation = "Failed to get location";
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    // print("hi") ;
    // _determinePosition() ;
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.black),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentLocation,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CurrentWeatherSection extends StatefulWidget {
  const CurrentWeatherSection({Key? key}) : super(key: key);

  @override
  _CurrentWeatherSectionState createState() => _CurrentWeatherSectionState();
}

class _CurrentWeatherSectionState extends State<CurrentWeatherSection> {

  String hl = "--.--%" ;
  String comfort  = "----";


  @override
  void initState() {
    super.initState();
    // someFunction();
    determineLevel() ;

  }

  Future<void> determineLevel() async {
    await someFunction() ;
    String s = hl ;

    String rets ;
    double value = double.tryParse(s) ?? 0.0;
    if (value >= 0 && value <= 40) {
      rets =  "Low";
    } else if (value > 40 && value <= 70) {
      rets = "Moderate";
    } else {
      rets =  "High";
    }
    setState(() {
      comfort = rets ;
    });
  }
  Future<double> fetchHumidity(String start, String end,int hour, double longitude, double latitude) async {
    final response = await http.get(
      Uri.parse('http://prudhvi.pythonanywhere.com/get_humidity?start=$start&end=$end&hour=$hour&longitude=$longitude&latitude=$latitude'),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var humidity = jsonResponse['humidity'];

      print('Humidity: $humidity');
      return humidity.toDouble() ;
      // print('Humidity type: ${humidity.runtimeType}');
      // print("success") ;
      // hl = humidity ;
    } else {
      print('Failed to fetch humidity data.');
      return 0.0;
    }
  }
  Future<void> someFunction() async {
    DateTime now = DateTime.now();
    int hour = now.hour ;
    String start = "2023-04-01";
    String end = "2023-04-02";
    Position position = await Geolocator.getCurrentPosition();

    double rets = await fetchHumidity(start, end,hour, position.longitude, position.latitude);
    setState(()
    {
      hl = rets.toStringAsFixed(2);
    });
    return ;
  }

  @override
  Widget build(BuildContext context) {
    var s = hl;
    DateTime now = DateTime.now();
    var _currentDateTime = DateFormat.yMMMMd('en_US').add_jm().format(now);


    int year = now.year;
    int month = now.month;
    int day = now.day;
    // // For hours in 24-hour format, you can use the `hour` property directly.
    int hours = now.hour;
    // int minutes = now.minute;

    int wname = now.weekday ;
    // Printing each component to check
    // print("Weekday: $wname" ) ;
    // print("Year: $year");
    // print("Month: $month");
    // print("Day: $day");
    // print("Time: $hours");
    // var s = data[0]["humidity"][hours].toStringAsFixed(0);
    // someFunction() ;
    // comfort = determineLevel(s);
    return Container(
      margin: const EdgeInsets.only(left: 16.0, right: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(

        color: Colors.blueAccent,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        // border: Border.all(
        //   color: Colors.white, // Color of the border
        //   width: 8.0, // Width of the border
        // ),
      ),
      child: Column(
        children: [
          Text(
            _currentDateTime,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.energy_savings_leaf, color: Colors.white),
              const SizedBox(width: 5),
              Text(
                'Comfort level: '+comfort,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.water_drop, color: Colors.white),
              const SizedBox(width: 5),
              Text(
                'Humidity: '+s+'%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(Icons.thermostat, color: Colors.white,size: 100,),
              const SizedBox(height: 10),
              Text(

                '28',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white,fontSize: 70),

              ),
            ],
          ),
        ],
      ),
    );
  }
}


class DailyTips extends StatelessWidget {
  const DailyTips({super.key});

  @override
  Widget build(BuildContext context) {
    // This would be where your list of weekly forecasts goes
    return Container(
      margin: const EdgeInsets.only(left: 16.0, right: 16.0,top: 16.0,bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration:BoxDecoration(

        color: Colors.white54,
        border: Border.all(
          width: 2 ,
          color: Colors.black ,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),

      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Today's Temperature",
              ),


            ],
          ),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Almost as same as Yesterday",
              ),

            ],
          ),

        ],
      ),

    );
  }
}
class WeeklyForecastList extends StatefulWidget {
  const WeeklyForecastList({super.key});

  @override
  _WeeklyForecastListState createState() => _WeeklyForecastListState();
}
String determineLevel2(double T, double RH) {
  String s = "---" ;
  double c1 = -42.379;
  double c2 = 2.04901523;
  double c3 = 10.14333127;
  double c4 = -0.22475541;
  double c5 = -6.83783e-3;
  double c6 = -5.481717e-2;
  double c7 = 1.22874e-3;
  double c8 = 8.5282e-4;
  double c9 = -1.99e-6;

  double HI = (c1 + (c2 * T) + (c3 * RH) + (c4 * T * RH) + (c5 * T * T) +
      (c6 * RH * RH) + (c7 * T * T * RH) + (c8 * T * RH * RH) +
      (c9 * T * T * RH * RH));
  if(HI <=80)
    {
      s = "Safe" ;
    }
  else if(HI <=90)
  {
    s = "Caution" ;
  }
  else if(HI <=103)
  {
    s = "Extreme Caution" ;
  }
  else if(HI <=124)
  {
    s = "Danger" ;
  }
  else if(HI > 124)
  {
    s = "Extreme Danger" ;
  }
  return s;
}
class _WeeklyForecastListState extends State<WeeklyForecastList> {
  int weekday = DateTime.now().weekday;
  List<String> humidities = ["------","------","------","------","------","------","------"] ;
  @override
  void initState() {
    super.initState();
    print("cp 1");
    someFunction().then((_) {
      print("all done");
    });
  }

  Future<String> determineLevel(value) async {
    String rets = "unable to find" ;
    if (value >= 0 && value <= 50) {
      rets =  "Low";
    } else if (value > 50 && value <= 70) {
      rets = "Moderate";
    } else {
      rets =  "High";
    }
    return rets ;

  }
  Future<double> fetchHumidity(String start, String end,int hour, double longitude, double latitude) async {
    final response = await http.get(
      Uri.parse('http://prudhvi.pythonanywhere.com/get_humidity?start=$start&end=$end&hour=$hour&longitude=$longitude&latitude=$latitude'),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var humidity = jsonResponse['humidity'];

      // print('Humidity: $humidity');
      return humidity.toDouble() ;
      // print('Humidity type: ${humidity.runtimeType}');
      // print("success") ;
      // hl = humidity ;
    } else {
      print('Failed to fetch humidity data.');
      return 0.0 ;
    }
  }

  Future<void> someFunction() async {
    print("cp 2") ;
    DateTime now = DateTime.now();
    int hour = now.hour;
    String start = "2023-04-01";
    String end = "2023-04-02";
    DateTime startDate = DateTime.parse(start);
    DateTime previousDate = startDate.subtract(Duration(days: 1));
    String prev = DateFormat('yyyy-MM-dd').format(previousDate);
    print("cp 2.1") ;
    Position position = await Geolocator.getCurrentPosition();
    double hm1 = await fetchHumidity(prev, start, hour, position.longitude, position.latitude);
    List<String> newHumidities = ["------","------","------","------","------","------","------"] ;
    print("cp 2.2") ;

    newHumidities[0] = await determineLevel2(90,hm1);
    print("cp 2.3") ;
    for (int i = 1; i < 7; i++) {
      int add = (i - 1) * 24;
      double h0 = await fetchHumidity(start, end, hour + add, position.longitude, position.latitude);
      print("humidity of $i with value : $h0") ;
      newHumidities[i] = await determineLevel2(90,h0);
    }

    setState(() {
      humidities = newHumidities; // Update the state with new humidities once all async operations are completed
    });
    print("cp 3") ;
  }


  @override
  Widget build(BuildContext context) {
    List<String> weeknames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

    return Container(
      margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 32),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white54,
        border: Border.all(
          width: 2,
          color: Colors.black,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Yesterday"),
              Text("Today"),
              Text(weeknames[((weekday % 7) + 1) % 7]),
              Text(weeknames[((weekday % 7) + 2) % 7]),
              Text(weeknames[((weekday % 7) + 3) % 7]),
              Text(weeknames[((weekday % 7) + 4) % 7]),
              Text(weeknames[((weekday % 7) + 5) % 7]),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(humidities[0]),
              Text(humidities[1]),
              Text(humidities[2]),
              Text(humidities[3]),
              Text(humidities[4]),
              Text(humidities[5]),
              Text(humidities[6]),
            ],
          ),
        ],
      ),
    );
  }
}

