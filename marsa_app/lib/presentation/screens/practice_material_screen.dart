import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/data/models/folder_model.dart';
import 'package:marsa_app/logic/blocs/folder/folder_bloc.dart';
import 'package:marsa_app/logic/blocs/folder/folder_event.dart';
import 'package:marsa_app/logic/blocs/folder/folder_state.dart';
import 'package:marsa_app/presentation/screens/folder_detail_screen_new.dart';
import 'package:marsa_app/presentation/widgets/glass_card.dart';
import 'package:marsa_app/presentation/widgets/layered_icons.dart';

class PracticeMaterialScreen extends StatefulWidget {
  const PracticeMaterialScreen({super.key});

  @override
  State<PracticeMaterialScreen> createState() => _PracticeMaterialScreenState();
}

class _PracticeMaterialScreenState extends State<PracticeMaterialScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();

    // Load folders when screen opens
    context.read<FolderBloc>().add(const LoadFolders());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleFolderTap(FolderModel folder) async {
    // Navigate to folder vocabulary screen (Quizlet-style)
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderDetailScreenNew(folder: folder),
      ),
    );
    // Reload folders to ensure word count is synchronized
    if (mounted) {
      context.read<FolderBloc>().add(const LoadFolders());
    }
  }

  void _handleCreateFolder() {
    final TextEditingController nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: isDark ? const Color(0xFF202140) : null,
          title: Text(
            'Create New Folder',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : null,
            ),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              style: TextStyle(color: isDark ? Colors.white : null),
              decoration: InputDecoration(
                labelText: 'Folder Name',
                labelStyle: TextStyle(color: isDark ? Colors.white70 : null),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDark ? Colors.white30 : Colors.grey.shade400,
                  ),
                ),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: isDark ? Colors.white70 : null),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8946),
              ),
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final name = nameController.text.trim();
                  context.read<FolderBloc>().add(AddFolder(name));
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0A082D), Color(0xFF1A1C3A)],
                )
              : null,
          color: isDark ? null : Theme.of(context).scaffoldBackgroundColor,
        ),
        child: _buildContent(),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: FloatingActionButton.extended(
          onPressed: _handleCreateFolder,
          icon: const Icon(Icons.add),
          label: const Text('New Folder'),
          elevation: 4,
          backgroundColor: const Color(0xFFFF8946),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<FolderBloc, FolderState>(
              builder: (context, state) {
                return AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Spaced Repetition Block
                      _buildSpacedRepetitionBlock(),
                      const SizedBox(height: 12),

                      // Stats
                      _buildStats(),
                      const SizedBox(height: 16),

                      // Folders Section
                      _buildFoldersSection(state),
                      const SizedBox(height: 24),

                      // Tips
                      _buildTips(),

                      // Add bottom padding for FAB
                      const SizedBox(height: 120),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpacedRepetitionBlock() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1800AD);
    return FadeTransition(
      opacity: _animationController,
      child: GlassCard(
        useGradientBorder: true,
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            LayeredGamepadIcon(size: 48, isDark: isDark),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PLAY & LEARN',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      fontFamily: 'League Spartan',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Practice vocabulary through fun games\nand earn XP!',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white.withOpacity(0.7)
                          : const Color(0xFF0A082D).withOpacity(0.7),
                      fontFamily: 'League Spartan',
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1800AD);
    final secondaryTextColor = isDark
        ? Colors.white70
        : const Color(0xFF1800AD).withOpacity(0.7);
    return Row(
      children: [
        Expanded(
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(-0.3, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.easeOut,
                  ),
                ),
            child: GlassCard(
              solidBorderColor: const Color(0xFFFF8946),
              borderRadius: 16,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      LayeredBoltIcon(size: 18, isDark: isDark),
                      const SizedBox(width: 6),
                      Text(
                        'TOTAL XP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: secondaryTextColor,
                          fontFamily: 'League Spartan',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '0',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF8946),
                      fontFamily: 'League Spartan',
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.easeOut,
                  ),
                ),
            child: GlassCard(
              solidBorderColor: const Color(0xFF9BCFFF),
              borderRadius: 16,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      LayeredStarIcon(size: 18, isDark: isDark),
                      const SizedBox(width: 6),
                      Text(
                        'LEVEL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: secondaryTextColor,
                          fontFamily: 'League Spartan',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '1',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      fontFamily: 'League Spartan',
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoldersSection(FolderState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1800AD);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CHOOSE A FOLDER',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        if (state is FolderLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (state is FolderError)
          _buildErrorState(state.message)
        else if (state is FolderLoaded)
          state.folders.isEmpty
              ? _buildEmptyState()
              : _buildFoldersList(state.folders)
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildFoldersList(List<FolderModel> folders) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final folder = folders[index];

        return FutureBuilder(
          future: Future.delayed(Duration(milliseconds: index * 50)),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(height: 0);
            }

            final isDark = Theme.of(context).brightness == Brightness.dark;
            final textColor = isDark ? Colors.white : const Color(0xFF1800AD);
            final secondaryTextColor = isDark
                ? Colors.white60
                : const Color(0xFF1800AD).withOpacity(0.6);
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOut,
                    ),
                  ),
              child: FadeTransition(
                opacity: _animationController,
                child: GlassCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  solidBorderColor: index % 2 == 0
                      ? const Color(0xFFFF8946)
                      : const Color(0xFF9BCFFF),
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: InkWell(
                    onTap: () => _handleFolderTap(folder),
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      children: [
                        LayeredFolderIcon(size: 42, isDark: isDark),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                folder.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                  fontFamily: 'League Spartan',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${folder.wordCount} words',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: secondaryTextColor,
                                  fontFamily: 'League Spartan',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _buildInfoChip('+50 XP', Icons.bolt),
                            const SizedBox(width: 6),
                            _buildInfoChip('~5 min', Icons.access_time),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          size: 24,
                          color: isDark
                              ? Colors.white54
                              : const Color(0xFF1800AD).withOpacity(0.54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1800AD);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF202140).withOpacity(0.4)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: icon == Icons.bolt
                ? const Color(0xFFFF8946)
                : const Color(0xFF53CFFE),
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: textColor,
              fontFamily: 'League Spartan',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return GlassCard(
      solidBorderColor: Colors.white10,
      borderRadius: 20,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.folder_open, size: 56, color: Colors.white30),
          const SizedBox(height: 12),
          const Text(
            'No Folders Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'League Spartan',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Create your first folder to start practicing!',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
              fontFamily: 'League Spartan',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return GlassCard(
      solidBorderColor: Colors.red.withOpacity(0.3),
      borderRadius: 20,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text(
            'Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'League Spartan',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
              fontFamily: 'League Spartan',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<FolderBloc>().add(const LoadFolders());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8946),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTips() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1800AD);
    return GlassCard(
      useGradientBorder: true,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 PRO TIPS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: textColor,
              fontFamily: 'League Spartan',
            ),
          ),
          const SizedBox(height: 12),
          _buildTipItem('Play daily to maintain your streak'),
          const SizedBox(height: 8),
          _buildTipItem('Higher accuracy = More XP earned'),
          const SizedBox(height: 8),
          _buildTipItem('Complete faster for bonus points'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1800AD);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.only(top: 5),
          decoration: const BoxDecoration(
            color: Color(0xFFFF8946),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
              fontFamily: 'League Spartan',
            ),
          ),
        ),
      ],
    );
  }
}
