import 'package:marsa_app/data/providers/ai_tutor_provider.dart';

class AiTutorRepository {
  final AiTutorProvider _aiTutorProvider;
  
  AiTutorRepository({
    required AiTutorProvider aiTutorProvider,
  }) : _aiTutorProvider = aiTutorProvider;
  
  /// Gets a chat response from the AI
  /// 
  /// [userMessage] is the message from the user
  /// 
  /// Returns a Future<String> with the AI's response
  Future<String> getChatResponse(String userMessage) async {
    try {
      final response = await _aiTutorProvider.getChatResponse(userMessage);
      return response;
    } catch (e) {
      // Re-throw the error to be handled by the BLoC
      rethrow;
    }
  }
}
