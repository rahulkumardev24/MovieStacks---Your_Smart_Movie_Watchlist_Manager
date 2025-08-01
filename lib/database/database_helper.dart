import 'package:moviestacks/model/movie_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._init();
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('movies.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE movies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        release_year TEXT NOT NULL,
        rating REAL NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertMovie(MovieModel movie) async {
    final db = await instance.database;
    return await db.insert('movies', movie.toMap());
  }

  Future<List<MovieModel>> getAllMovies() async {
    final db = await instance.database;
    final result = await db.query('movies');
    return result.map((json) => MovieModel.fromMap(json)).toList();
  }

  Future<List<MovieModel>> getMoviesByStatus(String status) async {
    final db = await instance.database;
    final result = await db.query(
      'movies',
      where: 'status = ?',
      whereArgs: [status],
    );
    return result.map((json) => MovieModel.fromMap(json)).toList();
  }

  Future<List<MovieModel>> searchMovies(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'movies',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
    );
    return result.map((json) => MovieModel.fromMap(json)).toList();
  }

  Future<int> updateMovie(MovieModel movie) async {
    final db = await instance.database;
    return await db.update(
      'movies',
      movie.toMap(),
      where: 'id = ?',
      whereArgs: [movie.id],
    );
  }

  Future<int> deleteMovie(int id) async {
    final db = await instance.database;
    return await db.delete('movies', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
