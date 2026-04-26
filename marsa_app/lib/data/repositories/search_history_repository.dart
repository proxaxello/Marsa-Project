// TEMPORARY: Commented out to bypass Supabase compiler error
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:marsa_app/data/models/search_history_model.dart';

/// Search History Repository - Manages user search history in Supabase
class SearchHistoryRepository {
  // TEMPORARY: Commented out to bypass Supabase compiler error
  // final SupabaseClient _supabase = Supabase.instance.client;

  /// Save a search to history
  Future<void> saveSearchHistory(String word, String userId) async {
    // TEMPORARY: Commented out to bypass Supabase compiler error
    // try {
    //   print('[SUPABASE] Inserting: word="$word", user_id="$userId"');
    //   await _supabase.from('search_history').insert({
    //     'word': word,
    //     'user_id': userId,
    //     'timestamp': DateTime.now().toIso8601String(),
    //   });
    //   print('[SUPABASE] ✓ Insert successful');
    // } catch (e) {
    //   print('[SUPABASE] ✗ ERROR saving search history: $e');
    // }
  }

  /// Get recent searches for a user
  Future<List<SearchHistory>> getRecentSearches(
    String userId, {
    int limit = 10,
  }) async {
    // TEMPORARY: Commented out to bypass Supabase compiler error
    return [];
    // try {
    //   final response = await _supabase
    //       .from('search_history')
    //       .select()
    //       .eq('user_id', userId)
    //       .order('timestamp', ascending: false)
    //       .limit(limit);
    //
    //   return (response as List<dynamic>)
    //       .map((item) => SearchHistory.fromMap(item as Map<String, dynamic>))
    //       .toList();
    // } catch (e) {
    //   print('Error getting recent searches: $e');
    //   return [];
    // }
  }

  /// Get unique recent searches (no duplicates)
  Future<List<String>> getUniqueRecentSearches(
    String userId, {
    int limit = 10,
  }) async {
    // TEMPORARY: Commented out to bypass Supabase compiler error
    return [];
    // try {
    //   final response = await _supabase
    //       .from('search_history')
    //       .select('word')
    //       .eq('user_id', userId)
    //       .order('timestamp', ascending: false)
    //       .limit(50); // Get more to filter duplicates
    //
    //   final words = (response as List<dynamic>)
    //       .map((item) => item['word'] as String)
    //       .toSet() // Remove duplicates
    //       .take(limit)
    //       .toList();
    //
    //   return words;
    // } catch (e) {
    //   print('Error getting unique recent searches: $e');
    //   return [];
    // }
  }

  /// Clear all search history for a user
  Future<void> clearHistory(String userId) async {
    // TEMPORARY: Commented out to bypass Supabase compiler error
    // try {
    //   await _supabase.from('search_history').delete().eq('user_id', userId);
    // } catch (e) {
    //   print('Error clearing search history: $e');
    // }
  }

  /// Delete a specific search entry
  Future<void> deleteSearchEntry(String id) async {
    // TEMPORARY: Commented out to bypass Supabase compiler error
    // try {
    //   await _supabase.from('search_history').delete().eq('id', id);
    // } catch (e) {
    //   print('Error deleting search entry: $e');
    // }
  }
}
