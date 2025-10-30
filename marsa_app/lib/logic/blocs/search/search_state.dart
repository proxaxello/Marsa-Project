import 'package:equatable/equatable.dart';
import 'package:marsa_app/data/models/word_model.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<WordModel> results;

  const SearchSuccess(this.results);

  @override
  List<Object> get props => [results];
}

class SearchFailure extends SearchState {
  final String errorMessage;

  const SearchFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
