import 'package:flutter/material.dart';
import 'package:marsa_app/presentation/screens/practice_modes/test_screen.dart';

class TestResultsScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<TestQuestion> questions;

  const TestResultsScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate percentage score
    final percentage = (score / totalQuestions) * 100;
    
    // Determine feedback based on score
    String feedback;
    Color feedbackColor;
    
    if (percentage >= 90) {
      feedback = 'Excellent!';
      feedbackColor = Colors.green;
    } else if (percentage >= 70) {
      feedback = 'Good job!';
      feedbackColor = Colors.green[700]!;
    } else if (percentage >= 50) {
      feedback = 'Keep practicing!';
      feedbackColor = Colors.orange;
    } else {
      feedback = 'Need more practice!';
      feedbackColor = Colors.red;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Column(
        children: [
          // Score summary
          Container(
            padding: const EdgeInsets.all(24.0),
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            child: Column(
              children: [
                Text(
                  '$score/$totalQuestions Correct',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  feedback,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: feedbackColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Question list header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Question Review',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Question list
          Expanded(
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final isCorrect = question.isCorrect;
                
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: isCorrect ? Colors.green : Colors.red,
                      width: 2.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question number and status
                        Row(
                          children: [
                            Text(
                              'Question ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: isCorrect ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                isCorrect ? 'Correct' : 'Incorrect',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Question meaning
                        Text(
                          'What word means:',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          question.word.meaning,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // User's answer
                        Text(
                          'Your answer:',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          question.selectedOption.word,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                        
                        // Show correct answer if wrong
                        if (!isCorrect) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Correct answer:',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            question.correctOption.word,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Done button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Return to folder detail screen
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
