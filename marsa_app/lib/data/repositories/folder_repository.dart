import 'package:marsa_app/data/models/folder_model.dart';
import 'package:marsa_app/data/providers/folder_provider.dart';

class FolderRepository {
  final FolderProvider _folderProvider;

  FolderRepository({required FolderProvider folderProvider})
      : _folderProvider = folderProvider;

  // Fetch all folders from the database
  Future<List<FolderModel>> fetchFolders() async {
    try {
      final folderMaps = await _folderProvider.getFolders();
      return folderMaps.map((map) => FolderModel(
        id: map['id'],
        name: map['name'],
        wordCount: map['wordCount'],
      )).toList();
    } catch (e) {
      // Log the error
      print('Error fetching folders: $e');
      // Rethrow to allow the BLoC to handle it
      rethrow;
    }
  }

  // Create a new folder
  Future<FolderModel> createFolder(String name) async {
    try {
      final id = await _folderProvider.createFolder(name);
      return FolderModel(id: id, name: name, wordCount: 0);
    } catch (e) {
      print('Error creating folder: $e');
      rethrow;
    }
  }

  // Get a folder by ID
  Future<FolderModel?> getFolder(int id) async {
    try {
      final folderMap = await _folderProvider.getFolder(id);
      if (folderMap != null) {
        return FolderModel(
          id: folderMap['id'],
          name: folderMap['name'],
          wordCount: folderMap['wordCount'],
        );
      }
      return null;
    } catch (e) {
      print('Error getting folder: $e');
      rethrow;
    }
  }

  // Update a folder
  Future<bool> updateFolder(FolderModel folder) async {
    try {
      final rowsAffected = await _folderProvider.updateFolder(
        folder.id,
        folder.name,
        folder.wordCount,
      );
      return rowsAffected > 0;
    } catch (e) {
      print('Error updating folder: $e');
      rethrow;
    }
  }

  // Delete a folder
  Future<bool> deleteFolder(int id) async {
    try {
      final rowsAffected = await _folderProvider.deleteFolder(id);
      return rowsAffected > 0;
    } catch (e) {
      print('Error deleting folder: $e');
      rethrow;
    }
  }
}
