import 'dart:math';
import 'package:flutter/material.dart';
import 'package:marsa_app/data/models/word_model.dart';
import 'package:marsa_app/presentation/screens/practice_modes/test_results_screen.dart';

class TestScreen extends StatefulWidget {
  final List<WordModel> words;

  const TestScreen({
    super.key,
    required this.words,
  });

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  // Controller for the PageView
  late PageController _pageController;
  
  // Current page index
  int _currentIndex = 0;
  
  // Random number generator
  final Random _random = Random();
  
  // List of questions with their options and user answers
  late List<TestQuestion> _questions;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _prepareQuestions();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  // Prepare all questions for the test
  void _prepareQuestions() {
    // Create a copy of the words list to shuffle
    final List<WordModel> shuffledWords = List.from(widget.words);
    shuffledWords.shuffle(_random);
    
    // Create questions from the words
    _questions = [];
    
    // Use all available words for the test
    for (int i = 0; i < shuffledWords.length; i++) {
      final correctWord = shuffledWords[i];
      
      // Create a list of potential wrong answers (excluding the current word)
      final potentialWrongAnswers = List<WordModel>.from(widget.words)
        ..removeWhere((word) => word.id == correctWord.id);
      
      // Shuffle the list to get random words
      potentialWrongAnswers.shuffle(_random);
      
      // Take the first 3 words as wrong answers
      final wrongAnswers = potentialWrongAnswers.take(3).toList();
      
      // Create the options list with the correct answer and wrong answers
      final options = [...wrongAnswers, correctWord];
      
      // Shuffle the options to randomize the position of the correct answer
      options.shuffle(_random);
      
      // Find the index of the correct answer in the shuffled options
      final correctOptionIndex = options.indexWhere((word) => word.id == correctWord.id);
      
      // Create the question
      _questions.add(
        TestQuestion(
          word: correctWord,
          options: options,
          correctOptionIndex: correctOptionIndex,
          userSelectedOptionIndex: -1, // -1 means not answered yet
        ),
      );
    }
  }
  
  // Handle when an option is selected
  void _selectOption(int optionIndex) {
    setState(() {
      // Save the user's answer
      _questions[_currentIndex].userSelectedOptionIndex = optionIndex;
      
      // Wait a moment before moving to the next question
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_currentIndex < _questions.length - 1) {
          // Move to the next question
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          // This was the last question, show results
          _showResults();
        }
      });
    });
  }
  
  // Navigate to the results screen
  void _showResults() {
    // Calculate score
    int correctAnswers = 0;
    for (final question in _questions) {
      if (question.userSelectedOptionIndex == question.correctOptionIndex) {
        correctAnswers++;
      }
    }
    
    // Navigate to results screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TestResultsScreen(
          score: correctAnswers,
          totalQuestions: _questions.length,
          questions: _questions,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Mode'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: _questions.isEmpty 
                ? 0 
                : (_currentIndex + 1) / _questions.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          
          // Progress text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Question ${_currentIndex + 1} of ${_questions.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          
          // Questions PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swiping
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionPage(_questions[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuestionPage(TestQuestion question) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question card showing the meaning
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
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
                    question.word.meaning,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Options
          Text(
            'Choose the correct word:',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Option buttons
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final option = question.options[index];
                
                // Check if this option has already been selected
                final bool isSelected = question.userSelectedOptionIndex == index;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: question.userSelectedOptionIndex >= 0
                        ? null // Disable all buttons if already answered
                        : () => _selectOption(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : null,
                      foregroundColor: isSelected ? Colors.white : null,
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Class to represent a test question
class TestQuestion {
  final WordModel word;
  final List<WordModel> options;
  final int correctOptionIndex;
  int userSelectedOptionIndex;
  
  TestQuestion({
    required this.word,
    required this.options,
    required this.correctOptionIndex,
    this.userSelectedOptionIndex = -1,
  });
  
  bool get isCorrect => userSelectedOptionIndex == correctOptionIndex;
  
  WordModel get selectedOption => 
      userSelectedOptionIndex >= 0 && userSelectedOptionIndex < options.length
          ? options[userSelectedOptionIndex]
          : WordModel(id: -1, word: "", meaning: "");
          
  WordModel get correctOption => options[correctOptionIndex];
}
