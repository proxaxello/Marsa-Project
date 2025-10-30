import 'package:flutter/material.dart';
import 'package:marsa_app/data/models/word_model.dart';

class SearchResultsWidget extends StatelessWidget {
  final List<WordModel> results;
  final Function(WordModel) onResultTap;

  const SearchResultsWidget({
    super.key,
    required this.results,
    required this.onResultTap,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No results found.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final wordModel = results[index];
        return ListTile(
          title: Text(
            wordModel.word,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(wordModel.meaning),
          trailing: IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: () {
              // This would be implemented with actual save logic in the future
            },
            tooltip: 'Save to vocabulary',
          ),
          onTap: () => onResultTap(wordModel),
        );
      },
    );
  }
}
