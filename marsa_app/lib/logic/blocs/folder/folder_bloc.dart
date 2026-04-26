import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/data/repositories/folder_repository.dart';
import 'package:marsa_app/logic/blocs/folder/folder_event.dart';
import 'package:marsa_app/logic/blocs/folder/folder_state.dart';

class FolderBloc extends Bloc<FolderEvent, FolderState> {
  final FolderRepository _folderRepository;
  
  FolderBloc({required FolderRepository folderRepository})
      : _folderRepository = folderRepository,
        super(const FolderInitial()) {
    on<LoadFolders>(_onLoadFolders);
    on<AddFolder>(_onAddFolder);
    on<DeleteFolder>(_onDeleteFolder);

    // Automatically load folders when the bloc is created
    add(const LoadFolders());
  }

  // No longer needed as we're using the repository

  FutureOr<void> _onLoadFolders(
    LoadFolders event,
    Emitter<FolderState> emit,
  ) async {
    emit(const FolderLoading());

    try {
      // Fetch folders from the repository
      final folders = await _folderRepository.fetchFolders();
      
      // Emit loaded state with the fetched folders
      emit(FolderLoaded(folders));
    } catch (e) {
      emit(FolderError('Failed to load folders from the database: $e'));
    }
  }

  FutureOr<void> _onAddFolder(
    AddFolder event,
    Emitter<FolderState> emit,
  ) async {
    // Get current state
    final currentState = state;
    if (currentState is FolderLoaded) {
      try {
        // Create a new folder using the repository
        final newFolder = await _folderRepository.createFolder(event.name);

        // Create a new list with the new folder
        final updatedFolders = [...currentState.folders, newFolder];
        
        // Emit the updated list
        emit(FolderLoaded(updatedFolders));
      } catch (e) {
        emit(FolderError('Failed to add folder: $e'));
      }
    }
  }

  FutureOr<void> _onDeleteFolder(
    DeleteFolder event,
    Emitter<FolderState> emit,
  ) async {
    // Get current state
    final currentState = state;
    if (currentState is FolderLoaded) {
      try {
        // Delete the folder using the repository
        final success = await _folderRepository.deleteFolder(event.id);
        
        if (success) {
          // Create a new list without the deleted folder
          final updatedFolders = currentState.folders
              .where((folder) => folder.id != event.id)
              .toList();
          
          // Emit the updated list
          emit(FolderLoaded(updatedFolders));
        } else {
          emit(FolderError('Failed to delete folder: Folder not found'));
        }
      } catch (e) {
        emit(FolderError('Failed to delete folder: $e'));
      }
    }
  }
}
