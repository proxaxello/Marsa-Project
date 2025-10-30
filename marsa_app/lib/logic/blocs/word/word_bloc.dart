import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/data/repositories/dictionary_repository.dart';
import 'package:marsa_app/logic/blocs/word/word_event.dart';
import 'package:marsa_app/logic/blocs/word/word_state.dart';

class WordBloc extends Bloc<WordEvent, WordState> {
  final DictionaryRepository _dictionaryRepository;

  WordBloc({required DictionaryRepository dictionaryRepository})
      : _dictionaryRepository = dictionaryRepository,
        super(const WordInitial()) {
    on<LoadWords>(_onLoadWords);
    on<AddWord>(_onAddWord);
    on<DeleteWord>(_onDeleteWord);
    on<LoadAllWords>(_onLoadAllWords);
    on<AddWordWithDetails>(_onAddWordWithDetails);
    on<UpdateWord>(_onUpdateWord);
    on<ToggleFavorite>(_onToggleFavorite);
    on<SearchWords>(_onSearchWords);
  }

  FutureOr<void> _onLoadWords(
    LoadWords event,
    Emitter<WordState> emit,
  ) async {
    emit(const WordLoading());

    try {
      final words = await _dictionaryRepository.fetchWordsByFolder(event.folderId);
      emit(WordLoaded(words));
    } catch (e) {
      emit(WordError('Failed to load words: $e'));
    }
  }

  FutureOr<void> _onAddWord(
    AddWord event,
    Emitter<WordState> emit,
  ) async {
    // Get current state
    final currentState = state;
    if (currentState is WordLoaded) {
      try {
        // Add the word to the folder
        final newWord = await _dictionaryRepository.addWordToFolder(
          event.word,
          event.meaning,
          event.folderId,
        );

        if (newWord != null) {
          // Create a new list with the new word
          final updatedWords = [...currentState.words, newWord];
          
          // Sort the words alphabetically by word
          updatedWords.sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));
          
          emit(WordLoaded(updatedWords));
        } else {
          // If the repository returned null, emit an error
          emit(WordError('Failed to add word: Unknown error'));
          
          // Restore the previous state after a short delay
          await Future.delayed(const Duration(seconds: 3));
          emit(currentState);
        }
      } catch (e) {
        // Emit error state with the error message
        emit(WordError('Failed to add word: ${e.toString()}'));
        
        // Restore the previous state after a short delay
        await Future.delayed(const Duration(seconds: 3));
        emit(currentState);
      }
    } else {
      // If we're not in a loaded state, try to load the words first
      emit(const WordLoading());
      try {
        final words = await _dictionaryRepository.fetchWordsByFolder(event.folderId);
        emit(WordLoaded(words));
        
        // Now try to add the word again
        add(event);
      } catch (e) {
        emit(WordError('Failed to load words before adding new word: $e'));
      }
    }
  }

  FutureOr<void> _onDeleteWord(
    DeleteWord event,
    Emitter<WordState> emit,
  ) async {
    // Get current state
    final currentState = state;
    if (currentState is WordLoaded) {
      try {
        // Delete the word from the repository
        final success = await _dictionaryRepository.deleteWord(event.wordId);
        
        if (success) {
          // Create a new list without the deleted word
          final updatedWords = currentState.words
              .where((word) => word.id != event.wordId)
              .toList();
          
          // Emit the updated list
          emit(WordLoaded(updatedWords));
        } else {
          // If deletion failed, emit an error
          emit(WordError('Failed to delete word'));
          
          // Restore the previous state after a short delay
          await Future.delayed(const Duration(seconds: 3));
          emit(currentState);
        }
      } catch (e) {
        // Emit error state with the error message
        emit(WordError('Failed to delete word: ${e.toString()}'));
        
        // Restore the previous state after a short delay
        await Future.delayed(const Duration(seconds: 3));
        emit(currentState);
      }
    }
  }

  FutureOr<void> _onLoadAllWords(
    LoadAllWords event,
    Emitter<WordState> emit,
  ) async {
    emit(const WordLoading());

    try {
      final words = await _dictionaryRepository.getAllWords(
        category: event.category,
        difficulty: event.difficulty,
        isFavorite: event.isFavorite,
      );
      emit(WordLoaded(words));
    } catch (e) {
      emit(WordError('Failed to load words: $e'));
    }
  }

  FutureOr<void> _onAddWordWithDetails(
    AddWordWithDetails event,
    Emitter<WordState> emit,
  ) async {
    final currentState = state;
    if (currentState is WordLoaded) {
      try {
        final newWord = await _dictionaryRepository.addWord(event.word);

        if (newWord != null) {
          final updatedWords = [...currentState.words, newWord];
          updatedWords.sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));
          emit(WordLoaded(updatedWords));
        } else {
          emit(const WordError('Failed to add word: Unknown error'));
          await Future.delayed(const Duration(seconds: 3));
          emit(currentState);
        }
      } catch (e) {
        emit(WordError('Failed to add word: ${e.toString()}'));
        await Future.delayed(const Duration(seconds: 3));
        emit(currentState);
      }
    }
  }

  FutureOr<void> _onUpdateWord(
    UpdateWord event,
    Emitter<WordState> emit,
  ) async {
    final currentState = state;
    if (currentState is WordLoaded) {
      try {
        final success = await _dictionaryRepository.updateWord(event.word);

        if (success) {
          final updatedWords = currentState.words.map((word) {
            return word.id == event.word.id ? event.word : word;
          }).toList();
          emit(WordLoaded(updatedWords));
        } else {
          emit(const WordError('Failed to update word'));
          await Future.delayed(const Duration(seconds: 3));
          emit(currentState);
        }
      } catch (e) {
        emit(WordError('Failed to update word: ${e.toString()}'));
        await Future.delayed(const Duration(seconds: 3));
        emit(currentState);
      }
    }
  }

  FutureOr<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<WordState> emit,
  ) async {
    final currentState = state;
    if (currentState is WordLoaded) {
      try {
        final success = await _dictionaryRepository.toggleFavorite(
          event.wordId,
          event.isFavorite,
        );

        if (success) {
          final updatedWords = currentState.words.map((word) {
            return word.id == event.wordId
                ? word.copyWith(isFavorite: event.isFavorite)
                : word;
          }).toList();
          emit(WordLoaded(updatedWords));
        } else {
          emit(const WordError('Failed to toggle favorite'));
          await Future.delayed(const Duration(seconds: 3));
          emit(currentState);
        }
      } catch (e) {
        emit(WordError('Failed to toggle favorite: ${e.toString()}'));
        await Future.delayed(const Duration(seconds: 3));
        emit(currentState);
      }
    }
  }

  FutureOr<void> _onSearchWords(
    SearchWords event,
    Emitter<WordState> emit,
  ) async {
    emit(const WordLoading());

    try {
      final words = await _dictionaryRepository.searchLocal(event.query);
      emit(WordLoaded(words));
    } catch (e) {
      emit(WordError('Failed to search words: $e'));
    }
  }
}
