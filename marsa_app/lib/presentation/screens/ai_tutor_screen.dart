import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/data/models/chat_message_model.dart';
import 'package:marsa_app/logic/blocs/chat/chat_bloc.dart';
import 'package:marsa_app/logic/blocs/chat/chat_event.dart';
import 'package:marsa_app/logic/blocs/chat/chat_state.dart';
import 'package:marsa_app/presentation/widgets/chat_message_widget.dart';

class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

// Loading dots animation for typing indicator
class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        3,
        (index) => AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double offset = (index / 3.0);
            return Opacity(
              opacity: (((_controller.value + offset) % 1.0) < 0.5) ? 1.0 : 0.3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // No longer need mock messages as they will come from the BLoC

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Send message using BLoC
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    // Add SendMessage event to the BLoC
    context.read<ChatBloc>().add(SendMessage(_messageController.text.trim()));
    
    // Clear the input field
    _messageController.clear();
    
    // Scroll to the bottom of the chat
    _scrollToBottom();
  }
  
  // Helper method to scroll to the bottom of the chat
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tutor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Chat messages area with BlocBuilder
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                // Scroll to bottom when state changes
                if (state is ChatLoaded || state is ChatLoading) {
                  _scrollToBottom();
                }
                
                // Show error message if there's an error
                if (state is ChatError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(
                        label: 'Retry',
                        onPressed: () {
                          // Try sending the last message again
                          if (state.messages.isNotEmpty) {
                            final lastUserMessage = state.messages.lastWhere(
                              (msg) => msg.isUserMessage,
                              orElse: () => const ChatMessageModel(text: '', isUserMessage: true),
                            );
                            if (lastUserMessage.text.isNotEmpty) {
                              context.read<ChatBloc>().add(SendMessage(lastUserMessage.text));
                            }
                          }
                        },
                        textColor: Colors.white,
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ChatInitial) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                List<ChatMessageModel> messages = [];
                bool isLoading = false;
                
                if (state is ChatLoaded) {
                  messages = state.messages;
                } else if (state is ChatLoading) {
                  messages = state.messages;
                  isLoading = true;
                } else if (state is ChatError) {
                  messages = state.messages;
                }
                
                return Column(
                  children: [
                    // Messages list
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return ChatMessageWidget(
                            text: message.text,
                            isUserMessage: message.isUserMessage,
                          );
                        },
                      ),
                    ),
                    
                    // AI typing indicator
                    if (isLoading)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            const Text(
                              'AI is typing',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 30,
                              height: 10,
                              child: LoadingDots(),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Text input field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                // Send button
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                    onPressed: _sendMessage,
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
