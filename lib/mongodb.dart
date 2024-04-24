import 'dart:developer';
import 'main.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'constant.dart';
var retval = data ;
class MongoDatabase {
  var db;
  String collectionName;

  MongoDatabase(this.collectionName);

  connect() async {
    db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);

    var status = await db.serverStatus();
    print(status);

    var collection = db.collection(collectionName);
    var listOfHumidities = await collection.find().toList();
    return listOfHumidities;
  }
}
