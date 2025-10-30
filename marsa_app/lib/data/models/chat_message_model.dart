import 'package:equatable/equatable.dart';

class ChatMessageModel extends Equatable {
  final String text;
  final bool isUserMessage;
  
  const ChatMessageModel({
    required this.text,
    required this.isUserMessage,
  });
  
  @override
  List<Object> get props => [text, isUserMessage];
  
  // Create a copy of this ChatMessageModel with the given fields replaced
  ChatMessageModel copyWith({
    String? text,
    bool? isUserMessage,
  }) {
    return ChatMessageModel(
      text: text ?? this.text,
      isUserMessage: isUserMessage ?? this.isUserMessage,
    );
  }
}
