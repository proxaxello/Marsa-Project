import 'package:equatable/equatable.dart';
import 'package:marsa_app/data/models/lesson_model.dart';

abstract class VoiceLabState extends Equatable {
  const VoiceLabState();
  
  @override
  List<Object> get props => [];
}

class VoiceLabInitial extends VoiceLabState {
  const VoiceLabInitial();
}

class VoiceLabLoading extends VoiceLabState {
  const VoiceLabLoading();
}

class VoiceLabLoaded extends VoiceLabState {
  final List<LessonModel> lessons;
  
  const VoiceLabLoaded(this.lessons);
  
  @override
  List<Object> get props => [lessons];
}

class VoiceLabError extends VoiceLabState {
  final String message;
  
  const VoiceLabError(this.message);
  
  @override
  List<Object> get props => [message];
}
