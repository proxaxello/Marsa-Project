import 'dart:math';
import 'package:flutter/material.dart';
import 'package:marsa_app/data/models/word_model.dart';

class LearnScreen extends StatefulWidget {
  final List<WordModel> words;

  const LearnScreen({
    super.key,
    required this.words,
  });

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  // Current question index
  int _currentIndex = 0;
  
  // Track if the current question has been answered
  bool _isAnswered = false;
  
  // Track which option was selected
  int? _selectedOptionIndex;
  
  // List of options for the current question
  late List<WordModel> _currentOptions;
  
  // Index of the correct answer in the options list
  late int _correctOptionIndex;
  
  // Random number generator
  final Random _random = Random();
  
  @override
  void initState() {
    super.initState();
    // Initialize the first question
    _prepareQuestion();
  }
  
  // Prepare a new question with options
  void _prepareQuestion() {
    // Reset state for the new question
    setState(() {
      _isAnswered = false;
      _selectedOptionIndex = null;
      
      // Get the current word
      final currentWord = widget.words[_currentIndex];
      
      // Create a list of potential wrong answers (excluding the current word)
      final potentialWrongAnswers = List<WordModel>.from(widget.words)
        ..removeWhere((word) => word.id == currentWord.id);
      
      // Shuffle the list to get random words
      potentialWrongAnswers.shuffle(_random);
      
      // Take the first 3 words as wrong answers
      final wrongAnswers = potentialWrongAnswers.take(3).toList();
      
      // Create the options list with the correct answer and wrong answers
      _currentOptions = [...wrongAnswers, currentWord];
      
      // Shuffle the options to randomize the position of the correct answer
      _currentOptions.shuffle(_random);
      
      // Find the index of the correct answer in the shuffled options
      _correctOptionIndex = _currentOptions.indexWhere((word) => word.id == currentWord.id);
    });
  }
  
  // Handle when an option is selected
  void _selectOption(int index) {
    if (_isAnswered) return; // Prevent multiple selections
    
    setState(() {
      _isAnswered = true;
      _selectedOptionIndex = index;
    });
  }
  
  // Move to the next question
  void _nextQuestion() {
    if (_currentIndex < widget.words.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _prepareQuestion();
    } else {
      // Show completion dialog when all words are learned
      _showCompletionDialog();
    }
  }
  
  // Show dialog when all words are learned
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: const Text('You have completed all the words in this learning session.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text('Finish'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Reset the learning session
              setState(() {
                _currentIndex = 0;
              });
              _prepareQuestion();
            },
            child: const Text('Start Over'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the current word being tested
    final currentWord = widget.words[_currentIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Mode'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: widget.words.isEmpty 
                ? 0 
                : (_currentIndex + 1) / widget.words.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          
          // Progress text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Word ${_currentIndex + 1} of ${widget.words.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          
          // Question card showing the meaning
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'What word means:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentWord.meaning,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Answer options
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Choose the correct word:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  // Option buttons
                  Expanded(
                    child: ListView.builder(
                      itemCount: _currentOptions.length,
                      itemBuilder: (context, index) {
                        final option = _currentOptions[index];
                        
                        // Determine button color based on state
                        Color? buttonColor;
                        if (_isAnswered) {
                          if (index == _correctOptionIndex) {
                            // Correct answer is always green when revealed
                            buttonColor = Colors.green;
                          } else if (index == _selectedOptionIndex) {
                            // Selected wrong answer is red
                            buttonColor = Colors.red;
                          }
                        }
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: _isAnswered 
                                ? null // Disable all buttons after answering
                                : () => _selectOption(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              foregroundColor: buttonColor != null ? Colors.white : null,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 16.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              option.word,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Continue button (only shown after answering)
                  if (_isAnswered)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton.icon(
                        onPressed: _nextQuestion,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Continue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 24.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Feedback area (shown after answering)
          if (_isAnswered)
            Container(
              padding: const EdgeInsets.all(16.0),
              color: _selectedOptionIndex == _correctOptionIndex
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    _selectedOptionIndex == _correctOptionIndex
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: _selectedOptionIndex == _correctOptionIndex
                        ? Colors.green
                        : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _selectedOptionIndex == _correctOptionIndex
                          ? 'Correct! Well done!'
                          : 'Incorrect. The correct answer is "${_currentOptions[_correctOptionIndex].word}".',
                      style: TextStyle(
                        color: _selectedOptionIndex == _correctOptionIndex
                            ? Colors.green[800]
                            : Colors.red[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
