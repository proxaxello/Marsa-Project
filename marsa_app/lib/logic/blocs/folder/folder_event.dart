import 'package:equatable/equatable.dart';

abstract class FolderEvent extends Equatable {
  const FolderEvent();

  @override
  List<Object> get props => [];
}

class LoadFolders extends FolderEvent {
  const LoadFolders();
}

class AddFolder extends FolderEvent {
  final String name;

  const AddFolder(this.name);

  @override
  List<Object> get props => [name];
}

class DeleteFolder extends FolderEvent {
  final int id;

  const DeleteFolder(this.id);

  @override
  List<Object> get props => [id];
}
