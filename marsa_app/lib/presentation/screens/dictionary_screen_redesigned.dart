import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:marsa_app/data/services/dictionary_service.dart';
import 'package:marsa_app/data/repositories/search_history_repository.dart';
import 'package:marsa_app/data/models/dictionary_entry_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:marsa_app/config/theme_colors.dart';
import 'package:translator/translator.dart';
import 'package:marsa_app/data/services/speech_service.dart';
import 'package:marsa_app/presentation/screens/search_history_screen.dart';

/// Redesigned Dictionary Screen with Glassmorphism, Recent Searches, and Enhanced Search
class DictionaryScreenRedesigned extends StatefulWidget {
  const DictionaryScreenRedesigned({super.key});

  @override
  State<DictionaryScreenRedesigned> createState() =>
      _DictionaryScreenRedesignedState();
}

class _DictionaryScreenRedesignedState
    extends State<DictionaryScreenRedesigned> {
  final TextEditingController _sourceController = TextEditingController();
  final SearchHistoryRepository _historyRepo = SearchHistoryRepository();
  final FocusNode _sourceFocus = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  final GoogleTranslator _translator = GoogleTranslator();
  final SpeechService _speechService = SpeechService();

  bool _isLoading = false;
  bool _showRecentSearches = false;
  DictionaryEntry? _currentEntry;
  String? _error;
  List<String> _recentSearches = [];
  String _translatedText = '';
  Timer? _debounceTimer;
  bool _isListening = false;

  // Language selection
  String _sourceLanguage = 'vi';
  String _targetLanguage = 'en';
  final Map<String, String> _languageNames = {
    'vi': 'Việt',
    'en': 'Anh',
    'zh': 'Trung (Giản thể)',
    'ja': 'Nhật',
    'ko': 'Hàn',
    'fr': 'Pháp',
    'de': 'Đức',
    'es': 'Tây Ban Nha',
  };

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    DictionaryService.initDatabase();

    // Listen to search focus
    _sourceFocus.addListener(() {
      if (_sourceFocus.hasFocus && _recentSearches.isNotEmpty) {
        setState(() {
          _showRecentSearches = true;
        });
      }
    });

    // Listen to text changes for real-time translation
    _sourceController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_sourceController.text.trim().isNotEmpty) {
        _translateText(_sourceController.text);
      } else {
        setState(() {
          _translatedText = '';
          _currentEntry = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _sourceFocus.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  String _detectLanguage(String text) {
    // Simple language detection based on character patterns
    final vietnamesePattern = RegExp(
      r'[àáảãạăắằẳẵặâấầẩẫậèéẻẽẹêếềểễệìíỉĩịòóỏõọôốồổỗộơớờởỡợùúủũụưứừửữựỳýỷỹỵđ]',
    );

    if (vietnamesePattern.hasMatch(text.toLowerCase())) {
      return 'vi';
    }
    return 'en';
  }

  Future<void> _translateText(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Auto-detect source language
      final detectedLang = _detectLanguage(text);

      // Auto-adjust languages if needed
      if (detectedLang != _sourceLanguage) {
        setState(() {
          _sourceLanguage = detectedLang;
          _targetLanguage = detectedLang == 'vi' ? 'en' : 'vi';
        });
      }

      print(
        '[TRANSLATE] Translating "$text" from $_sourceLanguage to $_targetLanguage',
      );

      // Translate using Google Translator package
      final translation = await _translator.translate(
        text,
        from: _sourceLanguage,
        to: _targetLanguage,
      );

      if (mounted) {
        setState(() {
          _translatedText = translation.text;
          _isLoading = false;
        });
      }

      print('[TRANSLATE] Result: "${translation.text}"');

      // If translated text is a single word, search in dictionary
      final words = translation.text.trim().split(' ');
      if (words.length == 1 && _targetLanguage == 'en') {
        // Save current translation before dictionary search
        final currentTranslation = _translatedText;
        await _searchWord(translation.text);
        // Restore translation if dictionary search failed
        if (_currentEntry == null && _translatedText.isEmpty) {
          setState(() {
            _translatedText = currentTranslation;
            _error = null; // Clear any dictionary errors
          });
        }
      }
    } catch (e) {
      print('[TRANSLATE_ERROR] $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Không thể dịch. Vui lòng kiểm tra kết nối mạng.';
        });
      }
    }
  }

  Future<void> _loadRecentSearches() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final searches = await _historyRepo.getUniqueRecentSearches(
      user.id,
      limit: 10,
    );
    setState(() {
      _recentSearches = searches;
    });
  }

  Future<void> _searchWord(String word) async {
    if (word.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _currentEntry = null;
      _showRecentSearches = false;
      _translatedText = '';
    });

    // Search in database
    final entry = await DictionaryService.searchWord(word);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (entry != null) {
          _currentEntry = entry;
          _sourceController.text = entry.word;

          // Save to history
          final user = Supabase.instance.client.auth.currentUser;
          if (user != null) {
            _historyRepo.saveSearchHistory(entry.word, user.id);
            _loadRecentSearches(); // Refresh recent searches
          }
        } else {
          _error = 'Word not found in dictionary';
        }
      });
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;

      // Swap text content and re-translate
      if (_translatedText.isNotEmpty) {
        _sourceController.text = _translatedText;
        _translatedText = '';

        // Trigger re-translation with swapped languages
        _translateText(_sourceController.text);
      }
    });
  }

  Future<void> _captureImageAndExtractText() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Initialize text recognizer
      final inputImage = InputImage.fromFile(File(image.path));
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );

      // Extract text from image
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      final String extractedText = recognizedText.text;

      print('[OCR] Extracted text: "$extractedText"');

      if (extractedText.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = 'Không tìm thấy văn bản trong ảnh';
        });
        textRecognizer.close();
        return;
      }

      // Set extracted text to source field
      _sourceController.text = extractedText;

      // Translate the text
      await _translateText(extractedText);

      textRecognizer.close();
    } catch (e) {
      print('[OCR_ERROR] $e');
      setState(() {
        _isLoading = false;
        _error = 'Không thể trích xuất văn bản từ ảnh: $e';
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Initialize text recognizer
      final inputImage = InputImage.fromFile(File(image.path));
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );

      // Extract text from image
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      final String extractedText = recognizedText.text;

      print('[GALLERY_OCR] Extracted text: "$extractedText"');

      if (extractedText.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = 'Không tìm thấy văn bản trong ảnh';
        });
        textRecognizer.close();
        return;
      }

      // Inject into input field
      _sourceController.text = extractedText;

      // Auto-translate
      await _translateText(extractedText);

      textRecognizer.close();
    } catch (e) {
      print('[GALLERY_OCR_ERROR] $e');
      setState(() {
        _isLoading = false;
        _error = 'Không thể trích xuất văn bản từ ảnh: $e';
      });
    }
  }

  void _onRecentSearchTap(String word) {
    _sourceController.text = word;
    _searchWord(word);
  }

  Future<void> _handleVoiceInput() async {
    if (_isListening) {
      _speechService.stop();
      setState(() {
        _isListening = false;
      });
      return;
    }

    setState(() {
      _isListening = true;
    });

    final recognizedText = await _speechService.listen();

    setState(() {
      _isListening = false;
    });

    if (recognizedText != null && recognizedText.isNotEmpty) {
      _sourceController.text = recognizedText;
      await _translateText(recognizedText);
    }
  }

  void _clearRecentSearches() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await _historyRepo.clearHistory(user.id);
      setState(() {
        _recentSearches = [];
        _showRecentSearches = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Dịch văn bản',
                            style: TextStyle(
                              color: theme.colorScheme.onBackground,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final selectedWord = await Navigator.push<String>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SearchHistoryScreen(),
                                ),
                              );

                              if (selectedWord != null) {
                                _sourceController.text = selectedWord;
                                await _translateText(selectedWord);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.history,
                                color: theme.colorScheme.onBackground,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Plain Text Input (No Frame)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  color: isDark
                      ? const Color(0xFF1a1e3a)
                      : const Color(0xFFF5F5F5),
                  child: TextField(
                    controller: _sourceController,
                    focusNode: _sourceFocus,
                    maxLines: null,
                    minLines: 4,
                    style: TextStyle(
                      color: theme.colorScheme.onBackground,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Nhập văn bản cần dịch',
                      hintStyle: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ),

                // Divider
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.shade300,
                ),

                // Results Area with bottom padding for control bar
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 160),
                    child: _buildResultsArea(),
                  ),
                ),
              ],
            ),

            // Bottom Control Bar (Fixed Position)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomControlBar(),
            ),

            // Recent Searches Overlay
            if (_showRecentSearches && _recentSearches.isNotEmpty)
              _buildRecentSearchesOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControlBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Language selector row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _languageNames[_sourceLanguage] ?? _sourceLanguage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF12100E),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Swap button
                    GestureDetector(
                      onTap: _swapLanguages,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.swap_horiz,
                          color: Color(0xFF12100E),
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _languageNames[_targetLanguage] ?? _targetLanguage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF12100E),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Action buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Microphone button
                    _buildActionButton(
                      icon: _isListening ? Icons.mic : Icons.mic_none,
                      onTap: _handleVoiceInput,
                    ),
                    // Camera button (large, white background)
                    _buildActionButton(
                      icon: Icons.camera_alt,
                      onTap: _captureImageAndExtractText,
                      isLarge: true,
                    ),
                    // Gallery/Image button
                    _buildActionButton(
                      icon: Icons.image,
                      onTap: _pickImageFromGallery,
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

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isLarge ? 64 : 56,
        height: isLarge ? 64 : 56,
        decoration: BoxDecoration(
          color: isLarge ? Colors.white : Colors.white.withOpacity(0.5),
          shape: BoxShape.circle,
          boxShadow: isLarge
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isLarge ? const Color(0xFFB85C7A) : const Color(0xFF12100E),
          size: isLarge ? 32 : 24,
        ),
      ),
    );
  }

  Widget _buildResultsArea() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.secondary),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.textTheme.bodyMedium?.color,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(
                  color: theme.colorScheme.onBackground,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Show translated text if available
    if (_translatedText.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Translation',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: Text(
                  _translatedText,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
              if (_currentEntry != null) ...[
                const SizedBox(height: 20),
                ..._currentEntry!.meanings
                    .map((meaning) => _buildMeaningCard(meaning))
                    .toList(),
              ],
            ],
          ),
        ),
      );
    }

    if (_currentEntry == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.translate,
                size: 80,
                color: isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Nhập văn bản hoặc chụp ảnh để dịch',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withOpacity(0.4)
                      : const Color(0xFF999999),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Display entry
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word Card
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.19),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Word - League Spartan Bold, Navy/Neon Blue
                    Text(
                      _currentEntry!.word,
                      style: TextStyle(
                        color: ThemeColors.getPrimary(context),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'League Spartan',
                      ),
                    ),
                    if (_currentEntry!.phonetic.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      // Phonetic - Italic, Grey
                      Text(
                        _currentEntry!.phonetic,
                        style: TextStyle(
                          color: const Color(0xFF999999),
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Meanings
          ..._currentEntry!.meanings
              .map((meaning) => _buildMeaningCard(meaning))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildMeaningCard(PartOfSpeech meaning) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.19),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Part of Speech Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeColors.getAccent(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    meaning.type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Definitions
                ...meaning.definitions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final def = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ',
                              style: TextStyle(
                                color: ThemeColors.getAccent(context),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                def.text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (def.example != null && def.example!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              '"${def.example}"',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearchesOverlay() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showRecentSearches = false;
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping content
            child: Container(
              margin: const EdgeInsets.all(40),
              constraints: const BoxConstraints(maxWidth: 400),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.19),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Searches',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: _clearRecentSearches,
                                child: Text(
                                  'Clear All',
                                  style: TextStyle(
                                    color: ThemeColors.getAccent(context),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Recent items
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: _recentSearches.length,
                          itemBuilder: (context, index) {
                            final word = _recentSearches[index];
                            return ListTile(
                              leading: Icon(
                                Icons.history,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              title: Text(
                                word,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white.withOpacity(0.5),
                                size: 16,
                              ),
                              onTap: () => _onRecentSearchTap(word),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
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
