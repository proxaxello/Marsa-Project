import 'dart:math';
import 'package:flutter/material.dart';
import 'package:marsa_app/data/models/word_model.dart';

class FlashcardsScreen extends StatefulWidget {
  final List<WordModel> words;

  const FlashcardsScreen({
    super.key,
    required this.words,
  });

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  // Controller for the PageView
  late PageController _pageController;
  
  // Current page index
  int _currentIndex = 0;
  
  // Track whether cards are showing the front (word) or back (meaning)
  List<bool> _isShowingWord = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Initialize all cards to show the word (front side)
    _isShowingWord = List.generate(widget.words.length, (_) => true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Toggle between showing word and meaning
  void _flipCard() {
    setState(() {
      _isShowingWord[_currentIndex] = !_isShowingWord[_currentIndex];
    });
  }

  // Navigate to the previous card
  void _previousCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Navigate to the next card
  void _nextCard() {
    if (_currentIndex < widget.words.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Card ${_currentIndex + 1} of ${widget.words.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          
          // Linear progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LinearProgressIndicator(
              value: widget.words.isEmpty 
                  ? 0 
                  : (_currentIndex + 1) / widget.words.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Flashcards
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.words.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final word = widget.words[index];
                return _buildFlashcard(word, index);
              },
            ),
          ),
          
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentIndex > 0 ? _previousCard : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _currentIndex < widget.words.length - 1 
                      ? _nextCard 
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Instructions
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Tap the card to flip it',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcard(WordModel word, int index) {
    final isShowingWord = _isShowingWord[index];
    
    return GestureDetector(
      onTap: _flipCard,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: TweenAnimationBuilder(
            tween: Tween<double>(
              begin: 0,
              end: isShowingWord ? 0 : 180,
            ),
            duration: const Duration(milliseconds: 300),
            builder: (context, double value, child) {
              // Calculate the visibility based on the rotation angle
              // Hide the front when it's rotated more than 90 degrees
              final frontOpacity = value <= 90 ? 1.0 : 0.0;
              // Show the back only when it's rotated more than 90 degrees
              final backOpacity = value > 90 ? 1.0 : 0.0;
              
              return Stack(
                children: [
                  // Front of the card (word)
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspective
                      ..rotateY(value * pi / 180),
                    child: Opacity(
                      opacity: frontOpacity,
                      child: _buildCardSide(
                        word.word,
                        Theme.of(context).colorScheme.primary,
                        Colors.white,
                        28.0,
                      ),
                    ),
                  ),
                  
                  // Back of the card (meaning)
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspective
                      ..rotateY((value + 180) * pi / 180),
                    child: Opacity(
                      opacity: backOpacity,
                      child: _buildCardSide(
                        word.meaning,
                        Theme.of(context).colorScheme.secondary,
                        Colors.white,
                        22.0,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCardSide(
    String content,
    Color backgroundColor,
    Color textColor,
    double fontSize,
  ) {
    return Card(
      elevation: 8,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            content,
            style: TextStyle(
              fontSize: fontSize,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
