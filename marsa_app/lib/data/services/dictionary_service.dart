import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:marsa_app/data/models/dictionary_entry_model.dart';
import 'package:marsa_app/data/models/search_suggestion_model.dart';
import 'package:marsa_app/utils/html_parser_util.dart';

/// Enhanced Dictionary Service with HTML parsing and performance optimization
class DictionaryService {
  static Database? _database;

  /// Initialize database from assets
  static Future<void> initDatabase() async {
    if (_database != null) {
      print('═══════════════════════════════════════════');
      print('[DB] Database already initialized - SKIPPING');
      print('═══════════════════════════════════════════');
      return;
    }

    try {
      print('═══════════════════════════════════════════');
      print('[DB] STARTING DATABASE INITIALIZATION');
      print('═══════════════════════════════════════════');

      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'marsa_dictionary_v6.db');

      print('═══════════════════════════════════════════');
      print('DEBUG PATH: Database path: $path');
      print('DEBUG PATH: Databases directory: $databasesPath');
      print('═══════════════════════════════════════════');

      print('[DB] Target path: $path');

      final exists = await databaseExists(path);
      print('[DB] Database exists at path: $exists');

      if (!exists) {
        print('[DB] Database NOT found - copying from assets...');
        try {
          await Directory(dirname(path)).create(recursive: true);
          print('[DB] Directory created: ${dirname(path)}');
        } catch (e) {
          print('[DB] Directory already exists or error: $e');
        }

        print('[DB] Loading from assets/database/marsa_dictionary_v6.db...');
        ByteData data = await rootBundle.load(
          'assets/database/marsa_dictionary_v6.db',
        );
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        print(
          '[DB] Asset loaded: ${bytes.length} bytes (${(bytes.length / 1024 / 1024).toStringAsFixed(2)} MB)',
        );

        await File(path).writeAsBytes(bytes, flush: true);
        print('[DB] ✓ Database copied successfully!');

        // Verify file was written
        final file = File(path);
        final fileSize = await file.length();
        print('[DB] Verified file size: $fileSize bytes');
      } else {
        print('[DB] Database already exists - using existing file');
        final file = File(path);
        final fileSize = await file.length();
        print(
          '[DB] Existing file size: $fileSize bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)',
        );
      }

      print('[DB] Opening database...');
      _database = await openDatabase(path, readOnly: true);
      print('[DB] ✓ Database opened successfully');

      // Verify database has the 'av' table
      print('[DB] Verifying table structure...');
      final tables = await _database!.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      print(
        '[DB] All tables in database: ${tables.map((t) => t['name']).join(', ')}',
      );

      final avTable = await _database!.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='av'",
      );
      if (avTable.isNotEmpty) {
        print('[DB] ✓ Table "av" found!');

        // Get table schema
        final schema = await _database!.rawQuery('PRAGMA table_info(av)');
        print(
          '[DB] Table "av" columns: ${schema.map((c) => c['name']).join(', ')}',
        );

        // Get row count
        final count = await _database!.rawQuery(
          'SELECT COUNT(*) as count FROM av',
        );
        print('[DB] Table "av" row count: ${count.first['count']}');

        // Get sample data
        final sample = await _database!.query('av', limit: 1);
        if (sample.isNotEmpty) {
          print('[DB] Sample row columns: ${sample.first.keys.join(', ')}');
          print('[DB] Sample word: ${sample.first['word']}');
        }
      } else {
        print('[DB] ✗ WARNING: Table "av" NOT FOUND!');
      }

