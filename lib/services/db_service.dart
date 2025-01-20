/*import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart'; // For joining paths

class DBService {
  static Database? _database;

  /// Get or initialize the database
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_cache.db');
    return _database!;
  }

  /// Initialize the database
  static Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cache (
            id TEXT PRIMARY KEY,
            card_data TEXT
          )
        ''');
      },
    );
  }

  /// Insert or update a cache entry
  static Future<void> insertCache(String id, String cardData) async {
    final db = await database;
    await db.insert(
      'cache',
      {'id': id, 'card_data': cardData},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetch a cache entry by ID
  static Future<Map<String, dynamic>?> fetchFromCache(String id) async {
    final db = await database;
    final result = await db.query(
      'cache',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }
}
 */
import 'dart:convert'; // For JSON encoding/decoding
import 'package:sqflite/sqflite.dart'; // For database operations
import 'package:path/path.dart'; // For joining paths

class DBService {
  static Database? _database;

  /// Getter for the database
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_cache.db');
    return _database!;
  }

  /// Initialize the database
  static Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cache (
            id TEXT PRIMARY KEY,
            card_data TEXT
          )
        ''');
      },
    );
  }

  /// Fetch a cache entry by ID
  static Future<Map<String, dynamic>?> fetchFromCache(String id) async {
    final db = await database;
    final result = await db.query(
      'cache',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      try {
        // Validate JSON structure before returning
        final cachedData = result.first['card_data'];
        if (cachedData is String) {
          final decodedData = json.decode(cachedData);
          if (decodedData is Map<String, dynamic>) {
            return decodedData;
          } else {
            throw Exception("Cached data is not in the expected format.");
          }
        } else {
          throw Exception("Cached data is not a valid string.");
        }
      } catch (e) {
        // Log and return null if parsing fails
        print("Error parsing cached data for ID $id: $e");
        return null;
      }
    } else {
      return null;
    }
  }

  /// Insert or update a cache entry
  static Future<void> insertCache(String id, String cardData) async {
    final db = await database;
    await db.insert(
      'cache',
      {'id': id, 'card_data': cardData},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}


