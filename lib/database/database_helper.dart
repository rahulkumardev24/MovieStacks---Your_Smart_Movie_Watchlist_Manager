import 'dart:convert';

import 'package:moviestacks/model/movie_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._();
  static final DBHelper db = DBHelper._();

  static Database? _database;
  static const String tableName = 'movies';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    /// get default path
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'movies.db');

    /// open database if exist or create new one
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      year INTEGER,
      rating REAL,
      status TEXT )
       ''');
  }

  /// insert movies
  Future<int> insertMovie(MovieModel movie) async {
    final db = await database;
    return await db.insert(tableName, movie.toJson());
  }

  /// get all movies
  Future<List<MovieModel>> getAllMovies() async {
    final db = await database;
    final result = await db.query(tableName);
    return result.map((json) => MovieModel.fromJson(json)).toList();
  }









}
