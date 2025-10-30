import 'package:equatable/equatable.dart';
import 'package:marsa_app/data/models/word_model.dart';

abstract class WordState extends Equatable {
  const WordState();

  @override
  List<Object> get props => [];
}

class WordInitial extends WordState {
  const WordInitial();
}

class WordLoading extends WordState {
  const WordLoading();
}

class WordLoaded extends WordState {
  final List<WordModel> words;

  const WordLoaded(this.words);

  @override
  List<Object> get props => [words];
}

class WordError extends WordState {
  final String message;

  const WordError(this.message);

  @override
  List<Object> get props => [message];
}
