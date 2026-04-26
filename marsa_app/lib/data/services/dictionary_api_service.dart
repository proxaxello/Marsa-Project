import 'package:dio/dio.dart';

/// Dictionary API Service using Free Dictionary API
/// API: https://dictionaryapi.dev/
class DictionaryApiService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';

  /// Search for word definition
  Future<Map<String, dynamic>> searchWord(String word) async {
    try {
      final response = await _dio.get('$_baseUrl/$word');
      
      if (response.statusCode == 200 && response.data != null) {
        // API returns array, get first result
        final data = response.data[0];
        return {
          'success': true,
          'word': data['word'] ?? word,
          'phonetic': data['phonetic'] ?? '',
          'phonetics': data['phonetics'] ?? [],
          'meanings': data['meanings'] ?? [],
          'origin': data['origin'] ?? '',
        };
      }
      
      return {
        'success': false,
        'error': 'Word not found',
      };
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return {
          'success': false,
          'error': 'Word not found in dictionary',
        };
      }
      return {
        'success': false,
        'error': 'Network error: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error: $e',
      };
    }
  }

  /// Get audio URL from phonetics
  String? getAudioUrl(List<dynamic> phonetics) {
    for (var phonetic in phonetics) {
      if (phonetic['audio'] != null && phonetic['audio'].toString().isNotEmpty) {
        return phonetic['audio'];
      }
    }
    return null;
  }
}
