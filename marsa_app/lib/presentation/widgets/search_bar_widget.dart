import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/logic/blocs/search/search_bloc.dart';
import 'package:marsa_app/logic/blocs/search/search_event.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearchPressed;
  final VoidCallback? onMicPressed;
  final VoidCallback? onHandwritingPressed;
  final VoidCallback? onCameraPressed;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSearchPressed,
    this.onMicPressed,
    this.onHandwritingPressed,
    this.onCameraPressed,
    this.hintText = "Nhập từ, cụm từ, hoặc câu...",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) {
                // When user presses enter/search on keyboard
                context.read<SearchBloc>().add(SearchSubmitted(controller.text));
                onSearchPressed();
              },
              onChanged: (value) {
                // Send event to BLoC when text changes
                context.read<SearchBloc>().add(SearchTermChanged(value));
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // When search icon is pressed
              context.read<SearchBloc>().add(SearchSubmitted(controller.text));
              onSearchPressed();
            },
            color: Theme.of(context).primaryColor,
          ),
          if (onMicPressed != null)
            IconButton(
              icon: const Icon(Icons.mic),
              onPressed: onMicPressed,
              color: Theme.of(context).primaryColor,
            ),
          if (onHandwritingPressed != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onHandwritingPressed,
              color: Theme.of(context).primaryColor,
            ),
          if (onCameraPressed != null)
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: onCameraPressed,
              color: Theme.of(context).primaryColor,
            ),
        ],
      ),
    );
  }
}
