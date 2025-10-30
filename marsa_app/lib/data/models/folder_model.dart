class FolderModel {
  final int id;
  final String name;
  final int wordCount;

  FolderModel({
    required this.id,
    required this.name,
    required this.wordCount,
  });

  // Create a FolderModel from a map (useful for database operations)
  factory FolderModel.fromMap(Map<String, dynamic> map) {
    return FolderModel(
      id: map['id'],
      name: map['name'],
      wordCount: map['wordCount'],
    );
  }

  // Convert a FolderModel to a map (useful for database operations)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'wordCount': wordCount,
    };
  }

  // Create a copy of this FolderModel with modified fields
  FolderModel copyWith({
    int? id,
    String? name,
    int? wordCount,
  }) {
    return FolderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      wordCount: wordCount ?? this.wordCount,
    );
  }

  @override
  String toString() {
    return 'FolderModel(id: $id, name: $name, wordCount: $wordCount)';
  }
}
