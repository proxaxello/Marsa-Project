import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/data/repositories/dictionary_repository.dart';
import 'package:marsa_app/logic/blocs/search/search_event.dart';
import 'package:marsa_app/logic/blocs/search/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final DictionaryRepository _dictionaryRepository;
  
  SearchBloc({required DictionaryRepository dictionaryRepository}) 
      : _dictionaryRepository = dictionaryRepository,
        super(SearchInitial()) {
    on<SearchTermChanged>(_onSearchTermChanged);
    on<SearchSubmitted>(_onSearchSubmitted);
    on<SearchCleared>(_onSearchCleared);
  }

  FutureOr<void> _onSearchTermChanged(
    SearchTermChanged event,
    Emitter<SearchState> emit,
  ) async {
    final searchTerm = event.searchTerm;
    
    // If search term is empty, reset to initial state
    if (searchTerm.isEmpty) {
      emit(SearchInitial());
      return;
    }
    
    // Only start searching if the term is at least 2 characters
    if (searchTerm.length < 2) {
      return;
    }
    
    // Emit loading state
    emit(SearchLoading());
    
    try {
      // Search the local dictionary using the repository
      final results = await _dictionaryRepository.searchLocal(searchTerm);
      emit(SearchSuccess(results));
    } catch (e) {
      emit(SearchFailure('An error occurred while searching: $e'));
    }
  }

  FutureOr<void> _onSearchSubmitted(
    SearchSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    final searchTerm = event.searchTerm;
    
    if (searchTerm.isEmpty) {
      return;
    }
    
    emit(SearchLoading());
    
    try {
      // Search the local dictionary using the repository
      final results = await _dictionaryRepository.searchLocal(searchTerm);
      emit(SearchSuccess(results));
    } catch (e) {
      emit(SearchFailure('Failed to search dictionary: $e'));
    }
  }

  FutureOr<void> _onSearchCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) {
    emit(SearchInitial());
  }
  
  // No longer needed as we're using the real repository
  // Removed _getMockResults method
}
