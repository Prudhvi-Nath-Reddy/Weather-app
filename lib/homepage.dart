import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'func.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
  String temp = "--.--" ;
  String comfort  = "----";


  @override
  void initState() {
    super.initState();
    // someFunction();
    determineLevel() ;

  }
  String determineLevel2(double T, double RH) {
    String s = "Predicting..." ;
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
      s = "Comfortable" ;
    }
    else if(HI <=90)
    {
      s = "Good" ;
    }
    else if(HI <=103)
    {
      s = "Average" ;
    }
    else if(HI <=124)
    {
      s = "Not Good" ;
    }
    else if(HI > 124)
    {
      s = "Bad" ;
    }
    return s;
  }

  Future<void> determineLevel() async {
    await someFunction() ;
    // double rh = double.parse(hl);
    // double tem = double.parse(temp);
    // double fah = (tem * 9 / 5) + 32;
    // String rets = determineLevel2(fah, rh) ;
    //
    // setState(() {
    //   comfort = rets ;
    // });
  }
  Future<Map<String, double>> fetchHumidity(String start, String end, int hour, double longitude, double latitude) async {
    final response = await http.get(
      Uri.parse('http://prudhvi.pythonanywhere.com/get_humidity?start=$start&end=$end&hour=$hour&longitude=$longitude&latitude=$latitude'),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var humidity = jsonResponse['humidity'].toDouble();
      var temp = jsonResponse['temperature'].toDouble();

      print('Humidity: $humidity, Temperature: $temp');
      return {'humidity': humidity, 'temperature': temp};
    } else {
      print('Failed to fetch humidity data.');
      return {'humidity': 0.0, 'temperature': 0.0};
    }
  }

  Future<void> someFunction() async {
    DateTime now = DateTime.now();
    int hour = now.hour ;
    String end = today();
    String start = befday(end);

    Position position = await Geolocator.getCurrentPosition();

    var ht = await fetchHumidity(start, end,hour+24, position.longitude, position.latitude);
    String rets = determineLevel2((ht['temperature'] ?? 0.0), (ht['humidity'] ?? 0.0)) ;
    setState(()
    {
      double hfah = (ht['temperature'] ?? 0.0) ;
      hfah = ((hfah - 32) * 5 / 9);


      hl = (ht['humidity'] ?? 0.0).toStringAsFixed(2);
      comfort = rets ;
      temp = hfah.toStringAsFixed(2);
      Singleton().prelev = "Humidity : $hl , Temperature ; $temp";

    });
    return ;
  }

  @override
  Widget build(BuildContext context) {
    var s = hl;
    var t = temp ;
    DateTime now = DateTime.now();
    var _currentDateTime = DateFormat.yMMMMd('en_US').add_jm().format(now);


    int year = now.year;
    int month = now.month;
    int day = now.day;
    // // For hours in 24-hour format, you can use the `hour` property directly.
    int hours = now.hour;
    // int minutes = now.minute;
    // int wname = now.weekday ;
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

                t,
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
    final PageController _pageController = PageController();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white54,
            border: Border.all(
              width: 2,
              color: Colors.black,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
          ),
          height: 100, // fixed height for the carousel container
          child: PageView(
            controller: _pageController,
            children: [
              Container(
                color: Colors.white,
                child: Center(
                  child: Text(
                    "Tip 1: Stay hydrated",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                child: Center(
                  child: Text(
                    "Tip 2: Wear sunscreen",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                child: Center(
                  child: Text(
                    "Tip 3: Avoid peak sun hours",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SmoothPageIndicator(
          controller: _pageController,
          count: 3,
          effect: const WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            spacing: 16,
            dotColor: Colors.grey,
            activeDotColor: Colors.blue,
          ),
        ),
      ],
    );
  }
}

class WeeklyForecastList extends StatefulWidget {
  const WeeklyForecastList({super.key});

  @override
  _WeeklyForecastListState createState() => _WeeklyForecastListState();
}
String determineLevel2(double T, double RH) {
  String s = "Predicting..." ;
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
    s = "Comfortable" ;
  }
  else if(HI <=90)
  {
    s = "Good" ;
  }
  else if(HI <=103)
  {
    s = "Average" ;
  }
  else if(HI <=124)
  {
    s = "Not Good" ;
  }
  else if(HI > 124)
  {
    s = "Bad" ;
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
  Future<Map<String, double>> fetchHumidity(String start, String end, int hour, double longitude, double latitude) async {
    final response = await http.get(
      Uri.parse('http://prudhvi.pythonanywhere.com/get_humidity?start=$start&end=$end&hour=$hour&longitude=$longitude&latitude=$latitude'),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var humidity = jsonResponse['humidity'].toDouble();
      var temp = jsonResponse['temperature'].toDouble();

      print('Humidity: $humidity, Temperature: $temp');
      return {'humidity': humidity, 'temperature': temp};
    } else {
      print('Failed to fetch humidity data.');
      return {'humidity': 0.0, 'temperature': 0.0};
    }
  }

  Future<void> someFunction() async {
    print("cp 2") ;
    DateTime now = DateTime.now();
    int hour = now.hour;
    String end = today();
    String start = befday(end);
    DateTime startDate = DateTime.parse(start);
    DateTime previousDate = startDate.subtract(Duration(days: 1));
    String prev = DateFormat('yyyy-MM-dd').format(previousDate);
    print("cp 2.1") ;
    Position position = await Geolocator.getCurrentPosition();
    var ht = await fetchHumidity(start, end, hour+24, position.longitude, position.latitude);
    double hm1= (ht['humidity'] ?? 0.0) ;
    double temp = (ht['temperature'] ?? 0.0) ;
    List<String> newHumidities = ["------","------","------","------","------","------","------"] ;
    print("cp 2.2") ;

    newHumidities[0] = await determineLevel2(temp,hm1);
    print("cp 2.3") ;
    for (int i = 1; i < 7; i++) {
      int add = (i) * 24;
      var ht = await fetchHumidity(start, end, hour+add, position.longitude, position.latitude);
      double h0= (ht['humidity'] ?? 0.0) ;
      double temp = (ht['temperature'] ?? 0.0) ;
      print(" $i with humidity : $h0 and temp : $temp") ;
      newHumidities[i] = await determineLevel2(temp,h0);
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

