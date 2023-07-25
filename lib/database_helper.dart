import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'data_model.dart';

class DatabaseHelper {
  static Future<Database> initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'data_entries.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE data_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            selectedDay TEXT,
            selectedTime TEXT,
            courseCode TEXT,
            courseTitle TEXT,
            teacherName TEXT,
            roomNumber TEXT
          )
          ''',
        );
      },
    );
  }

  static Future<void> insertData(DataModel data) async {
    final db = await initializeDatabase();
    await db.insert(
      'data_entries',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.close(); // Close the database after insertion
  }

  static Future<List<DataModel>> getData() async {
    final db = await initializeDatabase();
    final List<Map<String, dynamic>> maps = await db.query('data_entries');
    await db.close(); // Close the database after querying
    return List.generate(
      maps.length,
          (i) {
        return DataModel.fromMap(maps[i]);
      },
    );
  }

  static Future<void> updateData(DataModel data) async {
    final db = await initializeDatabase();
    await db.update(
      'data_entries',
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );
    await db.close(); // Close the database after update
  }

  static Future<void> deleteData(int id) async {
    final db = await initializeDatabase();
    await db.delete(
      'data_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
    await db.close(); // Close the database after delete
  }
}
