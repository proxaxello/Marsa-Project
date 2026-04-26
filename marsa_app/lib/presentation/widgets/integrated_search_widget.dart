import 'dart:ui';
import 'package:flutter/material.dart';
// TEMPORARY: Commented out to bypass Supabase compiler error
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:marsa_app/data/services/dictionary_service.dart';
// import 'package:marsa_app/data/repositories/search_history_repository.dart';
import 'package:marsa_app/data/models/search_suggestion_model.dart';
import 'package:marsa_app/utils/debouncer.dart';
import 'package:marsa_app/presentation/screens/word_detail_screen.dart';

/// Integrated Search Widget - Embedded search with overlay
class IntegratedSearchWidget extends StatefulWidget {
  const IntegratedSearchWidget({super.key});

  @override
  State<IntegratedSearchWidget> createState() => _IntegratedSearchWidgetState();
}

class _IntegratedSearchWidgetState extends State<IntegratedSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  // TEMPORARY: Commented out to bypass Supabase compiler error
  // final SearchHistoryRepository _historyRepo = SearchHistoryRepository();
  final Debouncer _debouncer = Debouncer(milliseconds: 300);

  bool _isSearching = false;
  bool _isLoadingSuggestions = false;
  bool _showOverlay = false;
  List<String> _searchHistory = [];
  List<SearchSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();

    print('═══════════════════════════════════════════');
    print('[WIDGET] IntegratedSearchWidget initState');
    print('═══════════════════════════════════════════');

    // Initialize database
    DictionaryService.initDatabase();

    _searchFocus.addListener(() {
      if (_searchFocus.hasFocus) {
        print('[FOCUS] Search bar focused - loading history');
        _loadSearchHistory();
        setState(() {
          _showOverlay = true;
        });
      } else {
        print('[FOCUS] Search bar unfocused');
      }
    });

    // REMOVED: _searchController.addListener(_onSearchTextChanged);
    // We only use onChanged callback in TextField to avoid duplicate calls
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    // TEMPORARY: Commented out to bypass Supabase compiler error
    // final user = Supabase.instance.client.auth.currentUser;
    // if (user == null) return;
    //
    // final history = await _historyRepo.getUniqueRecentSearches(
    //   user.id,
    //   limit: 10,
    // );
    // if (mounted) {
    //   setState(() {
    //     _searchHistory = history;
    //   });
    // }
  }

  void _onSearchTextChanged() {
    final query = _searchController.text.trim();

    print('═══════════════════════════════════════════');
    print('[SEARCH] _onSearchTextChanged called');
    print('[SEARCH] Query: "$query" (length: ${query.length})');
    print('═══════════════════════════════════════════');

    if (query.isEmpty) {
      print('[SEARCH] Query empty - clearing suggestions, showing history');
      setState(() {
        _suggestions = [];
        _isLoadingSuggestions = false;
        _showOverlay = _searchHistory.isNotEmpty;
      });
      return;
    }

    // Show loading state immediately
    print('[SEARCH] Setting loading state...');
    setState(() {
      _isLoadingSuggestions = true;
      _showOverlay = true;
    });

    // Debounce suggestions
    print('[SEARCH] Starting debouncer (300ms delay)...');
    _debouncer.run(() async {
      print('═══════════════════════════════════════════');
      print('[DEBOUNCER] Executing after 300ms delay');
      print('[DEBOUNCER] Current query: "$query"');
      print('[DEBOUNCER] TextField text: "${_searchController.text.trim()}"');
      print('═══════════════════════════════════════════');

      if (_searchController.text.trim() == query) {
        print('[DEBOUNCER] Query still matches - proceeding with search');

        // OPTIMIZED: Single query gets all data (word + phonetic + meaning)
        final suggestions = await DictionaryService.getSuggestionsWithDetails(
          query,
          limit: 30,
        );

        print('═══════════════════════════════════════════');
        print('[UI] ✓ POINT 2: Service Response Received');
        print('[UI] Service returned ${suggestions.length} items');
        if (suggestions.isNotEmpty) {
          print(
            '[UI] First 3: ${suggestions.take(3).map((s) => s.word).join(", ")}',
          );
          print(
            '[UI] Sample data - word: "${suggestions.first.word}", phonetic: "${suggestions.first.phonetic}", meaning: "${suggestions.first.briefMeaning}"',
          );
        }
        print('═══════════════════════════════════════════');

        if (mounted) {
          setState(() {
            _suggestions = suggestions;
            _isLoadingSuggestions = false;
            _showOverlay = true;
          });
          print('═══════════════════════════════════════════');
          print('[UI] ✓ setState() called - UI should update now');
          print('[UI] _suggestions.length = ${_suggestions.length}');
          print('[UI] _showOverlay = $_showOverlay');
          print('[UI] _isLoadingSuggestions = $_isLoadingSuggestions');
          print('═══════════════════════════════════════════');
        }
      } else {
        print(
          '[DEBOUNCER] Query changed during debounce - skipping stale search',
        );
        if (mounted) {
          setState(() {
            _isLoadingSuggestions = false;
          });
        }
      }
    });
  }

  Future<void> _searchWord(String word) async {
    if (word.trim().isEmpty) return;

    print('[TAP] User selected word: "$word"');
    setState(() {
      _isSearching = true;
      _showOverlay = false;
    });

    try {
      print('[SEARCH] Fetching full entry for: "$word"');
      final entry = await DictionaryService.searchWord(word);

      // TEMPORARY: Commented out to bypass Supabase compiler error
      // Save to history
      // final user = Supabase.instance.client.auth.currentUser;
      // if (user != null) {
      //   print('[SUPABASE] Saving search history for user: ${user.id}');
      //   await _historyRepo.saveSearchHistory(word, user.id);
      //   print('[SUPABASE] ✓ Saved search history: "$word"');
      // } else {
      //   print('[SUPABASE] ✗ No user logged in, skipping history save');
      // }

      if (mounted) {
        setState(() {
          _isSearching = false;
        });

        // Navigate to full-screen word detail
        if (entry != null) {
          print('[NAV] Opening WordDetailScreen for: "$word"');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WordDetailScreen(entry: entry),
            ),
          );
        } else {
          print('[NAV] ✗ No entry found for: "$word"');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _closeOverlay() {
    setState(() {
      _showOverlay = false;
      _searchFocus.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF202140) : const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: isDark
                    ? Colors.white.withOpacity(0.6)
                    : const Color(0xFF999999),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  enabled: true,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0a082d),
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.5)
                          : const Color(0xFF999999),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    print('═══════════════════════════════════════════');
                    print('[UI] ✓ POINT 1: onChanged TRIGGERED');
                    print('[UI] Typing: "$value"');
                    print('[UI] Text length: ${value.length}');
                    print('═══════════════════════════════════════════');
                    // Instant search on text change
                    _onSearchTextChanged();
                  },
                  onSubmitted: _searchWord,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.mic,
                color: isDark
                    ? Colors.white.withOpacity(0.6)
                    : const Color(0xFF999999),
                size: 22,
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.camera_alt,
                color: isDark
                    ? Colors.white.withOpacity(0.6)
                    : const Color(0xFF999999),
                size: 22,
              ),
            ],
          ),
        ),

        // Loading Indicator
        if (_isSearching)
          Container(
            margin: const EdgeInsets.only(top: 12),
            child: const CircularProgressIndicator(color: Color(0xFFf64a00)),
          ),

        // Full-screen suggestion overlay with dismiss on tap outside
        if (_showOverlay)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                print('[OVERLAY] Tap outside detected - closing overlay');
                _closeOverlay();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0a0e27) : Colors.white,
                  border: Border.all(color: Colors.red, width: 3),
                ),
                child: Column(
                  children: [
                    // Debug header
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.red.withOpacity(0.2),
                      child: Text(
                        'DEBUG OVERLAY: ${_isLoadingSuggestions
                            ? "LOADING"
                            : _suggestions.isEmpty
                            ? "EMPTY"
                            : "${_suggestions.length} RESULTS"}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _isLoadingSuggestions
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: isDark
                                        ? const Color(0xFFFF8946)
                                        : const Color(0xFFf64a00),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Đang tìm kiếm...',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.7)
                                          : const Color(0xFF999999),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _suggestions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.3)
                                        : const Color(0xFFCCCCCC),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Không tìm thấy kết quả',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.7)
                                          : const Color(0xFF999999),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Thử tìm kiếm từ khác',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.5)
                                          : const Color(0xFFCCCCCC),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GestureDetector(
                              onTap:
                                  () {}, // Prevent tap from propagating to parent
                              child: Builder(
                                builder: (context) {
                                  print(
                                    '═══════════════════════════════════════════',
                                  );
                                  print(
                                    '[UI] ✓ POINT 3: ListView.builder RENDERING',
                                  );
                                  print(
                                    '[UI] Rendering ${_suggestions.length} items in overlay',
                                  );
                                  if (_suggestions.isNotEmpty) {
                                    print(
                                      '[UI] First item to render: "${_suggestions.first.word}"',
                                    );
                                  }
                                  print(
                                    '═══════════════════════════════════════════',
                                  );
                                  return ListView.builder(
                                    padding: const EdgeInsets.all(0),
                                    itemCount: _suggestions.length,
                                    itemBuilder: (context, index) {
                                      final suggestion = _suggestions[index];
                                      if (index == 0) {
                                        print(
                                          '[UI] Building first tile: "${suggestion.word}"',
                                        );
                                      }
                                      return _buildSuggestionTile(
                                        suggestion,
                                        isDark,
                                      );
                                    },
                                  );
                                },
                              ),
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

  Widget _buildSuggestionTile(SearchSuggestion suggestion, bool isDark) {
    return InkWell(
      onTap: () {
        print('[TAP] User tapped suggestion: "${suggestion.word}"');
        _searchWord(suggestion.word);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.shade300,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.word,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (suggestion.phonetic.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      suggestion.phonetic,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (suggestion.briefMeaning.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      suggestion.briefMeaning,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(bool isDark) {
    if (_searchHistory.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'No recent searches',
          style: TextStyle(
            color: isDark
                ? Colors.white.withOpacity(0.5)
                : const Color(0xFF999999),
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchHistory.length,
      itemBuilder: (context, index) {
        final word = _searchHistory[index];
        return ListTile(
          dense: true,
          leading: Icon(
            Icons.history,
            color: isDark
                ? Colors.white.withOpacity(0.6)
                : const Color(0xFF999999),
            size: 20,
          ),
          title: Text(
            word,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0a082d),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: isDark
                ? Colors.white.withOpacity(0.6)
                : const Color(0xFF999999),
            size: 16,
          ),
          onTap: () => _searchWord(word),
        );
      },
    );
  }

  Widget _buildSuggestionsList(bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return ListTile(
          dense: true,
          leading: Icon(
            Icons.search,
            color: isDark ? const Color(0xFF53cffe) : const Color(0xFF1800ad),
            size: 20,
          ),
          title: Row(
            children: [
              Text(
                suggestion.word,
                style: const TextStyle(
                  color: Color(0xFFff8946),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (suggestion.phonetic.isNotEmpty) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    suggestion.phonetic,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0a082d),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          subtitle: suggestion.briefMeaning.isNotEmpty
              ? Text(
                  suggestion.briefMeaning,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : const Color(0xFF4B4B4B),
                    fontSize: 12,
                  ),
                )
              : null,
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: isDark
                ? Colors.white.withOpacity(0.6)
                : const Color(0xFF999999),
            size: 16,
          ),
          onTap: () => _searchWord(suggestion.word),
        );
      },
    );
  }
}
