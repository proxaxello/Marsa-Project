import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/data/models/lesson_model.dart';
import 'package:marsa_app/logic/blocs/voice_lab/voice_lab_event.dart';
import 'package:marsa_app/logic/blocs/voice_lab/voice_lab_state.dart';

class VoiceLabBloc extends Bloc<VoiceLabEvent, VoiceLabState> {
  VoiceLabBloc() : super(const VoiceLabInitial()) {
    on<LoadLessons>(_onLoadLessons);
    
    // Automatically load lessons when the bloc is created
    add(const LoadLessons());
  }

  void _onLoadLessons(
    LoadLessons event,
    Emitter<VoiceLabState> emit,
  ) async {
    try {
      emit(const VoiceLabLoading());
      
      // Simulate a network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return the sample lessons
      emit(VoiceLabLoaded(_sampleLessons));
    } catch (e) {
      emit(VoiceLabError(e.toString()));
    }
  }
  
  // Sample lessons data (moved from the UI)
  static final List<LessonModel> _sampleLessons = [
    LessonModel(
      id: 1,
      title: 'Common Greetings',
      description: 'Practice essential phrases for daily conversations',
      difficulty: 'Beginner',
      progress: 0.75,
      phrases: [
        'Hello, how are you?',
        'Nice to meet you.',
        'Good morning!',
        'Have a nice day!',
        'See you later.',
        "How's it going?",
        "What's up?",
      ],
    ),
    LessonModel(
      id: 2,
      title: 'Restaurant Conversations',
      description: 'Learn how to order food and talk with waiters',
      difficulty: 'Intermediate',
      progress: 0.4,
      phrases: [
        "I'd like to make a reservation.",
        'What do you recommend?',
        'Could I see the menu, please?',
        "I'll have the chicken, please.",
        'Can I get the check, please?',
        'Is service included?',
      ],
    ),
    LessonModel(
      id: 3,
      title: 'Business English',
      description: 'Professional vocabulary for meetings and presentations',
      difficulty: 'Advanced',
      progress: 0.1,
      phrases: [
        "Let's discuss the quarterly results.",
        "I'd like to propose a new strategy.",
        'What are your thoughts on this matter?',
        'Could you elaborate on that point?',
        'We should consider all the options.',
        "Let's schedule a follow-up meeting.",
      ],
    ),
    LessonModel(
      id: 4,
      title: 'Travel Phrases',
      description: 'Essential expressions for your next trip abroad',
      difficulty: 'Beginner',
      progress: 0.6,
      phrases: [
        'Excuse me, where is the bathroom?',
        'How much does this cost?',
        'Can you help me, please?',
        "I'm looking for the train station.",
        'Do you speak English?',
        "I'd like to book a room.",
      ],
    ),
    LessonModel(
      id: 5,
      title: 'Job Interview',
      description: 'Prepare for your next job interview in English',
      difficulty: 'Intermediate',
      progress: 0.0,
      phrases: [
        'Tell me about yourself.',
        'What are your strengths and weaknesses?',
        'Why do you want to work for this company?',
        'Where do you see yourself in five years?',
        "Can you describe a challenging situation you've faced?",
        'Do you have any questions for us?',
      ],
    ),
  ];
}
