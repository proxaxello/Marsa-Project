import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/data/models/folder_model.dart';
import 'package:marsa_app/logic/blocs/folder/folder_bloc.dart';
import 'package:marsa_app/logic/blocs/folder/folder_event.dart';
import 'package:marsa_app/logic/blocs/folder/folder_state.dart';
import 'package:marsa_app/presentation/screens/game_selection_screen.dart';
import 'package:marsa_app/presentation/theme/neo_brutal_theme.dart';

class PracticeMenuScreen extends StatefulWidget {
  const PracticeMenuScreen({super.key});

  @override
  State<PracticeMenuScreen> createState() => _PracticeMenuScreenState();
}

class _PracticeMenuScreenState extends State<PracticeMenuScreen> {
  @override
  void initState() {
    super.initState();
    // Load folders when screen opens
    context.read<FolderBloc>().add(const LoadFolders());
  }

  void _handleFolderTap(FolderModel folder) {
    // Navigate to game selection screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameSelectionScreen(folder: folder),
      ),
    );
  }

  void _handleCreateFolder() {
    final TextEditingController nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: const Offset(8, 8),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CREATE FOLDER',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  child: TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Folder name...',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black38,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a folder name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        if (formKey.currentState?.validate() ?? false) {
                          final name = nameController.text.trim();
                          context.read<FolderBloc>().add(AddFolder(name));
                          Navigator.of(dialogContext).pop();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: NeoBrutalTheme.neonGreen,
                          border: Border.all(color: Colors.black, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'CREATE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<FolderBloc, FolderState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Section
                    _buildHeroSection(),
                    const SizedBox(height: 24),

                    // Folders Grid
                    _buildFoldersSection(state),
                    const SizedBox(height: 24),

                    // Learning Tips
                    _buildLearningTips(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: _buildCreateFolderButton(),
    );
  }

  Widget _buildHeroSection() {
    return Transform.rotate(
      angle: 0.02,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: NeoBrutalTheme.neonGreen,
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(8, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'PRACTICE',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                height: 1.0,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Choose a folder to start learning!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoldersSection(FolderState state) {
    if (state is FolderLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(
            strokeWidth: 4,
            color: Colors.black,
          ),
        ),
      );
    }

    if (state is FolderError) {
      return _buildErrorState(state.message);
    }

    if (state is FolderLoaded) {
      final folders = state.folders;

      if (folders.isEmpty) {
        return _buildEmptyState();
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: folders.length,
        itemBuilder: (context, index) {
          final folder = folders[index];
          final colors = [
            NeoBrutalTheme.electricYellow,
            NeoBrutalTheme.hotPink,
            NeoBrutalTheme.cyanBlue,
            NeoBrutalTheme.neonGreen,
          ];
          final color = colors[index % colors.length];
          final rotations = [-0.01, 0.01, -0.01, 0.01];
          final rotation = rotations[index % rotations.length];

          return _buildFolderCard(folder, color, rotation);
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildFolderCard(FolderModel folder, Color color, double rotation) {
    return Transform.rotate(
      angle: rotation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleFolderTap(folder),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  offset: const Offset(6, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.black, width: 4),
                  ),
                  child: const Icon(
                    Icons.folder,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      folder.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${folder.wordCount} WORDS',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.black, width: 3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'START',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        size: 24,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Transform.rotate(
      angle: -0.01,
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: NeoBrutalTheme.cyanBlue,
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(6, 6),
            ),
          ],
        ),
        child: Column(
          children: const [
            Icon(
              Icons.folder_open,
              size: 80,
              color: Colors.black,
            ),
            SizedBox(height: 16),
            Text(
              'NO FOLDERS YET',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Create your first folder to start practicing!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Transform.rotate(
      angle: 0.01,
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: NeoBrutalTheme.hotPink,
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(6, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.black,
            ),
            const SizedBox(height: 16),
            const Text(
              'ERROR',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                context.read<FolderBloc>().add(const LoadFolders());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.black, width: 3),
                ),
                child: const Text(
                  'RETRY',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningTips() {
    return Transform.rotate(
      angle: -0.01,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(6, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LEARNING TIPS',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildTipItem(
              number: '1',
              title: 'PRACTICE DAILY',
              description: 'Spend 10-15 minutes every day for best results',
              color: NeoBrutalTheme.electricYellow,
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              number: '2',
              title: 'MIX IT UP',
              description: 'Try all game modes to reinforce learning',
              color: NeoBrutalTheme.hotPink,
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              number: '3',
              title: 'SAVE FAVORITES',
              description: 'Mark difficult words to review later',
              color: NeoBrutalTheme.cyanBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem({
    required String number,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black, width: 4),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreateFolderButton() {
    return GestureDetector(
      onTap: _handleCreateFolder,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: NeoBrutalTheme.neonGreen,
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          size: 32,
          color: Colors.black,
        ),
      ),
    );
  }
}
