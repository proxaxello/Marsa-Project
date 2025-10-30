import 'package:sqflite/sqflite.dart';

class FolderProvider {
  static const String _tableName = "folders";
  final Database _database;

  // Constructor that takes a database instance
  FolderProvider(this._database);

  // Get all folders
  Future<List<Map<String, dynamic>>> getFolders() async {
    return await _database.query(_tableName, orderBy: 'name ASC');
  }

  // Create a new folder
  Future<int> createFolder(String name) async {
    return await _database.insert(
      _tableName,
      {'name': name, 'wordCount': 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get a folder by ID
  Future<Map<String, dynamic>?> getFolder(int id) async {
    final List<Map<String, dynamic>> result = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Update a folder
  Future<int> updateFolder(int id, String name, [int? wordCount]) async {
    final Map<String, dynamic> updates = {'name': name};
    
    if (wordCount != null) {
      updates['wordCount'] = wordCount;
    }

    return await _database.update(
      _tableName,
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update word count for a folder
  Future<int> updateWordCount(int id, int wordCount) async {
    return await _database.update(
      _tableName,
      {'wordCount': wordCount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Increment word count for a folder
  Future<void> incrementWordCount(int id) async {
    await _database.rawUpdate(
      'UPDATE $_tableName SET wordCount = wordCount + 1 WHERE id = ?',
      [id],
    );
  }

  // Decrement word count for a folder
  Future<void> decrementWordCount(int id) async {
    await _database.rawUpdate(
      'UPDATE $_tableName SET wordCount = MAX(0, wordCount - 1) WHERE id = ?',
      [id],
    );
  }

  // Delete a folder
  Future<int> deleteFolder(int id) async {
    return await _database.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
