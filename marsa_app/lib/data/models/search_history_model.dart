/// Search History Model - Represents a user's search history entry
class SearchHistory {
  final String id;
  final String word;
  final String userId;
  final DateTime timestamp;

  SearchHistory({
    required this.id,
    required this.word,
    required this.userId,
    required this.timestamp,
  });

  factory SearchHistory.fromMap(Map<String, dynamic> map) {
    return SearchHistory(
      id: map['id'] ?? '',
      word: map['word'] ?? '',
      userId: map['user_id'] ?? '',
      timestamp: map['timestamp'] is String
          ? DateTime.parse(map['timestamp'])
          : map['timestamp'] as DateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'user_id': userId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'SearchHistory(id: $id, word: $word, userId: $userId, timestamp: $timestamp)';
  }
}
