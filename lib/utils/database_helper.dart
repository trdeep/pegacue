import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/cue.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pegacue8.db');
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
      CREATE TABLE cues(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        plain_text TEXT NOT NULL,
        delta_json TEXT NOT NULL,
        word_count INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertCue(Cue cue) async {
    final db = await instance.database;
    return await db.insert('cues', cue.toMap());
  }

  Future<List<Cue>> getAllCues() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('cues', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => Cue.fromMap(maps[i]));
  }

  Future<int> updateCue(Cue cue) async {
    final db = await instance.database;
    return await db.update(
      'cues',
      cue.toMap(),
      where: 'id = ?',
      whereArgs: [cue.id],
    );
  }

  Future<int> deleteCue(int id) async {
    final db = await instance.database;
    return await db.delete(
      'cues',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}