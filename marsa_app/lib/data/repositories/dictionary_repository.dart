import 'package:marsa_app/data/models/word_model.dart';
import 'package:marsa_app/data/providers/dictionary_provider.dart';

class DictionaryRepository {
  final DictionaryProvider _dictionaryProvider;

  DictionaryRepository({required DictionaryProvider dictionaryProvider})
      : _dictionaryProvider = dictionaryProvider;

  // Search for words in the local dictionary
  Future<List<WordModel>> searchLocal(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final results = await _dictionaryProvider.searchWord(query);
      return results.map((map) => WordModel.fromMap(map)).toList();
    } catch (e) {
      // Log the error
      print('Error searching local dictionary: $e');
      // Return empty list on error
      return [];
    }
  }

  // Get a word by exact match
  Future<WordModel?> getWord(String word) async {
    try {
      final result = await _dictionaryProvider.getWord(word);
      if (result != null) {
        return WordModel.fromMap(result);
      }
      return null;
    } catch (e) {
      // Log the error
      print('Error getting word from local dictionary: $e');
      return null;
    }
  }

  // Fetch words by folder ID
  Future<List<WordModel>> fetchWordsByFolder(int folderId) async {
    try {
      // Ensure the folder_id column exists
      await _dictionaryProvider.ensureFolderIdColumn();
      
      // Get words for the specified folder
      final results = await _dictionaryProvider.getWordsByFolder(folderId);
      return results.map((map) => WordModel.fromMap(map)).toList();
    } catch (e) {
      // Log the error
      print('Error fetching words by folder: $e');
      // Return empty list on error
      return [];
    }
  }

  // Add a word to a folder
  Future<WordModel?> addWordToFolder(String word, String meaning, int folderId) async {
    try {
      final id = await _dictionaryProvider.addWordToFolder(word, meaning, folderId);
      return WordModel(id: id, word: word, meaning: meaning);
    } catch (e) {
      // Log the error
      print('Error adding word to folder: $e');
      return null;
    }
  }

  // Update a word's folder
  Future<bool> updateWordFolder(int wordId, int folderId) async {
    try {
      final rowsAffected = await _dictionaryProvider.updateWordFolder(wordId, folderId);
      return rowsAffected > 0;
    } catch (e) {
      // Log the error
      print('Error updating word folder: $e');
      return false;
    }
  }

  // Delete a word by ID
  Future<bool> deleteWord(int wordId) async {
    try {
      final rowsAffected = await _dictionaryProvider.deleteWord(wordId);
      return rowsAffected > 0;
    } catch (e) {
      // Log the error
      print('Error deleting word: $e');
      return false;
    }
  }

  // Get all words with optional filtering
  Future<List<WordModel>> getAllWords({
    String? category,
    String? difficulty,
    bool? isFavorite,
  }) async {
    try {
      await _dictionaryProvider.ensureNewColumns();
      final results = await _dictionaryProvider.getAllWords(
        category: category,
        difficulty: difficulty,
        isFavorite: isFavorite,
      );
      return results.map((map) => WordModel.fromMap(map)).toList();
    } catch (e) {
      print('Error getting all words: $e');
      return [];
    }
  }

  // Add a new word
  Future<WordModel?> addWord(WordModel word) async {
    try {
      await _dictionaryProvider.ensureNewColumns();
      final id = await _dictionaryProvider.addWord(word.toMap());
      return word.copyWith(id: id);
    } catch (e) {
      print('Error adding word: $e');
      return null;
    }
  }

  // Update a word
  Future<bool> updateWord(WordModel word) async {
    try {
      final rowsAffected = await _dictionaryProvider.updateWord(
        word.id,
        word.toMap(),
      );
      return rowsAffected > 0;
    } catch (e) {
      print('Error updating word: $e');
      return false;
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(int wordId, bool isFavorite) async {
    try {
      final rowsAffected = await _dictionaryProvider.toggleFavorite(
        wordId,
        isFavorite,
      );
      return rowsAffected > 0;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // Close the database connection
  Future<void> close() async {
    await _dictionaryProvider.close();
  }
}
