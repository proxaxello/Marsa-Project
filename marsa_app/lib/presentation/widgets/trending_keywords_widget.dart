import 'package:flutter/material.dart';

class TrendingKeywordsWidget extends StatelessWidget {
  final List<String> keywords;
  final Function(String) onKeywordTap;

  const TrendingKeywordsWidget({
    super.key,
    required this.keywords,
    required this.onKeywordTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Từ khóa hot",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: keywords.length,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  onTap: () => onKeywordTap(keywords[index]),
                  child: Chip(
                    label: Text(keywords[index]),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
