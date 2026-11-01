
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
      version: 4,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createCheckInsTable(db);
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE habits ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0',
          );
        }
        if (oldVersion < 4) {
          await db.execute(
            "ALTER TABLE habits ADD COLUMN status TEXT NOT NULL DEFAULT 'notStarted'",
          );

          await db.execute(
            'ALTER TABLE habits ADD COLUMN startedLocalDate TEXT',
          );
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
        motivationNote TEXT,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'notStarted',
        startedLocalDate TEXT
      )
    ''');

    await _createCheckInsTable(db);
  }
// delete cascade ensures deletion deketes all associated check ins**
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
// habit insertion logic
  Future<int> insertHabit(Map<String, dynamic> habit) async {
    final db = await instance.database;
    return await db.insert('habits', habit);
  }
  // update row matching habit id 
  Future<int> updateHabit(int id, Map<String, dynamic> habit) async {
    final db = await instance.database;

    return await db.update(
      'habits',
      habit,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  //input habit status for start implementation
  Future<int> updateHabitStatus(
    int id,
    String status,
    String? startedLocalDate,
  ) async {
    final db = await instance.database;

    return await db.update(
      'habits',
      {
        'status': status,
        'startedLocalDate': startedLocalDate,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  // delete habit 
    Future<int> deleteHabit(int id) async {
      final db = await instance.database;

      return await db.delete(
        'habits',
        where: 'id = ?',
        whereArgs: [id],
      );
    }

  Future<List<Map<String, dynamic>>> getHabits() async {
    final db = await instance.database;
    return await db.query('habits', orderBy: 'id DESC');
  }
//logic to fill in check in according to date
  Future<int> addCheckIn(int habitId, DateTime date) async {
    final db = await instance.database;
    final checkInDate = _formatDate(date);

    return await db.transaction((txn) async {
      final existing = await txn.query(
        'check_ins',
        where: 'habitId = ? AND checkInDate = ?',
        whereArgs: [habitId, checkInDate],
      );
      if (existing.isNotEmpty) {
        return 0;
      }
      await txn.insert(
        'check_ins',
        {
          'habitId': habitId,
          'checkInDate': checkInDate,
        },
      );
      return 1;
    });
  }
//compile check in counts for summary
  Future<Map<int, int>> getWeeklyCheckInCounts() async {
    final db = await instance.database;
    final today = DateTime.now();
    final startOfWeek =
        today.subtract(Duration(days: today.weekday - 1));
    final startDate = _formatDate(startOfWeek);
    final endDate = _formatDate(startOfWeek.add(const Duration(days: 7)));
    final result = await db.rawQuery('''
      SELECT
        habits.id AS habitId,
        CASE
          WHEN habits.status = 'finished' THEN habits.weeklyTarget
          ELSE COUNT(check_ins.id)
        END AS completed
      FROM habits
      LEFT JOIN check_ins
        ON check_ins.habitId = habits.id
        AND check_ins.checkInDate >= ?
        AND check_ins.checkInDate < ?
        AND check_ins.checkInDate >= habits.startedLocalDate
      GROUP BY habits.id
    ''', [startDate, endDate]);

    return {
      for (final row in result)
        row['habitId'] as int: row['completed'] as int,
    };
  }
    Future<List<String>> getCheckInDatesForHabit(int habitId) async {
    final db = await instance.database;
    final habit = await db.query(
      'habits',
      columns: ['startedLocalDate'],
      where: 'id = ?',
      whereArgs: [habitId],
    );
    if (habit.isEmpty || habit.first['startedLocalDate'] == null) {
      return [];
    }
    final startDate = habit.first['startedLocalDate'] as String;
    final result = await db.query(
      'check_ins',
      columns: ['checkInDate'],
      where: 'habitId = ? AND checkInDate >= ?',
      whereArgs: [habitId, startDate],
    );

    return result.map((row) => row['checkInDate'] as String).toList();
  }
  
  //HISTORY SCREEN LOGIC:
    // get recent check-ins for history screen
  Future<List<Map<String, dynamic>>> getRecentCheckIns() async {
    final db = await instance.database;
    // joined tabked by habit Id and order check ins from newest to oldest:
    return await db.rawQuery('''
      SELECT
        check_ins.id AS id,
        check_ins.habitId AS habitId,
        check_ins.checkInDate AS checkInDate,
        habits.name AS habitName,
        habits.startedLocalDate AS startedLocalDate
      FROM check_ins
      INNER JOIN habits ON check_ins.habitId = habits.id
      ORDER BY check_ins.checkInDate DESC, check_ins.id DESC
    ''');
  }

  // delete check in
  Future<int> deleteCheckIn(int id) async {
    final db = await instance.database;
    // deletes selected [id] check-in
    return await db.delete(
      'check_ins',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  // update check in date
Future<int> updateCheckIn(int id, DateTime date) async {
  final db = await instance.database;
  final checkInDate = _formatDate(date);
  // update with new check in date selected by user
  return await db.update(
    'check_ins',
    {
      'checkInDate': checkInDate,
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

}