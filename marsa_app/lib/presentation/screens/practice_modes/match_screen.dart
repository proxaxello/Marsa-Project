import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:marsa_app/data/models/word_model.dart';

class MatchScreen extends StatefulWidget {
  final List<WordModel> words;

  const MatchScreen({
    super.key,
    required this.words,
  });

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> with TickerProviderStateMixin {
  // List of all cards (both words and meanings)
  late List<MatchCard> _cards;
  
  // Currently selected card index
  int? _selectedCardIndex;
  
  // Timer for the game
  late Timer _timer;
  
  // Time elapsed in seconds
  int _timeElapsed = 0;
  
  // Animation controllers for card flipping and shaking
  late Map<int, AnimationController> _shakeControllers;
  
  // Flag to track if the game is completed
  bool _isGameCompleted = false;
  
  // Random number generator
  final Random _random = Random();
  
  @override
  void initState() {
    super.initState();
    _initializeGame();
  }
  
  @override
  void dispose() {
    // Dispose all animation controllers
    for (final controller in _shakeControllers.values) {
      controller.dispose();
    }
    
    // Cancel the timer
    _timer.cancel();
    
    super.dispose();
  }
  
  // Initialize the game
  void _initializeGame() {
    // Create a list of match cards
    _cards = [];
    _shakeControllers = {};
    
    // Take a subset of words if there are too many
    final gameWords = widget.words.length > 10
        ? _getRandomSubset(widget.words, 10)
        : widget.words;
    
    // Create cards for words and meanings
    for (int i = 0; i < gameWords.length; i++) {
      // Add word card
      _cards.add(
        MatchCard(
          id: i,
          text: gameWords[i].word,
          type: CardType.word,
          matchId: i,
          isMatched: false,
        ),
      );
      
      // Add meaning card
      _cards.add(
        MatchCard(
          id: i + gameWords.length,
          text: gameWords[i].meaning,
          type: CardType.meaning,
          matchId: i,
          isMatched: false,
        ),
      );
      
      // Create shake animation controllers for both cards
      _shakeControllers[i] = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      _shakeControllers[i + gameWords.length] = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
    }
    
    // Shuffle the cards
    _cards.shuffle(_random);
    
    // Start the timer
    _timeElapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isGameCompleted) {
        setState(() {
          _timeElapsed++;
        });
      }
    });
  }
  
  // Get a random subset of words
  List<WordModel> _getRandomSubset(List<WordModel> words, int count) {
    final List<WordModel> wordsCopy = List.from(words);
    wordsCopy.shuffle(_random);
    return wordsCopy.take(count).toList();
  }
  
  // Handle card tap
  void _onCardTap(int index) {
    // Ignore taps if the card is already matched
    if (_cards[index].isMatched) return;
    
    // If no card is selected, select this one
    if (_selectedCardIndex == null) {
      setState(() {
        _selectedCardIndex = index;
      });
      return;
    }
    
    // If the same card is tapped again, deselect it
    if (_selectedCardIndex == index) {
      setState(() {
        _selectedCardIndex = null;
      });
      return;
    }
    
    // Check if the two cards match
    final selectedCard = _cards[_selectedCardIndex!];
    final currentCard = _cards[index];
    
    if (selectedCard.matchId == currentCard.matchId &&
        selectedCard.type != currentCard.type) {
      // Match found
      setState(() {
        _cards[_selectedCardIndex!] = selectedCard.copyWith(isMatched: true);
        _cards[index] = currentCard.copyWith(isMatched: true);
        _selectedCardIndex = null;
      });
      
      // Check if all cards are matched
      if (_cards.every((card) => card.isMatched)) {
        _onGameCompleted();
      }
    } else {
      // No match
      // Start shake animation for both cards
      _shakeControllers[_selectedCardIndex!]!.forward(from: 0).then((_) {
        _shakeControllers[_selectedCardIndex!]!.reset();
      });
      _shakeControllers[index]!.forward(from: 0).then((_) {
        _shakeControllers[index]!.reset();
      });
      
      // Deselect after a short delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _selectedCardIndex = null;
          });
        }
      });
    }
  }
  
  // Handle game completion
  void _onGameCompleted() {
    setState(() {
      _isGameCompleted = true;
    });
    
    // Stop the timer
    _timer.cancel();
    
    // Show completion dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showCompletionDialog();
      }
    });
  }
  
  // Show completion dialog
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You have completed the matching game!'),
            const SizedBox(height: 16),
            Text(
              'Time: ${_formatTime(_timeElapsed)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Reset and restart the game
              setState(() {
                _initializeGame();
              });
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
  
  // Format time as MM:SS
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Game'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Timer display
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer, size: 24),
                const SizedBox(width: 8),
                Text(
                  _formatTime(_timeElapsed),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Game instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Match each word with its meaning',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Game grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  final isSelected = _selectedCardIndex == index;
                  
                  return AnimatedBuilder(
                    animation: _shakeControllers[index]!,
                    builder: (context, child) {
                      // Apply shake animation
                      final offset = sin(_shakeControllers[index]!.value * 10) * 5;
                      
                      return Transform.translate(
                        offset: Offset(offset, 0),
                        child: child,
                      );
                    },
                    child: _buildCard(card, isSelected, index),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCard(MatchCard card, bool isSelected, int index) {
    // Determine card color based on type and state
    Color cardColor;
    Color borderColor;
    Color textColor;
    
    if (card.isMatched) {
      // Matched cards are faded
      cardColor = Colors.grey[300]!;
      borderColor = Colors.grey[400]!;
      textColor = Colors.grey[600]!;
    } else if (isSelected) {
      // Selected card
      cardColor = card.type == CardType.word
          ? Colors.blue[100]!
          : Colors.green[100]!;
      borderColor = card.type == CardType.word
          ? Colors.blue
          : Colors.green;
      textColor = Colors.black;
    } else {
      // Normal card
      cardColor = card.type == CardType.word
          ? Colors.blue[50]!
          : Colors.green[50]!;
      borderColor = Colors.grey[300]!;
      textColor = Colors.black87;
    }
    
    return AnimatedOpacity(
      opacity: card.isMatched ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: card.isMatched ? null : () => _onCardTap(index),
        child: Card(
          elevation: isSelected ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: borderColor,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          color: cardColor,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                card.text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Enum for card types
enum CardType { word, meaning }

// Class to represent a card in the matching game
class MatchCard {
  final int id;
  final String text;
  final CardType type;
  final int matchId;
  final bool isMatched;
  
  const MatchCard({
    required this.id,
    required this.text,
    required this.type,
    required this.matchId,
    required this.isMatched,
  });
  
  // Create a copy with updated properties
  MatchCard copyWith({
    int? id,
    String? text,
    CardType? type,
    int? matchId,
    bool? isMatched,
  }) {
    return MatchCard(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      matchId: matchId ?? this.matchId,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}
