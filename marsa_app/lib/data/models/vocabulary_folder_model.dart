/// Vocabulary Folder Model - Represents a user's custom vocabulary folder
class VocabularyFolder {
  final String id;
  final String name;
  final String userId;
  final List<String> wordIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  VocabularyFolder({
    required this.id,
    required this.name,
    required this.userId,
    required this.wordIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VocabularyFolder.fromMap(Map<String, dynamic> map) {
    return VocabularyFolder(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      userId: map['user_id'] ?? '',
      wordIds: (map['word_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: map['created_at'] is String
          ? DateTime.parse(map['created_at'])
          : map['created_at'] as DateTime,
      updatedAt: map['updated_at'] is String
          ? DateTime.parse(map['updated_at'])
          : map['updated_at'] as DateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
      'word_ids': wordIds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  VocabularyFolder copyWith({
    String? id,
    String? name,
    String? userId,
    List<String>? wordIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VocabularyFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      wordIds: wordIds ?? this.wordIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'VocabularyFolder(id: $id, name: $name, userId: $userId, wordCount: ${wordIds.length})';
  }
}
