import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Local Dictionary Service using SQLite databases
class DictionaryLocalService {
  Database? _database;
  
  /// Initialize database from assets
  Future<void> initDatabase() async {
    if (_database != null) return;
    
    try {
      // Get database path
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'marsa_dictionary_v6.db');
      
      // Check if database exists
      final exists = await databaseExists(path);
      
      if (!exists) {
        // Copy from assets
        try {
          await Directory(dirname(path)).create(recursive: true);
        } catch (_) {}
        
        ByteData data = await rootBundle.load('assets/database/marsa_dictionary_v6.db');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
      }
      
      // Open database
      _database = await openDatabase(path, readOnly: true);
    } catch (e) {
      print('Error initializing database: $e');
      // Try alternative database
      await _tryAlternativeDatabase();
    }
  }
  
  Future<void> _tryAlternativeDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'en_vi_dict.db');
      
      final exists = await databaseExists(path);
      
      if (!exists) {
        try {
          await Directory(dirname(path)).create(recursive: true);
        } catch (_) {}
        
        ByteData data = await rootBundle.load('assets/database/en_vi_dict.db');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
      }
      
      _database = await openDatabase(path, readOnly: true);
    } catch (e) {
      print('Error with alternative database: $e');
    }
  }
  
  /// Search for a word in the dictionary
  Future<Map<String, dynamic>> searchWord(String word) async {
    try {
      await initDatabase();
      
      if (_database == null) {
        return {
          'success': false,
          'error': 'Database not initialized',
        };
      }
      
      // Try different table structures
      final result = await _searchInTables(word.toLowerCase().trim());
      
      if (result != null) {
        return {
          'success': true,
          'word': word,
          'phonetic': result['phonetic'] ?? '',
          'meanings': _parseMeanings(result),
        };
      }
      
      return {
        'success': false,
        'error': 'Word not found in dictionary',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error searching: $e',
      };
    }
  }
  
  Future<Map<String, dynamic>?> _searchInTables(String word) async {
    // Try common table names
    final tableNames = ['av', 'words', 'dictionary', 'entries', 'anh_viet'];
    
    for (final tableName in tableNames) {
      try {
        // Check if table exists
        final tables = await _database!.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          [tableName],
        );
        
        if (tables.isEmpty) continue;
        
        // Get table info to find column names
        final columns = await _database!.rawQuery('PRAGMA table_info($tableName)');
        final columnNames = columns.map((c) => c['name'] as String).toList();
        
        // Try to find word column
        String? wordColumn;
        for (final col in ['word', 'en', 'english', 'term', 'key']) {
          if (columnNames.contains(col)) {
            wordColumn = col;
            break;
          }
        }
        
        if (wordColumn == null) continue;
        
        // Search for word
        final results = await _database!.query(
          tableName,
          where: '$wordColumn = ? OR $wordColumn LIKE ?',
          whereArgs: [word, '$word%'],
          limit: 1,
        );
        
        if (results.isNotEmpty) {
          return results.first;
        }
      } catch (e) {
        continue;
      }
    }
    
    return null;
  }
  
  List<Map<String, dynamic>> _parseMeanings(Map<String, dynamic> data) {
    final meanings = <Map<String, dynamic>>[];
    
    // Try to find meaning/definition columns
    String? meaningText;
    for (final key in ['meaning', 'vi', 'vietnamese', 'definition', 'def', 'description']) {
      if (data.containsKey(key) && data[key] != null) {
        meaningText = data[key].toString();
        break;
      }
    }
    
    if (meaningText == null || meaningText.isEmpty) {
      return meanings;
    }
    
    // Parse meaning text
    // Common formats: "noun: definition1; definition2" or just "definition"
    final lines = meaningText.split('\n');
    
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      
      // Check if line contains part of speech
      final parts = line.split(':');
      if (parts.length >= 2) {
        final partOfSpeech = parts[0].trim();
        final definitions = parts.sublist(1).join(':').split(';');
        
        meanings.add({
          'partOfSpeech': partOfSpeech,
          'definitions': definitions.map((d) => {
            'definition': d.trim(),
            'example': null,
          }).toList(),
        });
      } else {
        // No part of speech, treat as general definition
        meanings.add({
          'partOfSpeech': 'general',
          'definitions': [{
            'definition': line.trim(),
            'example': null,
          }],
        });
      }
    }
    
    return meanings;
  }
  
  /// Close database
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
