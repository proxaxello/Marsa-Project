import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchTermChanged extends SearchEvent {
  final String searchTerm;

  const SearchTermChanged(this.searchTerm);

  @override
  List<Object> get props => [searchTerm];
}

class SearchSubmitted extends SearchEvent {
  final String searchTerm;

  const SearchSubmitted(this.searchTerm);

  @override
  List<Object> get props => [searchTerm];
}

class SearchCleared extends SearchEvent {}
