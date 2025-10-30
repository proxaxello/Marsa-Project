import 'package:marsa_app/data/providers/speech_analysis_provider.dart';

class SpeechAnalysisRepository {
  final SpeechAnalysisProvider _speechAnalysisProvider;

  SpeechAnalysisRepository({
    required SpeechAnalysisProvider speechAnalysisProvider,
  }) : _speechAnalysisProvider = speechAnalysisProvider;

  /// Analyzes audio recording against a reference text
  /// 
  /// [filePath] is the path to the audio file
  /// [referenceText] is the text that should be spoken in the audio
  /// 
  /// Returns a Map containing the analysis results
  Future<Map<String, dynamic>> analyzeAudio(String filePath, String referenceText) async {
    try {
      final result = await _speechAnalysisProvider.analyzeAudio(filePath, referenceText);
      return result;
    } catch (e) {
      // Re-throw the error to be handled by the BLoC
      rethrow;
    }
  }
}
