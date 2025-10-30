import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/data/models/word_model.dart';
import 'package:marsa_app/logic/blocs/search/search_bloc.dart';
import 'package:marsa_app/logic/blocs/search/search_event.dart';
import 'package:marsa_app/logic/blocs/search/search_state.dart';
import 'package:marsa_app/presentation/widgets/search_bar_widget.dart';
import 'package:marsa_app/presentation/widgets/search_results_widget.dart';
import 'package:marsa_app/presentation/widgets/trending_keywords_widget.dart';
import 'package:marsa_app/presentation/widgets/search_history_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Sample data for trending keywords
  final List<String> _trendingKeywords = [
    'Success',
    'Motivation',
    'Technology',
    'Business',
    'Education',
    'Health',
    'Travel',
    'Science',
  ];
  
  // Sample data for search history
  final List<SearchHistoryItem> _searchHistory = [
    SearchHistoryItem(
      word: 'Success',
      meaning: 'Sự thành công',
      searchedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    SearchHistoryItem(
      word: 'Motivation',
      meaning: 'Động lực',
      searchedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SearchHistoryItem(
      word: 'Technology',
      meaning: 'Công nghệ',
      searchedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    SearchHistoryItem(
      word: 'Innovation',
      meaning: 'Sự đổi mới',
      searchedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    SearchHistoryItem(
      word: 'Perseverance',
      meaning: 'Sự kiên trì',
      searchedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  void _handleSearch() {
    final searchTerm = _searchController.text;
    if (searchTerm.isNotEmpty) {
      // Dispatch search event to the BLoC
      context.read<SearchBloc>().add(SearchSubmitted(searchTerm));
    }
  }

  void _handleMicPressed() {
    // This would be implemented with voice input logic in the future
    print('Microphone pressed');
  }

  void _handleHandwritingPressed() {
    // This would be implemented with handwriting input logic in the future
    print('Handwriting pressed');
  }

  void _handleCameraPressed() {
    // This would be implemented with camera input logic in the future
    print('Camera pressed');
  }

  void _handleKeywordTap(String keyword) {
    // Set the search controller text to the tapped keyword
    _searchController.text = keyword;
    // Dispatch search event to the BLoC
    context.read<SearchBloc>().add(SearchSubmitted(keyword));
  }

  void _handleHistoryItemTap(SearchHistoryItem item) {
    // Set the search controller text to the tapped history item
    _searchController.text = item.word;
    // Dispatch search event to the BLoC
    context.read<SearchBloc>().add(SearchSubmitted(item.word));
  }

  void _handleClearHistory() {
    // This would clear the search history in a real implementation
    print('Clear history pressed');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar with Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Marsa',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SearchBarWidget(
                controller: _searchController,
                onSearchPressed: _handleSearch,
                onMicPressed: _handleMicPressed,
                onHandwritingPressed: _handleHandwritingPressed,
                onCameraPressed: _handleCameraPressed,
              ),
            ),
            
            // Content Area (Scrollable)
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  // Show loading indicator when searching
                  if (state is SearchLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  // Show error message if search failed
                  if (state is SearchFailure) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${state.errorMessage}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Clear search and return to initial state
                                _searchController.clear();
                                context.read<SearchBloc>().add(SearchCleared());
                              },
                              child: const Text('Clear Search'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  // Show search results if search was successful
                  if (state is SearchSuccess) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Search Results',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          SearchResultsWidget(
                            results: state.results,
                            onResultTap: (wordModel) {
                              // Handle result tap
                              print('Tapped on word: ${wordModel.word}, meaning: ${wordModel.meaning}');
                              // Here you could navigate to a detail screen or show a dialog with the full definition
                            },
                          ),
                        ],
                      ),
                    );
                  }
                  
                  // Default view (SearchInitial state)
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16.0),
                        
                        // Trending Keywords Section
                        TrendingKeywordsWidget(
                          keywords: _trendingKeywords,
                          onKeywordTap: _handleKeywordTap,
                        ),
                        
                        const SizedBox(height: 16.0),
                        const Divider(),
                        
                        // Search History Section
                        SearchHistoryWidget(
                          historyItems: _searchHistory,
                          onItemTap: _handleHistoryItemTap,
                          onClearHistory: _handleClearHistory,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
