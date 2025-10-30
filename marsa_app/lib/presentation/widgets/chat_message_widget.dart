import 'package:flutter/material.dart';

class ChatMessageWidget extends StatelessWidget {
  final String text;
  final bool isUserMessage;

  const ChatMessageWidget({
    super.key,
    required this.text,
    required this.isUserMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(12.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUserMessage 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
              : Colors.grey[300],
          // Add different border radius for user and AI messages
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
            bottomLeft: isUserMessage ? const Radius.circular(16.0) : const Radius.circular(4.0),
            bottomRight: isUserMessage ? const Radius.circular(4.0) : const Radius.circular(16.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add sender label
            Text(
              isUserMessage ? 'You' : 'AI Tutor',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isUserMessage 
                    ? Colors.white.withOpacity(0.8)
                    : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            // Message text
            Text(
              text,
              style: TextStyle(
                color: isUserMessage ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
