import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:apollineflutter/sensormodel.dart';

// database table and column names
final String tableSensorModel = 'SensorModel';
final String columnId = '_id';
final String columnDeviceName = 'deviceName';
final String columnUuid = 'uuid';
final String columnProvider = 'provider';
final String columnGeohash = 'geohash';
final String columnTransport = 'transport';
final String columnValues = 'values';

// Author GDISSA Ramy
// Sqflite Database
class SqfLiteService {
  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "apolline.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  SqfLiteService._privateConstructor();
  static final SqfLiteService instance = SqfLiteService._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

// open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database, can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableSensorModel (
            $columnId INTEGER PRIMARY KEY,
            $columnDeviceName TEXT NOT NULL,
            $columnUuid TEXT NOT NULL,
            $columnProvider TEXT NOT NULL,
            $columnTransport TEXT NOT NULL,
            $columnGeohash TEXT NOT NULL,
            $columnValues TEXT NOT NULL
          )
          ''');
  }

  // SQL get SensorModel data by uuid
  Future<List<SensorModel>> querySensdorModelByUuid(String uuid) async {
    Database db = await database;
    List<Map> maps = await db.query(tableSensorModel,
        columns: [
          columnId,
          columnDeviceName,
          columnUuid,
          columnProvider,
          columnGeohash,
          columnTransport,
          columnValues
        ],
        where: '$columnUuid = ?',
        whereArgs: [uuid]);
    if (maps.length > 0) {
      List<SensorModel> sensdorModels = [];
      maps.forEach((map) => sensdorModels.add(SensorModel.fromJson(map)));
      return sensdorModels;
    }
    return null;
  }

  // SQL get all SensorModel data
  Future<List<SensorModel>> queryAllSensdorModels() async {
    Database db = await database;
    List<Map> maps = await db.query(tableSensorModel);
    if (maps.length > 0) {
      List<SensorModel> sensdorModels = [];
      maps.forEach((map) => sensdorModels.add(SensorModel.fromJson(map)));
      return sensdorModels;
    }
    return null;
  }

  // SQL delete all data
  Future<int> deleteAll(int id) async {
    Database db = await database;
    return await db.delete(tableSensorModel);
  }
}
