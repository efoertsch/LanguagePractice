import 'package:mongo_dart/mongo_dart.dart';
import 'dart:developer';

class MongoDBConnector {
  // Use your actual connection string here.
  // For Atlas, it usually looks like: mongodb+srv://<user>:<password>@cluster.mongodb.net/<dbname>
  //static const String _connectionString = "mongodb+srv://USER:PASSWORD@cluster0.example.mongodb.net/myDatabase?retryWrites=true&w=majority";
  static const String _connectionString = String.fromEnvironment(
    'MONGO_CONN_STR',
    defaultValue: 'mongodb://127.0.0.1:27017/local',
  );

  static Db? _db;

  /// Returns the database instance, initializing it if necessary.
  static Future<Db> get database async {
    if (_db == null || !_db!.isConnected) {
      await connect();
    }
    return _db!;
  }

  /// Establishes the connection to the remote server
  static Future<void> connect() async {
    if (_connectionString.isEmpty || _connectionString.contains('localhost') && !bool.fromEnvironment('DEBUG_LOCAL')) {
      log("Warning: Using default/empty connection string.");
    }

    try {
      // Db.create is the modern way to handle srv and standard connection strings
      _db = await Db.create(_connectionString);
      await _db!.open();
      log("Successfully connected to MongoDB");
    } catch (e) {
      log("Error connecting to MongoDB: $e");
      rethrow;
    }
  }

  /// Closes the connection (useful for app shutdown)
  static Future<void> close() async {
    await _db?.close();
    _db = null;
    log("MongoDB connection closed");
  }
}