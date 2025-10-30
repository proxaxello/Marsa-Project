import 'package:flutter/material.dart';

class SearchHistoryItem {
  final String word;
  final String meaning;
  final DateTime searchedAt;

  SearchHistoryItem({
    required this.word,
    required this.meaning,
    required this.searchedAt,
  });
}

class SearchHistoryWidget extends StatelessWidget {
  final List<SearchHistoryItem> historyItems;
  final Function(SearchHistoryItem) onItemTap;
  final VoidCallback? onClearHistory;

  const SearchHistoryWidget({
    super.key,
    required this.historyItems,
    required this.onItemTap,
    this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Lịch sử",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (onClearHistory != null && historyItems.isNotEmpty)
                TextButton(
                  onPressed: onClearHistory,
                  child: Text(
                    "Xóa tất cả",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (historyItems.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text("Chưa có lịch sử tìm kiếm"),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: historyItems.length,
            itemBuilder: (context, index) {
              final item = historyItems[index];
              return ListTile(
                title: Text(
                  item.word,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  item.meaning,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  _formatDate(item.searchedAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                onTap: () => onItemTap(item),
              );
            },
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hôm nay';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
