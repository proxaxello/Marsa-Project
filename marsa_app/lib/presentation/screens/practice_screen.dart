import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/data/models/folder_model.dart';
import 'package:marsa_app/logic/blocs/folder/folder_bloc.dart';
import 'package:marsa_app/logic/blocs/folder/folder_event.dart';
import 'package:marsa_app/logic/blocs/folder/folder_state.dart';
import 'package:marsa_app/presentation/screens/folder_detail_screen.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {

  void _handleFolderTap(FolderModel folder) {
    // Navigate to the folder detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderDetailScreen(folder: folder),
      ),
    );
  }

  void _handleCreateFolder() {
    final TextEditingController nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create New Folder'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Folder Name'),
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
            onFieldSubmitted: (_) {
              // Khi nhấn Enter, cũng thực hiện logic như nhấn nút "Create"
              if (formKey.currentState?.validate() ?? false) {
                final name = nameController.text.trim();
                // Gửi sự kiện đến BLoC
                context.read<FolderBloc>().add(AddFolder(name));
                // Đóng dialog
                Navigator.of(dialogContext).pop();
              }
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a folder name';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Validate form
              if (formKey.currentState?.validate() ?? false) {
                // Lấy tên thư mục
                final name = nameController.text.trim();
                // Gửi sự kiện AddFolder đến BLoC
                context.read<FolderBloc>().add(AddFolder(name));
                // Đóng dialog
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocListener<FolderBloc, FolderState>(
      listenWhen: (previous, current) => current is FolderError,
      listener: (context, state) {
        if (state is FolderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Practice'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Refresh folders
                context.read<FolderBloc>().add(const LoadFolders());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Refreshing folders...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: BlocBuilder<FolderBloc, FolderState>(
          builder: (context, state) {
            if (state is FolderLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is FolderError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Retry loading folders
                        context.read<FolderBloc>().add(const LoadFolders());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is FolderLoaded) {
              final folders = state.folders;
              
              if (folders.isEmpty) {
                return const Center(
                  child: Text(
                    'No folders yet. Create your first folder!',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<FolderBloc>().add(const LoadFolders());
                  return Future.delayed(const Duration(seconds: 1));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final folder = folders[index];
                    return Card(
                      elevation: 2.0,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Icon(
                            Icons.folder,
                            color: Theme.of(context).primaryColor,
                            size: 32.0,
                          ),
                        ),
                        title: Text(
                          folder.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${folder.wordCount} words',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _handleFolderTap(folder),
                      ),
                    );
                  },
                ),
              );
            }
            
            // Default case (FolderInitial)
            return const Center(child: Text('Loading folders...'));
          },
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleCreateFolder,
        tooltip: 'Create Folder',
        child: const Icon(Icons.add),
      ),
      ),
    );
  }
}
