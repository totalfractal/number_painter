import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static final DBProvider db = DBProvider._();
  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  DBProvider._();

  Future<Database> initDB() async {
    final databasessDirectory = await getDatabasesPath();
    final path = join(databasessDirectory, 'TestDB.db');
    return openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE Painters (id TEXT PRIMARY KEY, shapes TEXT, isCompleted INTEGER)');
      },
    );
  }
}
