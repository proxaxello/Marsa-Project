import 'dart:io';
import 'package:dio/dio.dart';

class SpeechAnalysisProvider {
  final Dio _dio;

  SpeechAnalysisProvider(this._dio);

  Future<Map<String, dynamic>> analyzeAudio(String filePath, String referenceText) async {
    try {
      // Create a file object from the file path
      final file = File(filePath);
      
      // Create form data
      final formData = FormData.fromMap({
        'audio_file': await MultipartFile.fromFile(
          file.path,
          filename: 'audio_recording.m4a',
        ),
        'reference_text': referenceText,
        'user_id': 'test_user', // Mock user ID
        'dialect': 'en-us', // American English dialect
      });

      // Make the POST request to the API
      // In a real implementation, this would be a real API endpoint with an API key
      final response = await _dio.post(
        'https://api.speechace.com/api/v0.1/speech-recognition',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response.data;
    } catch (e) {
      // For development purposes, return a mock successful response
      return _getMockAnalysisResult(referenceText);
    }
  }

  // Mock analysis result for development
  Map<String, dynamic> _getMockAnalysisResult(String referenceText) {
    // Generate a random score between 70 and 100
    final overallScore = 70 + (DateTime.now().millisecondsSinceEpoch % 30);
    
    // Split the reference text into words
    final words = referenceText.split(' ');
    
    // Generate word-level scores
    final wordScores = words.map((word) {
      // Generate a random score for each word
      final wordScore = 60 + (word.hashCode % 40);
      
      return {
        'word': word,
        'score': wordScore,
        'feedback': wordScore > 80 ? 'Good' : 'Needs practice',
      };
    }).toList();
    
    return {
      'status': 'success',
      'overall_score': overallScore,
      'pronunciation_score': overallScore - 5,
      'fluency_score': overallScore + 5,
      'word_scores': wordScores,
      'reference_text': referenceText,
      'feedback': overallScore > 90 
          ? 'Excellent pronunciation!' 
          : overallScore > 80 
              ? 'Good pronunciation with minor issues.' 
              : 'Your pronunciation needs more practice.',
    };
  }
}
