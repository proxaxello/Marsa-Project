import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/data/models/lesson_model.dart';
import 'package:marsa_app/data/repositories/speech_analysis_repository.dart';
import 'package:marsa_app/logic/blocs/voice_lab/lesson_detail_bloc.dart';
import 'package:marsa_app/logic/blocs/voice_lab/lesson_detail_event.dart';
import 'package:marsa_app/logic/blocs/voice_lab/voice_lab_bloc.dart';
import 'package:marsa_app/logic/blocs/voice_lab/voice_lab_event.dart';
import 'package:marsa_app/logic/blocs/voice_lab/voice_lab_state.dart';
import 'package:marsa_app/presentation/screens/lesson_detail_screen.dart';

class VoiceLabScreen extends StatelessWidget {
  const VoiceLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Lab'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Improve Your Pronunciation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Practice speaking with our interactive lessons',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          
          // Lessons list header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Available Lessons',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Lessons list with BlocBuilder
          Expanded(
            child: BlocBuilder<VoiceLabBloc, VoiceLabState>(
              builder: (context, state) {
                if (state is VoiceLabLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (state is VoiceLabError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.message}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Retry loading lessons
                            context.read<VoiceLabBloc>().add(const LoadLessons());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is VoiceLabLoaded) {
                  final lessons = state.lessons;
                  
                  if (lessons.isEmpty) {
                    return const Center(
                      child: Text(
                        'No lessons available yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: lessons.length,
                    itemBuilder: (context, index) {
                      final lesson = lessons[index];
                      return _buildLessonCard(context, lesson);
                    },
                  );
                }
                
                // Default case (VoiceLabInitial)
                return const Center(
                  child: Text('Loading lessons...'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLessonCard(BuildContext context, LessonModel lesson) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to lesson detail screen with BlocProvider
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => LessonDetailBloc(
                  // Lấy repository đã được cung cấp ở main.dart
                  speechAnalysisRepository: context.read<SpeechAnalysisRepository>(),
                )..add(LoadPhrases(lesson)),
                child: LessonDetailScreen(
                  title: lesson.title,
                ),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lesson difficulty badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(lesson.difficulty),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      lesson.difficulty,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  Text(
                    '${lesson.phrases.length} phrases',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12.0),
              
              // Lesson title
              Text(
                lesson.title,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8.0),
              
              // Lesson description
              Text(
                lesson.description,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[700],
                ),
              ),
              
              const SizedBox(height: 16.0),
              
              // Lesson progress indicator
              Row(
                children: [
                  const Icon(
                    Icons.mic,
                    size: 18.0,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: lesson.progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    '${(lesson.progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
  
}

