import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      print('[SPEECH] Microphone permission denied');
      return false;
    }
    
    _isInitialized = await _speech.initialize(
      onError: (error) => print('[SPEECH_ERROR] $error'),
      onStatus: (status) => print('[SPEECH_STATUS] $status'),
    );
    
    return _isInitialized;
  }

  Future<String?> listen() async {
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) return null;
    }

    String? result;
    final completer = Future<String?>(() async {
      await _speech.listen(
        onResult: (speechResult) {
          result = speechResult.recognizedWords;
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );

      // Wait for speech to complete
      while (_speech.isListening) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      return result;
    });

    return completer;
  }

  void stop() {
    _speech.stop();
  }

  bool get isListening => _speech.isListening;
}
