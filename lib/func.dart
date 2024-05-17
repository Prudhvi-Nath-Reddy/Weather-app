

String befday(String startDate) {
  // Parse the start date string into a DateTime object
  DateTime start = DateTime.parse(startDate);
  // Calculate the day before the start date
  DateTime dayBefore = start.subtract(Duration(days: 1));
  // Format the DateTime object to a string in 'YYYY-MM-DD' format
  String formattedDate = "${dayBefore.year.toString().padLeft(4, '0')}-${dayBefore.month.toString().padLeft(2, '0')}-${dayBefore.day.toString().padLeft(2, '0')}";

  return formattedDate;
}

String today()
{

  DateTime now = DateTime.now();

  // Format the date as 'YYYY-MM-DD'
  String tod = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  return tod ;

}
class Singleton {
  static final Singleton _singleton = Singleton._internal();

  String mapurl2 = "https://harsha-deep.github.io/projects/gee-humidity/map1.html";

  factory Singleton() {
    return _singleton;
  }

  Singleton._internal();
}


class gvars {
  static var mapurl = "https://harsha-deep.github.io/projects/gee-humidity/map1.html";
}

