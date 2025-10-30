import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/data/models/chat_message_model.dart';
import 'package:marsa_app/data/repositories/ai_tutor_repository.dart';
import 'package:marsa_app/logic/blocs/chat/chat_event.dart';
import 'package:marsa_app/logic/blocs/chat/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final AiTutorRepository _aiTutorRepository;
  
  ChatBloc({
    required AiTutorRepository aiTutorRepository,
  }) : _aiTutorRepository = aiTutorRepository,
       super(const ChatInitial()) {
    on<InitializeChat>(_onInitializeChat);
    on<SendMessage>(_onSendMessage);
  }

  void _onInitializeChat(InitializeChat event, Emitter<ChatState> emit) {
    // Initialize with a welcome message from AI
    final initialMessages = [
      const ChatMessageModel(
        text: "Hello! I'm your AI language tutor. How can I help you today?",
        isUserMessage: false,
      ),
    ];
    
    emit(ChatLoaded(initialMessages));
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    // Get current messages
    List<ChatMessageModel> currentMessages = [];
    
    if (state is ChatLoaded) {
      currentMessages = List.from((state as ChatLoaded).messages);
    } else if (state is ChatLoading) {
      currentMessages = List.from((state as ChatLoading).messages);
    } else if (state is ChatError) {
      currentMessages = List.from((state as ChatError).messages);
    } else {
      // If we're in initial state, initialize with empty list
      currentMessages = [];
    }
    
    // Add user message
    final userMessage = ChatMessageModel(
      text: event.message,
      isUserMessage: true,
    );
    
    final updatedMessages = List<ChatMessageModel>.from(currentMessages)..add(userMessage);
    
    // Emit loaded state with user message
    emit(ChatLoaded(updatedMessages));
    
    // Then emit loading state to show "AI is typing..."
    emit(ChatLoading(updatedMessages));
    
    try {
      // Get response from AI Tutor Repository
      final aiResponseText = await _aiTutorRepository.getChatResponse(event.message);
      
      // Add AI response
      final aiMessage = ChatMessageModel(
        text: aiResponseText,
        isUserMessage: false,
      );
      
      final finalMessages = List<ChatMessageModel>.from(updatedMessages)..add(aiMessage);
      
      // Emit final loaded state with AI response
      emit(ChatLoaded(finalMessages));
    } catch (e) {
      // Handle error
      emit(ChatError(
        messages: updatedMessages,
        errorMessage: 'Failed to get AI response: ${e.toString()}',
      ));
    }
  }
  
  // No longer need the mock response generator as we're using the repository
}
