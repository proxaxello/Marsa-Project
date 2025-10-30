import 'package:dio/dio.dart';

class AiTutorProvider {
  final Dio _dio;
  
  AiTutorProvider(this._dio);
  
  /// Gets a chat response from the AI API
  /// 
  /// [userMessage] is the message from the user
  /// 
  /// Returns a Future<String> with the AI's response
  Future<String> getChatResponse(String userMessage) async {
    try {
      // Set up headers with API key (placeholder)
      final headers = {
        'Authorization': 'Bearer YOUR_API_KEY',
        'Content-Type': 'application/json',
      };
      
      // Set up request body for OpenAI API
      // This is configured for ChatGPT, but can be adapted for other APIs
      final body = {
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a helpful language tutor assistant. You help users learn languages by having conversations with them, explaining grammar concepts, and providing vocabulary help.',
          },
          {
            'role': 'user',
            'content': userMessage,
          }
        ],
        'temperature': 0.7,
        'max_tokens': 150,
      };
      
      // Make the API call
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(headers: headers),
        data: body,
      );
      
      // Extract the response text
      final responseData = response.data;
      final aiMessage = responseData['choices'][0]['message']['content'];
      
      return aiMessage;
    } catch (e) {
      // For development purposes, return a mock response
      // This allows the app to function without a real API key
      return _getMockResponse(userMessage);
    }
  }
  
  /// Generates a mock response based on the user message
  /// This is used when the API call fails (e.g., no API key)
  String _getMockResponse(String userMessage) {
    final lowercaseMessage = userMessage.toLowerCase();
    
    if (lowercaseMessage.contains('hello') || 
        lowercaseMessage.contains('hi') || 
        lowercaseMessage.contains('hey')) {
      return "Hello there! I'm your AI language tutor. How can I help with your language learning today?";
    } else if (lowercaseMessage.contains('thank')) {
      return "You're welcome! Learning languages is a journey, and I'm here to help you every step of the way. Is there anything specific you'd like to practice?";
    } else if (lowercaseMessage.contains('bye') || 
              lowercaseMessage.contains('goodbye')) {
      return "Goodbye! Remember, consistent practice is key to language learning. Feel free to come back anytime for more practice.";
    } else if (lowercaseMessage.contains('help')) {
      return "I can help you practice conversations, explain grammar rules, or work on vocabulary. I can also help with pronunciation tips and cultural context. What would you like to focus on?";
    } else if (lowercaseMessage.contains('grammar')) {
      return "Grammar is the foundation of clear communication. I can explain grammar rules, provide examples, and create exercises for you to practice. Is there a specific grammar point you'd like to work on?";
    } else if (lowercaseMessage.contains('vocabulary') || 
              lowercaseMessage.contains('words')) {
      return "Building vocabulary is essential for language fluency! I can help you learn new words, practice using them in context, and create memory aids. Would you like to focus on a specific topic or situation?";
    } else if (lowercaseMessage.contains('practice') || 
              lowercaseMessage.contains('exercise')) {
      return "Practice makes perfect! I can create customized exercises for you based on your learning goals. Would you prefer conversation practice, grammar exercises, vocabulary drills, or something else?";
    } else if (lowercaseMessage.contains('conversation')) {
      return "Conversation practice is a great way to improve fluency! Let's have a chat. You can tell me about your day, your interests, or we can role-play a specific scenario like ordering at a restaurant or asking for directions.";
    } else {
      return "I understand you're interested in improving your language skills. Could you tell me more about your specific learning goals? For example, are you preparing for a test, planning to travel, or just learning for fun?";
    }
  }
}
