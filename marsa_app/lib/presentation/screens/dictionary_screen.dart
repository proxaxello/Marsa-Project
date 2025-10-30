import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:marsa_app/data/models/word_model.dart';
import 'package:marsa_app/logic/blocs/word/word_bloc.dart';
import 'package:marsa_app/logic/blocs/word/word_event.dart';
import 'package:marsa_app/logic/blocs/word/word_state.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  
  String _filterCategory = 'all';
  bool _showAddForm = false;
  bool _isOnline = true;
  
  // New word form fields
  final TextEditingController _englishController = TextEditingController();
  final TextEditingController _vietnameseController = TextEditingController();
  final TextEditingController _exampleSentenceController = TextEditingController();
  final TextEditingController _exampleTranslationController = TextEditingController();
  String _selectedCategory = 'noun';
  String _selectedDifficulty = 'beginner';

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _loadWords();
  }

  void _initializeTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _loadWords() {
    context.read<WordBloc>().add(LoadAllWords(
      category: _filterCategory == 'all' ? null : _filterCategory,
    ));
  }

  void _speakWord(String text) async {
    await _flutterTts.speak(text);
  }

  void _handleSearch(String query) {
    if (query.isEmpty) {
      _loadWords();
    } else {
      context.read<WordBloc>().add(SearchWords(query));
    }
  }

  void _handleAddWord() {
    if (_englishController.text.isEmpty || _vietnameseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in English and Vietnamese fields')),
      );
      return;
    }

    final newWord = WordModel(
      id: DateTime.now().millisecondsSinceEpoch,
      word: _englishController.text,
      meaning: _vietnameseController.text,
      exampleSentence: _exampleSentenceController.text.isEmpty ? null : _exampleSentenceController.text,
      exampleTranslation: _exampleTranslationController.text.isEmpty ? null : _exampleTranslationController.text,
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
      isFavorite: false,
    );

    context.read<WordBloc>().add(AddWordWithDetails(newWord));
    
    // Clear form
    _englishController.clear();
    _vietnameseController.clear();
    _exampleSentenceController.clear();
    _exampleTranslationController.clear();
    setState(() {
      _showAddForm = false;
    });
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'noun':
        return const Color(0xFFFFE500);
      case 'verb':
        return const Color(0xFFFF006E);
      case 'adjective':
        return const Color(0xFF00F5FF);
      case 'adverb':
        return const Color(0xFF39FF14);
      case 'phrase':
        return const Color(0xFFFF006E);
      case 'idiom':
        return const Color(0xFF00F5FF);
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _englishController.dispose();
    _vietnameseController.dispose();
    _exampleSentenceController.dispose();
    _exampleTranslationController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<WordBloc, WordState>(
          builder: (context, state) {
            final words = state is WordLoaded ? state.words : <WordModel>[];
            final isLoading = state is WordLoading;
            
            // Filter words by search term
            final filteredWords = _searchController.text.isEmpty
                ? words
                : words.where((word) =>
                    word.word.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                    word.meaning.toLowerCase().contains(_searchController.text.toLowerCase())).toList();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Online Status Banner
                    _buildStatusBanner(),
                    const SizedBox(height: 16),
                    
                    // Hero Section
                    _buildHeroSection(words.length),
                    const SizedBox(height: 24),
                    
                    // Search and Filter Bar
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    
                    // Add Word Form
                    if (_showAddForm) ...[
                      _buildAddWordForm(),
                      const SizedBox(height: 24),
                    ],
                    
                    // Words List
                    if (isLoading)
                      _buildLoadingState()
                    else if (filteredWords.isEmpty)
                      _buildEmptyState()
                    else
                      _buildWordsList(filteredWords),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isOnline ? const Color(0xFF39FF14) : const Color(0xFFFF006E),
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _isOnline ? Icons.wifi : Icons.wifi_off,
            size: 24,
            color: Colors.black,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isOnline ? 'ONLINE - Dictionary synced' : 'OFFLINE MODE - Using cached data',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(int wordCount) {
    return Transform.rotate(
      angle: -0.02,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFF006E),
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
          children: [
            const Text(
              'DICTIONARY',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'English ⟷ Vietnamese Translation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$wordCount words available offline',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        // Highly Prominent Search Bar
        Container(
          height: 64,
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
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _handleSearch,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'SEARCH DICTIONARY...',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black38,
                      fontSize: 18,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 32,
                      color: Colors.black,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 28, color: Colors.black),
                  onPressed: () {
                    _searchController.clear();
                    _handleSearch('');
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Action Buttons Row
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: 'ADD WORD',
                icon: Icons.add_circle,
                color: const Color(0xFF39FF14),
                onPressed: () {
                  setState(() {
                    _showAddForm = !_showAddForm;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                label: 'FAVORITES',
                icon: Icons.star,
                color: const Color(0xFFFFE500),
                onPressed: () {
                  // Filter favorites
                  context.read<WordBloc>().add(const LoadAllWords(isFavorite: true));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCategoryFilter(),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['all', 'noun', 'verb', 'adjective', 'adverb', 'phrase', 'idiom'];
    
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _filterCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildNeoBrutalButton(
              onPressed: () {
                setState(() {
                  _filterCategory = category;
                });
                _loadWords();
              },
              color: isSelected ? const Color(0xFFFFE500) : Colors.white,
              child: Text(
                category.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddWordForm() {
    return Transform.rotate(
      angle: 0.02,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE500),
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
              'ADD NEW WORD',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField('ENGLISH', _englishController),
            const SizedBox(height: 12),
            _buildTextField('VIETNAMESE', _vietnameseController),
            const SizedBox(height: 12),
            _buildTextField('EXAMPLE SENTENCE', _exampleSentenceController, maxLines: 2),
            const SizedBox(height: 12),
            _buildTextField('EXAMPLE TRANSLATION', _exampleTranslationController, maxLines: 2),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'CATEGORY',
                    _selectedCategory,
                    ['noun', 'verb', 'adjective', 'adverb', 'phrase', 'idiom'],
                    (value) => setState(() => _selectedCategory = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    'DIFFICULTY',
                    _selectedDifficulty,
                    ['beginner', 'intermediate', 'advanced'],
                    (value) => setState(() => _selectedDifficulty = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: _buildNeoBrutalButton(
                onPressed: _handleAddWord,
                color: Colors.black,
                child: const Text(
                  'ADD WORD',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF39FF14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item.toUpperCase()),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildWordsList(List<WordModel> words) {
    return Column(
      children: words.asMap().entries.map((entry) {
        final index = entry.key;
        final word = entry.value;
        final rotation = index % 3 == 0 ? 0.01 : (index % 3 == 1 ? -0.01 : 0.0);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Transform.rotate(
            angle: rotation,
            child: _buildWordCard(word),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWordCard(WordModel word) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Category and Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (word.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(word.category),
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                        child: Text(
                          word.category!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    if (word.difficulty != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                        child: Text(
                          word.difficulty!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildIconButton(
                    icon: Icons.volume_up,
                    color: const Color(0xFF00F5FF),
                    onPressed: () => _speakWord(word.word),
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    icon: word.isFavorite ? Icons.star : Icons.star_border,
                    color: word.isFavorite ? const Color(0xFFFFE500) : Colors.white,
                    onPressed: () {
                      context.read<WordBloc>().add(ToggleFavorite(
                        wordId: word.id,
                        isFavorite: !word.isFavorite,
                      ));
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    icon: Icons.delete,
                    color: const Color(0xFFFF006E),
                    onPressed: () {
                      context.read<WordBloc>().add(DeleteWord(word.id));
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Word with IPA
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    word.word,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // IPA Transcription - Generate based on word
                  Text(
                    _generateIPA(word.word),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Vietnamese meaning
              Text(
                word.meaning,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          // Examples
          if (word.exampleSentence != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EXAMPLE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.black54,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    word.exampleSentence!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 1.4,
                    ),
                  ),
                  if (word.exampleTranslation != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      word.exampleTranslation!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          
          // SAVE TO FLASHCARD Button - Very Prominent
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF39FF14),
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '"${word.word}" SAVED TO FLASHCARD!',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      backgroundColor: const Color(0xFF39FF14),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.black, width: 3),
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.bookmark_add,
                      size: 24,
                      color: Colors.black,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'SAVE TO FLASHCARD',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Generate IPA transcription (simplified - in production use a proper API)
  String _generateIPA(String word) {
    // This is a simplified version. In production, use a proper IPA API
    final ipaMap = {
      'hello': '/həˈloʊ/',
      'world': '/wɜːrld/',
      'dictionary': '/ˈdɪkʃəneri/',
      'learn': '/lɜːrn/',
      'study': '/ˈstʌdi/',
      'practice': '/ˈpræktɪs/',
      'word': '/wɜːrd/',
      'language': '/ˈlæŋɡwɪdʒ/',
    };
    return ipaMap[word.toLowerCase()] ?? '/wɜːrd/';
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: Colors.black),
      ),
    );
  }

  Widget _buildNeoBrutalButton({
    required VoidCallback onPressed,
    required Color color,
    required Widget child,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
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
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 4,
            ),
            SizedBox(height: 16),
            Text(
              'LOADING...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Transform.rotate(
      angle: -0.02,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF00F5FF),
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
            const Text(
              'NO WORDS FOUND',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            if (!_isOnline) ...[
              const SizedBox(height: 8),
              const Text(
                'Connect to internet to sync more words',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