      print('═══════════════════════════════════════════');
      print('[DB] DATABASE INITIALIZATION COMPLETE');
      print('═══════════════════════════════════════════');
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════════');
      print('[DB] ✗ ERROR INITIALIZING DATABASE');
      print('[DB] Error: $e');
      print('[DB] Stack trace: $stackTrace');
      print('═══════════════════════════════════════════');
      debugPrint('Error initializing database: $e');
    }
  }

  /// Search for a word with fuzzy matching
  static Future<DictionaryEntry?> searchWord(String query) async {
    if (query.trim().isEmpty) return null;

    await initDatabase();
    if (_database == null) {
      print('[SEARCH] ✗ Database not initialized');
      return null;
    }

    try {
      final searchQuery = query.toLowerCase().trim();
      print('[SEARCH] Searching for: "$searchQuery"');

      // Fuzzy search with priority: exact match > starts with > contains
      List<Map<String, dynamic>> results = [];

      // 1. Try exact match first
      results = await _database!.query(
        'av',
        where: 'word = ?',
        whereArgs: [searchQuery],
        limit: 1,
      );
      print('[SEARCH] Exact match: ${results.length} results');

      // 2. If no exact match, try starts with
      if (results.isEmpty) {
        results = await _database!.query(
          'av',
          where: 'word LIKE ?',
          whereArgs: ['$searchQuery%'],
          limit: 1,
          orderBy: 'word ASC',
        );
        print('[SEARCH] Starts with: ${results.length} results');
      }

      // 3. If still no match, try contains
      if (results.isEmpty) {
        results = await _database!.query(
          'av',
          where: 'word LIKE ?',
          whereArgs: ['%$searchQuery%'],
          limit: 1,
          orderBy: 'word ASC',
        );
        print('[SEARCH] Contains: ${results.length} results');
      }

      if (results.isEmpty) {
        print('[SEARCH] ✗ No results found for: "$searchQuery"');
        return null;
      }

      final row = results.first;
      final word = row['word'] as String;
      final html = row['html'] as String;

      print('[SEARCH] ✓ Found word: "$word"');

      // Parse HTML content using HtmlParserUtil
      final entry = HtmlParserUtil.parseHtmlContent(word, html);
      return entry;
    } catch (e, stackTrace) {
      print('[SEARCH] ✗ Error: $e');
      print('[SEARCH] Stack trace: $stackTrace');
      return null;
    }
  }

  /// Search suggestions (for autocomplete)
  static Future<List<String>> getSuggestions(String query) async {
    if (query.trim().isEmpty) return [];

    await initDatabase();
    if (_database == null) {
      print('[SQL] ✗ Database not initialized');
      return [];
    }

    try {
      // HARD DEBUG: Check table count
      final countResult = await _database!.rawQuery(
        'SELECT count(*) as count FROM av',
      );
      print('!!! DEBUG TABLE COUNT: ${countResult.toString()}');

      // HARD DEBUG: Check table schema
      final schemaResult = await _database!.rawQuery("PRAGMA table_info(av)");
      print('!!! DEBUG TABLE SCHEMA: ${schemaResult.toString()}');

      // HARD DEBUG: List all tables
      final tablesResult = await _database!.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      print('!!! DEBUG ALL TABLES: ${tablesResult.toString()}');

      print(
        '[SQL] Executing: SELECT word FROM av WHERE word LIKE \'$query%\' LIMIT 50',
      );
      final results = await _database!.query(
        'av',
        columns: ['word'],
        where: 'word LIKE ?',
        whereArgs: ['$query%'],
        limit: 50,
        orderBy: 'word ASC',
      );

      print('!!! DEBUG RAW DATA: ${results.toString()}');

      final words = results.map((r) => r['word'] as String).toList();
      print(
        '[RESULTS] Found ${words.length} suggestions: ${words.take(5).join(", ")}${words.length > 5 ? "..." : ""}',
      );
      return words;
    } catch (e) {
      print('[SQL] ✗ ERROR getting suggestions: $e');
      debugPrint('Error getting suggestions: $e');
      return [];
    }
  }

  /// Get brief meaning for suggestion display (first 50 chars)
  static Future<String> getBriefMeaning(String word) async {
    try {
      await initDatabase();
      if (_database == null) return '';

      final results = await _database!.query(
        'av',
        columns: ['description', 'pronounce'],
        where: 'word = ?',
        whereArgs: [word.toLowerCase()],
        limit: 1,
      );

      if (results.isEmpty) return '';

      final description = results.first['description'] as String? ?? '';

      // Strip HTML tags and get first 50 characters
      final cleanText = description
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('&nbsp;', ' ')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&amp;', '&')
          .trim();

      if (cleanText.length <= 50) return cleanText;
      return '${cleanText.substring(0, 50)}...';
    } catch (e) {
      debugPrint('Error getting brief meaning: $e');
      return '';
    }
  }

  /// Get phonetic for a word
  static Future<String> getPhonetic(String word) async {
    try {
      await initDatabase();
      if (_database == null) return '';

      final results = await _database!.query(
        'av',
        columns: ['description'],
        where: 'word = ?',
        whereArgs: [word.toLowerCase()],
        limit: 1,
      );

      if (results.isEmpty) return '';

      final description = results.first['description'] as String? ?? '';

      // Extract phonetic from <h3><i>phonetic</i></h3>
      final phoneticRegex = RegExp(r'<h3><i>(.*?)</i></h3>');
      final match = phoneticRegex.firstMatch(description);

      return match?.group(1)?.trim() ?? '';
    } catch (e) {
      debugPrint('Error getting phonetic: $e');
      return '';
    }
  }

  /// DEBUG FUNCTION - Verify actual database schema
  static Future<void> debugDatabaseSchema() async {
    print('═══════════════════════════════════════════');
    print('DEBUG SCHEMA: Starting schema verification');
    print('═══════════════════════════════════════════');

    await initDatabase();

    if (_database == null) {
      print('DEBUG SCHEMA: ✗ Database is NULL!');
      return;
    }

    print('DEBUG SCHEMA: ✓ Database is initialized');

    // 1. Lấy danh sách bảng
    final tables = await _database!.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table';",
    );
    print('DEBUG SCHEMA: Tables in database: $tables');

    // 2. Lấy danh sách cột của TỪNG bảng
    for (var table in tables) {
      String tableName = table['name'] as String;
      print('═══════════════════════════════════════════');
      print('DEBUG SCHEMA: Analyzing table "$tableName"');

      final columns = await _database!.rawQuery(
        "PRAGMA table_info($tableName);",
      );
      print('DEBUG SCHEMA: Columns in table "$tableName":');
      for (var col in columns) {
        print('  - ${col['name']} (${col['type']})');
      }

      // 3. Lấy sample data từ bảng
      try {
        final sample = await _database!.rawQuery(
          "SELECT * FROM $tableName LIMIT 1;",
        );
        if (sample.isNotEmpty) {
          print(
            'DEBUG SCHEMA: Sample row columns: ${sample.first.keys.toList()}',
          );
          final firstRow = sample.first;
          for (var key in firstRow.keys) {
            final value = firstRow[key];
            final valueStr = value is String && value.length > 100
                ? '${value.substring(0, 100)}...'
                : value.toString();
            print('  - $key: $valueStr');
          }
        } else {
          print('DEBUG SCHEMA: Table "$tableName" is empty');
        }
      } catch (e) {
        print('DEBUG SCHEMA: Cannot query table "$tableName": $e');
      }
    }

    print('═══════════════════════════════════════════');
    print('DEBUG SCHEMA: Schema verification complete');
    print('═══════════════════════════════════════════');
  }

  /// DEBUG FUNCTION - Test search functionality
  static Future<void> debugSearch(String query) async {
    print('═══════════════════════════════════════════');
    print('DEBUG: debugSearch() called with query: "$query"');
    print('DEBUG: Searching for "$query" in v6.db');
    print('═══════════════════════════════════════════');

    await initDatabase();
    if (_database == null) {
      print('DEBUG: ✗ Database is NULL - not initialized!');
      return;
    }

    print('DEBUG: ✓ Database is initialized');
    final results = await getSuggestionsWithDetails(query);
    print('DEBUG: Found ${results.length} results');
    if (results.isNotEmpty) {
      print('DEBUG: First result: ${results.first.word}');
    }
  }

  /// Get suggestions with details (OPTIMIZED - Single query)
  /// Returns list of SearchSuggestion with word, phonetic, and brief meaning
  /// This replaces the old pattern of calling getSuggestions() + getPhonetic() + getBriefMeaning() in a loop
  static Future<List<SearchSuggestion>> getSuggestionsWithDetails(
    String query, {
    int limit = 30,
  }) async {
    if (query.trim().isEmpty) return [];

    await initDatabase();
    if (_database == null) {
      print('═══════════════════════════════════════════');
      print('DEBUG: ✗ Database not initialized in getSuggestionsWithDetails');
      print('═══════════════════════════════════════════');
      return [];
    }

    try {
      print('═══════════════════════════════════════════');
      print('DEBUG: Executing SQL query for: "$query"');
      print(
        'DEBUG: Query: SELECT word, html, pronounce FROM av WHERE word LIKE \'$query%\' LIMIT $limit',
      );
      print('═══════════════════════════════════════════');

      // Try lowercase first (most common)
      var results = await _database!.query(
        'av',
        columns: ['word', 'html', 'pronounce'],
        where: 'word LIKE ?',
        whereArgs: ['${query.toLowerCase()}%'],
        limit: limit,
        orderBy: 'word ASC',
      );

      print(
        '[RESULTS] Found ${results.length} raw results with lowercase query',
      );

      // If no results, try case-insensitive search
      if (results.isEmpty) {
        print(
          '[RESULTS] No results with lowercase, trying case-insensitive...',
        );
        results = await _database!.query(
          'av',
          columns: ['word', 'html', 'pronounce'],
          where: 'LOWER(word) LIKE LOWER(?)',
          whereArgs: ['$query%'],
          limit: limit,
          orderBy: 'word ASC',
        );
        print(
          '[RESULTS] Found ${results.length} results with case-insensitive query',
        );
      }

      // If still no results, try contains instead of starts with
      if (results.isEmpty) {
        print('[RESULTS] No results with starts-with, trying contains...');
        results = await _database!.query(
          'av',
          columns: ['word', 'html', 'pronounce'],
          where: 'LOWER(word) LIKE LOWER(?)',
          whereArgs: ['%$query%'],
          limit: limit,
          orderBy: 'word ASC',
        );
        print('[RESULTS] Found ${results.length} results with contains query');
      }

      print('[RESULTS] FINAL: ${results.length} raw results');

      // Parse in memory (no additional queries)
      if (results.isEmpty) {
        print('[RESULTS] No results to parse - returning empty list');
        return [];
      }

      print('[RESULTS] Parsing ${results.length} results...');

      final suggestions = <SearchSuggestion>[];
      for (var i = 0; i < results.length; i++) {
        try {
          final row = results[i];
          final word = row['word'] as String? ?? '';
          final html = row['html'] as String? ?? '';
          final pronounce = row['pronounce'] as String? ?? '';

          if (i == 0) {
            print(
              '[RESULTS] First row - word: "$word", html length: ${html.length}, pronounce: "$pronounce"',
            );
          }

          // Use pronounce column directly if available, otherwise extract from HTML
          String phonetic = pronounce;
          if (phonetic.isEmpty && html.isNotEmpty) {
            final phoneticRegex = RegExp(r'<h3><i>(.*?)</i></h3>');
            final phoneticMatch = phoneticRegex.firstMatch(html);
            phonetic = phoneticMatch?.group(1)?.trim() ?? '';
          }

          // Strip HTML tags and get first 50 characters for brief meaning
          final cleanText = html
              .replaceAll(RegExp(r'<[^>]*>'), '')
              .replaceAll('&nbsp;', ' ')
              .replaceAll('&lt;', '<')
              .replaceAll('&gt;', '>')
              .replaceAll('&amp;', '&')
              .trim();

          final briefMeaning = cleanText.length <= 50
              ? cleanText
              : '${cleanText.substring(0, 50)}...';

          suggestions.add(
            SearchSuggestion(
              word: word,
              phonetic: phonetic,
              briefMeaning: briefMeaning,
            ),
          );

          if (i == 0) {
            print(
              '[RESULTS] First suggestion parsed - word: "$word", phonetic: "$phonetic", meaning: "${briefMeaning.substring(0, briefMeaning.length > 30 ? 30 : briefMeaning.length)}..."',
            );
          }
        } catch (e) {
          print('[RESULTS] Error parsing row $i: $e');
        }
      }

      print('═══════════════════════════════════════════');
      print('[RESULTS] Successfully parsed ${suggestions.length} suggestions');
      if (suggestions.isNotEmpty) {
        print(
          '[RESULTS] First 3: ${suggestions.take(3).map((s) => s.word).join(", ")}${suggestions.length > 3 ? "..." : ""}',
        );
      }
      print('═══════════════════════════════════════════');

      return suggestions;
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════════');
      print('[SQL] ✗ ERROR getting suggestions with details');
      print('[SQL] Error: $e');
      print('[SQL] Stack trace: $stackTrace');
      print('═══════════════════════════════════════════');
      debugPrint('Error getting suggestions with details: $e');
      return [];
    }
  }

  /// Close database
  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
