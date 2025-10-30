import 'package:equatable/equatable.dart';

abstract class VoiceLabEvent extends Equatable {
  const VoiceLabEvent();

  @override
  List<Object> get props => [];
}

class LoadLessons extends VoiceLabEvent {
  const LoadLessons();

  @override
  List<Object> get props => [];
}
