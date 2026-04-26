import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/data/models/folder_model.dart';
import 'package:marsa_app/logic/blocs/folder/folder_bloc.dart';
import 'package:marsa_app/logic/blocs/folder/folder_event.dart';
import 'package:marsa_app/logic/blocs/folder/folder_state.dart';
import 'package:marsa_app/logic/providers/text_size_provider.dart';
import 'package:marsa_app/presentation/screens/folder_detail_screen_new.dart';
import 'package:marsa_app/presentation/theme/material_theme.dart';
import 'package:marsa_app/presentation/widgets/gradient_icon.dart';

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
        builder: (context) => FolderDetailScreenNew(folder: folder),
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
    final textSizeProvider = context.watch<TextSizeProvider>();

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textSizeProvider.fontSizeMultiplier),
      ),
      child: BlocListener<FolderBloc, FolderState>(
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
        child: Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final bgColor = isDark
                ? const Color(0xFF0A082D)
                : Theme.of(context).scaffoldBackgroundColor;
            final textColor = isDark ? Colors.white : AppColors.lightText;

            return Scaffold(
              backgroundColor: bgColor,
              appBar: AppBar(
                title: Text('Luyện tập', style: TextStyle(color: textColor)),
                backgroundColor: bgColor,
                elevation: 0,
                iconTheme: IconThemeData(color: textColor),
                actions: [
                  IconButton(
                    icon: GradientIcon(
                      icon: Icons.refresh,
                      size: 24,
                      gradient: AppColors.actionIconGradient,
                    ),
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
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.premiumAccent,
                      ),
                    );
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
                              context.read<FolderBloc>().add(
                                const LoadFolders(),
                              );
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
                      return Center(
                        child: Text(
                          'Chưa có thư mục nào. Tạo thư mục đầu tiên!',
                          style: TextStyle(fontSize: 16, color: textColor),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<FolderBloc>().add(const LoadFolders());
                        return Future.delayed(const Duration(seconds: 1));
                      },
                      child: Column(
                        children: [
                          _buildPlayLearnCard(context, isDark),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              itemCount: folders.length,
                              itemBuilder: (context, index) {
                                final folder = folders[index];
                                return _buildGlassmorphismFolderCard(
                                  context,
                                  folder,
                                  index,
                                  isDark,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Default case (FolderInitial)
                  return Center(
                    child: Text(
                      'Loading folders...',
                      style: TextStyle(color: textColor),
                    ),
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: _handleCreateFolder,
                tooltip: 'Tạo thư mục',
                backgroundColor: AppColors.premiumAccent,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build PLAY & LEARN glassmorphism card
  Widget _buildPlayLearnCard(BuildContext context, bool isDark) {
    final textColor = Colors.white;
    final secondaryTextColor = Colors.white70;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF202140).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(width: 1.5, color: Colors.transparent),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: AppColors.actionIconGradient,
              ),
              padding: const EdgeInsets.all(1.5),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF202140).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.actionIconGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.play_circle_filled,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PLAY & LEARN',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Chọn thư mục để bắt đầu luyện tập',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build glassmorphism folder card with gradient border
  Widget _buildGlassmorphismFolderCard(
    BuildContext context,
    FolderModel folder,
    int index,
    bool isDark,
  ) {
    final textColor = Colors.white;
    final secondaryTextColor = Colors.white70;

    // Folder colors for visual variety
    final colors = [
      AppColors.premiumAccent,
      AppColors.gradientStart,
      AppColors.gradientEnd,
      const Color(0xFFFF6B9D),
    ];
    final folderColor = colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF202140).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: AppColors.actionIconGradient,
              ),
              padding: const EdgeInsets.all(1.5),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF202140).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14.5),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14.5),
                    onTap: () => _handleFolderTap(folder),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: folderColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: GradientIcon(
                              icon: Icons.folder,
                              size: 32,
                              gradient: AppColors.actionIconGradient,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  folder.name.toUpperCase(),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${folder.wordCount} từ vựng',
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: secondaryTextColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
