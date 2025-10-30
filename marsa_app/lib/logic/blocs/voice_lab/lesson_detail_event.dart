import 'package:equatable/equatable.dart';
import 'package:marsa_app/data/models/lesson_model.dart';

abstract class LessonDetailEvent extends Equatable {
  const LessonDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadPhrases extends LessonDetailEvent {
  final LessonModel lesson;

  const LoadPhrases(this.lesson);

  @override
  List<Object> get props => [lesson];
}

class AnalyzePronunciation extends LessonDetailEvent {
  final String filePath;
  final String referenceText;

  const AnalyzePronunciation({
    required this.filePath,
    required this.referenceText,
  });

  @override
  List<Object> get props => [filePath, referenceText];
}
