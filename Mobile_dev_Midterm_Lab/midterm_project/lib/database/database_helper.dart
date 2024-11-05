import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');
    return await openDatabase(
      path,
      version: 2,  // Increment the database version
      onCreate: (db, version) {
        return db.execute('''
        CREATE TABLE tasks(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          dueDate TEXT,
          dueTime TEXT,  -- New column for due time
          isCompleted INTEGER,
          isRepeating INTEGER,
          repeatInterval TEXT
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add dueTime column if upgrading from version 1 to 2
          await db.execute('ALTER TABLE tasks ADD COLUMN dueTime TEXT');
        }
      },
    );
  }



  // CRUD methods (Add, Update, Delete, Fetch)
// Add a new task
  Future<int> addTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

// Fetch all tasks
  Future<List<Task>> fetchTasks() async {
    final db = await database;
    final tasks = await db.query('tasks');
    return tasks.map((map) => Task.fromMap(map)).toList();
  }

// Update an existing task
  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }


  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
