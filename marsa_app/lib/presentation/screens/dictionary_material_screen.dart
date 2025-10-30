import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:marsa_app/data/models/word_model.dart';
import 'package:marsa_app/logic/blocs/word/word_bloc.dart';
import 'package:marsa_app/logic/blocs/word/word_event.dart';
import 'package:marsa_app/logic/blocs/word/word_state.dart';

class DictionaryMaterialScreen extends StatefulWidget {
  const DictionaryMaterialScreen({super.key});

  @override
  State<DictionaryMaterialScreen> createState() => _DictionaryMaterialScreenState();
}

class _DictionaryMaterialScreenState extends State<DictionaryMaterialScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  String _selectedCategory = 'ALL';
  bool _showFavoritesOnly = false;
  late AnimationController _animationController;

  final List<String> _categories = [
    'ALL',
    'NOUN',
    'VERB',
    'ADJECTIVE',
    'ADVERB',
    'PHRASE',
    'IDIOM',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
    
    _initTts();
    context.read<WordBloc>().add(const LoadAllWords());
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _flutterTts.stop();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _filterWords() {
    final query = _searchController.text;
    context.read<WordBloc>().add(
          LoadAllWords(
            category: _selectedCategory == 'ALL' ? null : _selectedCategory,
            isFavorite: _showFavoritesOnly ? true : null,
          ),
        );
    if (query.isNotEmpty) {
      context.read<WordBloc>().add(SearchWords(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(),
            
            // Category Chips
            _buildCategoryChips(),
            
            // Word List
            Expanded(
              child: BlocBuilder<WordBloc, WordState>(
                builder: (context, state) {
                  if (state is WordLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is WordLoaded) {
                    if (state.words.isEmpty) {
                      return _buildEmptyState();
                    }

                    return _buildWordList(state.words);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddWordDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Word'),
        elevation: 4,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => _filterWords(),
          decoration: InputDecoration(
            hintText: 'Search dictionary...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[600],
              size: 24,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[600]),
                    onPressed: () {
                      _searchController.clear();
                      _filterWords();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
                _filterWords();
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[700],
              ),
              elevation: isSelected ? 2 : 0,
              pressElevation: 4,
            ),
          );
        },
      ),
    );
  }

  Widget _buildWordList(List<WordModel> words) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: words.length,
      itemBuilder: (context, index) {
        return _buildWordCard(words[index], index);
      },
    );
  }

  Widget _buildWordCard(WordModel word, int index) {
    final delay = index * 50;
    
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delay)),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(height: 0);
        }

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOut,
          )),
          child: FadeTransition(
            opacity: _animationController,
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () => _showWordDetails(word),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Word Header
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  word.word,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (word.category != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _generateIPA(word.word),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Action Buttons
                          IconButton(
                            icon: Icon(
                              Icons.volume_up,
                              color: Colors.blue[400],
                            ),
                            onPressed: () => _speak(word.word),
                            tooltip: 'Pronounce',
                          ),
                          IconButton(
                            icon: Icon(
                              word.isFavorite ? Icons.star : Icons.star_border,
                              color: word.isFavorite
                                  ? Colors.amber
                                  : Colors.grey[400],
                            ),
                            onPressed: () {
                              context.read<WordBloc>().add(
                                    ToggleFavorite(
                                      wordId: word.id!,
                                      isFavorite: !word.isFavorite,
                                    ),
                                  );
                            },
                            tooltip: 'Favorite',
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Category & Difficulty Badges
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (word.category != null)
                            _buildBadge(
                              word.category!,
                              _getCategoryColor(word.category!),
                            ),
                          if (word.difficulty != null)
                            _buildBadge(
                              word.difficulty!,
                              _getDifficultyColor(word.difficulty!),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Meaning
                      Text(
                        word.meaning,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      
                      // Example (if available)
                      if (word.exampleSentence != null &&
                          word.exampleSentence!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                word.exampleSentence!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[800],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              if (word.exampleTranslation != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  word.exampleTranslation!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 12),
                      
                      // Save to Flashcard Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added "${word.word}" to flashcards'),
                                behavior: SnackBarBehavior.floating,
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  onPressed: () {},
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_card),
                          label: const Text('Save to Flashcard'),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'NOUN':
        return Colors.blue;
      case 'VERB':
        return Colors.green;
      case 'ADJECTIVE':
        return Colors.orange;
      case 'ADVERB':
        return Colors.purple;
      case 'PHRASE':
        return Colors.teal;
      case 'IDIOM':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toUpperCase()) {
      case 'BEGINNER':
        return Colors.green;
      case 'INTERMEDIATE':
        return Colors.orange;
      case 'ADVANCED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _generateIPA(String word) {
    final ipaMap = {
      'hello': '/həˈloʊ/',
      'world': '/wɜːrld/',
      'dictionary': '/ˈdɪkʃəneri/',
      'learn': '/lɜːrn/',
      'study': '/ˈstʌdi/',
    };
    return ipaMap[word.toLowerCase()] ?? '/${word.toLowerCase()}/';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No words found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first word to get started',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showWordDetails(WordModel word) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  word.word,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  word.meaning,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.read<WordBloc>().add(DeleteWord(word.id!));
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _speak(word.word);
                        },
                        icon: const Icon(Icons.volume_up),
                        label: const Text('Pronounce'),
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

  void _showAddWordDialog() {
    final formKey = GlobalKey<FormState>();
    final wordController = TextEditingController();
    final meaningController = TextEditingController();
    final exampleController = TextEditingController();
    final translationController = TextEditingController();
    String selectedCategory = 'NOUN';
    String selectedDifficulty = 'BEGINNER';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Add New Word',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: wordController,
                  decoration: const InputDecoration(
                    labelText: 'English Word',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: meaningController,
                  decoration: const InputDecoration(
                    labelText: 'Vietnamese Meaning',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: exampleController,
                  decoration: const InputDecoration(
                    labelText: 'Example Sentence (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: translationController,
                  decoration: const InputDecoration(
                    labelText: 'Translation (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final word = WordModel(
                  id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
                  word: wordController.text.trim(),
                  meaning: meaningController.text.trim(),
                  exampleSentence: exampleController.text.trim().isEmpty
                      ? null
                      : exampleController.text.trim(),
                  exampleTranslation: translationController.text.trim().isEmpty
                      ? null
                      : translationController.text.trim(),
                  category: selectedCategory,
                  difficulty: selectedDifficulty,
                  isFavorite: false,
                );
                context.read<WordBloc>().add(AddWordWithDetails(word));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add Word'),
          ),
        ],
      ),
    );
  }
}
