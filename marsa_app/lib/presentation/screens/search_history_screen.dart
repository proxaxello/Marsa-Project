import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:marsa_app/data/repositories/search_history_repository.dart';

class SearchHistoryScreen extends StatefulWidget {
  const SearchHistoryScreen({super.key});

  @override
  State<SearchHistoryScreen> createState() => _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends State<SearchHistoryScreen> {
  final SearchHistoryRepository _historyRepo = SearchHistoryRepository();
  List<String> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final searches = await _historyRepo.getUniqueRecentSearches(
      user.id,
      limit: 100,
    );
    
    setState(() {
      _history = searches;
      _isLoading = false;
    });
  }

  Future<void> _clearHistory() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await _historyRepo.clearHistory(user.id);
      setState(() {
        _history = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0a0e27)
          : const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF0a0e27)
            : const Color(0xFFF8F8F8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : const Color(0xFF12100E),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lịch sử tra cứu',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF12100E),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: isDark ? Colors.white : const Color(0xFF12100E),
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xóa lịch sử'),
                    content: const Text('Bạn có chắc muốn xóa toàn bộ lịch sử?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Xóa'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _clearHistory();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 80,
                        color: isDark
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có lịch sử tra cứu',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withOpacity(0.5)
                              : const Color(0xFF999999),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final word = _history[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.pop(context, word);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.history,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.7)
                                      : const Color(0xFF999999),
                                  size: 20,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    word,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF12100E),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.5)
                                      : const Color(0xFF999999),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
