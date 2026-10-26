
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HabitDatabase {
  static final HabitDatabase instance = HabitDatabase._init();
  static Database? _database;

  HabitDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('habit_garden.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        iconPath TEXT NOT NULL,
        weeklyTarget INTEGER NOT NULL,
        motivationNote TEXT
      )
    ''');
  }

  Future<int> insertHabit(Map<String, dynamic> habit) async {
    final db = await instance.database;
    return await db.insert('habits', habit);
  }

  Future<List<Map<String, dynamic>>> getHabits() async {
    final db = await instance.database;
    return await db.query('habits', orderBy: 'id DESC');
  }
}
