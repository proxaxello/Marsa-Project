import 'package:equatable/equatable.dart';
import 'package:marsa_app/data/models/phrase_model.dart';

abstract class LessonDetailState extends Equatable {
  const LessonDetailState();
  
  @override
  List<Object> get props => [];
}

class LessonDetailInitial extends LessonDetailState {
  const LessonDetailInitial();
}

class LessonDetailLoading extends LessonDetailState {
  const LessonDetailLoading();
}

class LessonDetailLoaded extends LessonDetailState {
  final List<PhraseModel> phrases;
  
  const LessonDetailLoaded(this.phrases);
  
  @override
  List<Object> get props => [phrases];
}

class LessonDetailError extends LessonDetailState {
  final String message;
  
  const LessonDetailError(this.message);
  
  @override
  List<Object> get props => [message];
}

// Pronunciation analysis states
class AnalysisLoading extends LessonDetailState {
  const AnalysisLoading();
}

class AnalysisSuccess extends LessonDetailState {
  final Map<String, dynamic> result;
  final int phraseId;
  
  const AnalysisSuccess({
    required this.result,
    required this.phraseId,
  });
  
  // Extract useful metrics from the analysis result
  int get overallScore => result['overall_score'] as int;
  int get pronunciationScore => result['pronunciation_score'] as int;
  int get fluencyScore => result['fluency_score'] as int;
  String get feedback => result['feedback'] as String;
  List<dynamic> get wordScores => result['word_scores'] as List<dynamic>;
  
  @override
  List<Object> get props => [result, phraseId];
}

class AnalysisFailure extends LessonDetailState {
  final String message;
  
  const AnalysisFailure(this.message);
  
  @override
  List<Object> get props => [message];
}
