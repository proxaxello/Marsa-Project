import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:marsa_app/data/repositories/supabase_folder_repository.dart';
import 'package:marsa_app/config/theme_colors.dart';

/// Simple Practice Screen with Folder Creation
class PracticeScreenSimple extends StatefulWidget {
  const PracticeScreenSimple({super.key});

  @override
  State<PracticeScreenSimple> createState() => _PracticeScreenSimpleState();
}

class _PracticeScreenSimpleState extends State<PracticeScreenSimple> {
  final TextEditingController _folderNameController = TextEditingController();
  final SupabaseFolderRepository _folderRepo = SupabaseFolderRepository();
  List<Map<String, dynamic>> _userFolders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    try {
      final folders = await _folderRepo.fetchUserFolders();
      setState(() {
        _userFolders = folders;
        _isLoading = false;
      });
    } catch (e) {
      print('[FOLDER_LOAD_ERROR] $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải thư mục: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  void _showCreateFolderDialog() {
    _folderNameController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Tạo thư mục mới',
            style: TextStyle(
              color: Color(0xFF12100E),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: _folderNameController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Nhập tên thư mục',
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: ThemeColors.getPrimary(context),
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Hủy',
                style: TextStyle(color: Color(0xFF999999)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final folderName = _folderNameController.text.trim();
                if (folderName.isNotEmpty) {
                  try {
                    final newFolder = await _folderRepo.createFolder(
                      folderName,
                    );
                    setState(() {
                      _userFolders.insert(0, newFolder);
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã tạo thư mục "$folderName"'),
                        backgroundColor: const Color(0xFF57d9b2),
                      ),
                    );
                  } catch (e) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.getPrimary(context),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tạo'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Space Repetition Section
              Text(
                'Space repetition',
                style: TextStyle(
                  color: theme.colorScheme.onBackground,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x38FFFFFF) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Spaced repetition visualization
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildRepetitionBar(
                          '1',
                          1200,
                          theme.colorScheme.secondary,
                          120,
                        ),
                        _buildRepetitionBar(
                          '2',
                          20,
                          theme.colorScheme.secondary,
                          20,
                        ),
                        _buildRepetitionBar(
                          '3',
                          15,
                          theme.colorScheme.secondary,
                          15,
                        ),
                        _buildRepetitionBar(
                          '4',
                          10,
                          theme.colorScheme.secondary,
                          10,
                        ),
                        _buildRepetitionBar(
                          'Nhớ sâu',
                          400,
                          const Color(0xFF57d9b2),
                          80,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Review button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '+ 1245 Từ cần ôn tập',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Tệp đã tạo (Created Folders) Section
              Text(
                'Tệp đã tạo',
                style: TextStyle(
                  color: theme.colorScheme.onBackground,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _userFolders.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text(
                          'Chưa có thư mục nào.\nNhấn nút + để tạo thư mục mới.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _userFolders.length,
                      itemBuilder: (context, index) {
                        final folder = _userFolders[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0x38FFFFFF)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.folder,
                                    color: theme.colorScheme.primary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        folder['name'],
                                        style: TextStyle(
                                          color: theme.colorScheme.onBackground,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${folder['card_count'] ?? 0} cards · by you',
                                        style: TextStyle(
                                          color:
                                              theme.textTheme.bodyMedium?.color,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  color: theme.textTheme.bodyMedium?.color,
                                  onPressed: () =>
                                      _showFolderMenu(context, folder),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 32),

              // Từ vựng theo chủ đề (Topic Vocabulary) Section
              Text(
                'Từ vựng theo chủ đề',
                style: TextStyle(
                  color: theme.colorScheme.onBackground,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTopicCard(
                      'CHIẾN TRANH',
                      '150+',
                      ThemeColors.getAccent(context),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTopicCard(
                      'KINH TẾ',
                      '200+',
                      ThemeColors.getAccent(context),
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Luyện tập theo trò chơi (Practice Games) Section
              Text(
                'Luyện tập theo trò chơi',
                style: TextStyle(
                  color: theme.colorScheme.onBackground,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildGameCard(
                'Flashcards',
                Icons.style,
                theme.colorScheme.primary,
                false,
                isDark,
              ),
              const SizedBox(height: 12),
              _buildGameCard(
                'Learn',
                Icons.school,
                theme.colorScheme.primary,
                true,
                isDark,
              ),
              const SizedBox(height: 12),
              _buildGameCard(
                'Test',
                Icons.assignment,
                theme.colorScheme.primary,
                true,
                isDark,
              ),
              const SizedBox(height: 12),
              _buildGameCard(
                'Match',
                Icons.grid_view,
                theme.colorScheme.primary,
                false,
                isDark,
              ),
              const SizedBox(height: 12),
              _buildGameCard(
                'Blast',
                Icons.flash_on,
                theme.colorScheme.primary,
                false,
                isDark,
              ),
              const SizedBox(height: 12),
              _buildGameCard(
                'Blocks',
                Icons.grid_4x4,
                theme.colorScheme.primary,
                false,
                isDark,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: FloatingActionButton(
          onPressed: _showCreateFolderDialog,
          backgroundColor: theme.colorScheme.primary,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showFolderMenu(BuildContext context, Map<String, dynamic> folder) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Đổi tên'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(folder);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(folder);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(Map<String, dynamic> folder) {
    final controller = TextEditingController(text: folder['name']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi tên thư mục'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nhập tên mới',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                try {
                  await _folderRepo.updateFolder(folder['id'], newName);
                  setState(() {
                    folder['name'] = newName;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã đổi tên thư mục')),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.getPrimary(context),
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thư mục'),
        content: Text('Bạn có chắc muốn xóa "${folder['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await _folderRepo.deleteFolder(folder['id']);
                setState(() {
                  _userFolders.remove(folder);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Đã xóa thư mục')));
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Widget _buildRepetitionBar(
    String label,
    int count,
    Color color,
    double height,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: const TextStyle(
            color: Color(0xFF12100E),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF999999), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildTopicCard(
    String title,
    String count,
    Color accentColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x38FFFFFF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: accentColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                count,
                style: TextStyle(
                  color: ThemeColors.getPrimary(context),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Từ vựng',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFCCCCCC)
                      : const Color(0xFF999999),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(
    String title,
    IconData icon,
    Color iconColor,
    bool isLocked,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x38FFFFFF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF12100E),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isLocked)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ThemeColors.getAccent(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.lock,
                color: ThemeColors.getAccent(context),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
