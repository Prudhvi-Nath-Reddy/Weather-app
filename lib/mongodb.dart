import 'dart:developer';

import 'package:mongo_dart/mongo_dart.dart';
import 'constant.dart';
var retval ;
class MongoDatabase {
  connect() async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var status = db.serverStatus();
    print(status);
    var collection = db.collection(COLLECTION_NAME);

    var listOfHumidities = await collection.find().toList();
    retval = listOfHumidities ;
    // print(listOfHumidities.runtimeType);
    //
    // print(listOfHumidities);
  }
}
