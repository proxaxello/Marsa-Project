// TEMPORARY: Stub file to bypass Supabase compiler error
import 'package:marsa_app/data/models/vocabulary_folder_model.dart';

/// Vocabulary Folder Repository - Manages user vocabulary folders in Supabase
/// TEMPORARY: All methods return empty/null to bypass Supabase compiler error
class VocabularyFolderRepository {
  Future<VocabularyFolder?> createFolder(String name, String userId) async => null;
  Future<void> renameFolder(String folderId, String newName) async {}
  Future<void> deleteFolder(String folderId) async {}
  Future<void> addWordToFolder(String folderId, String word) async {}
  Future<void> removeWordFromFolder(String folderId, String word) async {}
  Future<List<VocabularyFolder>> getUserFolders(String userId) async => [];
  Future<List<String>> getFolderWords(String folderId) async => [];
  Future<bool> isWordInFolder(String folderId, String word) async => false;
}
