import 'package:equatable/equatable.dart';
import 'package:marsa_app/data/models/word_model.dart';

abstract class WordEvent extends Equatable {
  const WordEvent();

  @override
  List<Object> get props => [];
}

class LoadWords extends WordEvent {
  final int folderId;

  const LoadWords(this.folderId);

  @override
  List<Object> get props => [folderId];
}

class AddWord extends WordEvent {
  final String word;
  final String meaning;
  final int folderId;

  const AddWord({
    required this.word,
    required this.meaning,
    required this.folderId,
  });

  @override
  List<Object> get props => [word, meaning, folderId];
}

class DeleteWord extends WordEvent {
  final int wordId;

  const DeleteWord(this.wordId);

  @override
  List<Object> get props => [wordId];
}

class LoadAllWords extends WordEvent {
  final String? category;
  final String? difficulty;
  final bool? isFavorite;

  const LoadAllWords({
    this.category,
    this.difficulty,
    this.isFavorite,
  });

  @override
  List<Object> get props => [
        category ?? '',
        difficulty ?? '',
        isFavorite ?? false,
      ];
}

class AddWordWithDetails extends WordEvent {
  final WordModel word;

  const AddWordWithDetails(this.word);

  @override
  List<Object> get props => [word];
}

class UpdateWord extends WordEvent {
  final WordModel word;

  const UpdateWord(this.word);

  @override
  List<Object> get props => [word];
}

class ToggleFavorite extends WordEvent {
  final int wordId;
  final bool isFavorite;

  const ToggleFavorite({
    required this.wordId,
    required this.isFavorite,
  });

  @override
  List<Object> get props => [wordId, isFavorite];
}

class SearchWords extends WordEvent {
  final String query;

  const SearchWords(this.query);

  @override
  List<Object> get props => [query];
}
