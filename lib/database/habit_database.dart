
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
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createCheckInsTable(db);
        }
      },
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

    await _createCheckInsTable(db);
  }

  Future<void> _createCheckInsTable(Database db) async {
    await db.execute('''
      CREATE TABLE check_ins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habitId INTEGER NOT NULL,
        checkInDate TEXT NOT NULL,
        FOREIGN KEY (habitId) REFERENCES habits (id)
          ON DELETE CASCADE,
        UNIQUE (habitId, checkInDate)
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

  Future<int> addCheckIn(int habitId, DateTime date) async {
    final db = await instance.database;
    final checkInDate = _formatDate(date);

    return await db.insert(
      'check_ins',
      {
        'habitId': habitId,
        'checkInDate': checkInDate,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<Map<int, int>> getWeeklyCheckInCounts() async {
    final db = await instance.database;
    final today = DateTime.now();
    final weekStart = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    final results = await db.rawQuery(
      '''
      SELECT habitId, COUNT(*) AS completed
      FROM check_ins
      WHERE checkInDate >= ? AND checkInDate < ?
      GROUP BY habitId
      ''',
      [
        _formatDate(weekStart),
        _formatDate(weekEnd),
      ],
    );

    return {
      for (final row in results)
        row['habitId'] as int: row['completed'] as int,
    };
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
