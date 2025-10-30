import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/data/models/phrase_model.dart';
import 'package:marsa_app/data/repositories/speech_analysis_repository.dart';
import 'package:marsa_app/logic/blocs/voice_lab/lesson_detail_event.dart';
import 'package:marsa_app/logic/blocs/voice_lab/lesson_detail_state.dart';

class LessonDetailBloc extends Bloc<LessonDetailEvent, LessonDetailState> {
  final SpeechAnalysisRepository speechAnalysisRepository;
  
  LessonDetailBloc({
    required this.speechAnalysisRepository,
  }) : super(const LessonDetailInitial()) {
    on<LoadPhrases>(_onLoadPhrases);
    on<AnalyzePronunciation>(_onAnalyzePronunciation);
  }

  void _onLoadPhrases(
    LoadPhrases event,
    Emitter<LessonDetailState> emit,
  ) async {
    try {
      emit(const LessonDetailLoading());
      
      // Simulate a network delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Convert the lesson's phrases (strings) to PhraseModel objects
      final phrases = event.lesson.phrases.asMap().entries.map((entry) {
        return PhraseModel(
          id: entry.key,
          text: entry.value,
        );
      }).toList();
      
      emit(LessonDetailLoaded(phrases));
    } catch (e) {
      emit(LessonDetailError(e.toString()));
    }
  }
  
  void _onAnalyzePronunciation(
    AnalyzePronunciation event,
    Emitter<LessonDetailState> emit,
  ) async {
    try {
      // Emit loading state
      emit(const AnalysisLoading());
      
      // Extract phrase ID from the file path
      // The file path format is: /path/to/recording_<phraseId>.m4a
      final filePath = event.filePath;
      final fileName = filePath.split('/').last;
      final phraseIdStr = fileName.split('_').last.split('.').first;
      final phraseId = int.tryParse(phraseIdStr) ?? 0;
      
      // Call the repository to analyze the audio
      final result = await speechAnalysisRepository.analyzeAudio(
        event.filePath,
        event.referenceText,
      );
      
      // Emit success state with the analysis result
      emit(AnalysisSuccess(result: result, phraseId: phraseId));
      
      // After showing the analysis result, we should return to the loaded state
      // to continue showing the phrases list
      // We need to get the current state to check if it was previously in loaded state
      if (state is LessonDetailLoaded) {
        final loadedState = state as LessonDetailLoaded;
        emit(LessonDetailLoaded(loadedState.phrases));
      }
    } catch (e) {
      // Emit failure state with error message
      emit(AnalysisFailure(e.toString()));
    }
  }
}
