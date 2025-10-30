import 'package:equatable/equatable.dart';
import 'package:marsa_app/data/models/folder_model.dart';

abstract class FolderState extends Equatable {
  const FolderState();

  @override
  List<Object> get props => [];
}

class FolderInitial extends FolderState {
  const FolderInitial();
}

class FolderLoading extends FolderState {
  const FolderLoading();
}

class FolderLoaded extends FolderState {
  final List<FolderModel> folders;

  const FolderLoaded(this.folders);

  @override
  List<Object> get props => [folders];
}

class FolderError extends FolderState {
  final String message;

  const FolderError(this.message);

  @override
  List<Object> get props => [message];
}
