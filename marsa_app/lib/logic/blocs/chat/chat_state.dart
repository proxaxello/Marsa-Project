import 'package:equatable/equatable.dart';
import 'package:marsa_app/data/models/chat_message_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  
  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoaded extends ChatState {
  final List<ChatMessageModel> messages;
  
  const ChatLoaded(this.messages);
  
  @override
  List<Object> get props => [messages];
}

class ChatLoading extends ChatState {
  final List<ChatMessageModel> messages;
  
  const ChatLoading(this.messages);
  
  @override
  List<Object> get props => [messages];
}

class ChatError extends ChatState {
  final List<ChatMessageModel> messages;
  final String errorMessage;
  
  const ChatError({
    required this.messages,
    required this.errorMessage,
  });
  
  @override
  List<Object> get props => [messages, errorMessage];
}
