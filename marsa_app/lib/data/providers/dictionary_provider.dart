import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DictionaryProvider {
  static const String _databaseName = "en_vi_dict.db";
  static const String _tableName = "dictionary";
  static Database? _database;

  // Get a singleton instance of the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initializeDB();
    return _database!;
  }

  // Initialize the database
  Future<Database> initializeDB() async {
    // Get the directory path for both Android and iOS to store the database
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    // Check if the database exists
    bool dbExists = await File(path).exists();

    // If the database doesn't exist, copy it from assets
    if (!dbExists) {
      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "database", _databaseName));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    }

    // Open the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create tables if they don't exist
  Future<void> _onCreate(Database db, int version) async {
    // Create dictionary table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName(
        id INTEGER PRIMARY KEY,
        word TEXT NOT NULL,
        meaning TEXT NOT NULL,
        example_sentence TEXT,
        example_translation TEXT,
        category TEXT,
        difficulty TEXT,
        is_favorite INTEGER DEFAULT 0,
        folder_id INTEGER
      )
    ''');
    
    // Create folders table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS folders(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        wordCount INTEGER DEFAULT 0
      )
    ''');
  }

  // Search for words in the dictionary
  Future<List<Map<String, dynamic>>> searchWord(String query) async {
    final db = await database;
    
    // Search for words that start with the query
    return await db.query(
      _tableName,
      where: 'word LIKE ?',
      whereArgs: ['$query%'],
      limit: 50, // Limit the number of results
    );
  }

  // Get a word by exact match
  Future<Map<String, dynamic>?> getWord(String word) async {
    final db = await database;
    
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'word = ?',
      whereArgs: [word],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Get words by folder ID
  Future<List<Map<String, dynamic>>> getWordsByFolder(int folderId) async {
    final db = await database;
    
    return await db.query(
      _tableName,
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'word ASC',
    );
  }

  // Add a word to a folder
  Future<int> addWordToFolder(String word, String meaning, int folderId) async {
    final db = await database;
    
    return await db.insert(
      _tableName,
      {
        'word': word,
        'meaning': meaning,
        'folder_id': folderId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update folder_id for existing words
  Future<int> updateWordFolder(int wordId, int folderId) async {
    final db = await database;
    
    return await db.update(
      _tableName,
      {'folder_id': folderId},
      where: 'id = ?',
      whereArgs: [wordId],
    );
  }

  // Add folder_id column if it doesn't exist
  Future<void> ensureFolderIdColumn() async {
    final db = await database;
    
    try {
      // Check if the column exists
      await db.rawQuery('SELECT folder_id FROM $_tableName LIMIT 1');
    } catch (e) {
      // If the column doesn't exist, add it
      await db.execute('ALTER TABLE $_tableName ADD COLUMN folder_id INTEGER;');
    }
  }

  // Delete a word from the dictionary
  Future<int> deleteWord(int wordId) async {
    final db = await database;
    
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [wordId],
    );
  }

  // Get all words with optional filtering
  Future<List<Map<String, dynamic>>> getAllWords({
    String? category,
    String? difficulty,
    bool? isFavorite,
  }) async {
    final db = await database;
    
    String? whereClause;
    List<dynamic>? whereArgs;
    
    if (category != null || difficulty != null || isFavorite != null) {
      List<String> conditions = [];
      whereArgs = [];
      
      if (category != null && category != 'all') {
        conditions.add('category = ?');
        whereArgs.add(category);
      }
      if (difficulty != null) {
        conditions.add('difficulty = ?');
        whereArgs.add(difficulty);
      }
      if (isFavorite != null) {
        conditions.add('is_favorite = ?');
        whereArgs.add(isFavorite ? 1 : 0);
      }
      
      whereClause = conditions.join(' AND ');
    }
    
    return await db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'word ASC',
    );
  }

  // Add a new word with all fields
  Future<int> addWord(Map<String, dynamic> wordData) async {
    final db = await database;
    return await db.insert(
      _tableName,
      wordData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update word data
  Future<int> updateWord(int wordId, Map<String, dynamic> updates) async {
    final db = await database;
    return await db.update(
      _tableName,
      updates,
      where: 'id = ?',
      whereArgs: [wordId],
    );
  }

  // Toggle favorite status
  Future<int> toggleFavorite(int wordId, bool isFavorite) async {
    final db = await database;
    return await db.update(
      _tableName,
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [wordId],
    );
  }

  // Ensure new columns exist (for database migration)
  Future<void> ensureNewColumns() async {
    final db = await database;
    
    try {
      // Check if columns exist by trying to query them
      await db.rawQuery('SELECT example_sentence, example_translation, category, difficulty, is_favorite FROM $_tableName LIMIT 1');
    } catch (e) {
      // Add missing columns
      try {
        await db.execute('ALTER TABLE $_tableName ADD COLUMN example_sentence TEXT;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE $_tableName ADD COLUMN example_translation TEXT;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE $_tableName ADD COLUMN category TEXT;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE $_tableName ADD COLUMN difficulty TEXT;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE $_tableName ADD COLUMN is_favorite INTEGER DEFAULT 0;');
      } catch (_) {}
    }
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
