class LessonModel {
  final int id;
  final String title;
  final String description;
  final String difficulty;
  final double progress;
  final List<String> phrases;

  const LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.progress,
    required this.phrases,
  });

  // Create a copy with updated properties
  LessonModel copyWith({
    int? id,
    String? title,
    String? description,
    String? difficulty,
    double? progress,
    List<String>? phrases,
  }) {
    return LessonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      progress: progress ?? this.progress,
      phrases: phrases ?? this.phrases,
    );
  }

  // Convert model to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'progress': progress,
      'phrases': phrases,
    };
  }

  // Create model from a map
  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      difficulty: map['difficulty'] as String,
      progress: map['progress'] as double,
      phrases: List<String>.from(map['phrases'] as List),
    );
  }

  @override
  String toString() {
    return 'LessonModel(id: $id, title: $title, description: $description, difficulty: $difficulty, progress: $progress, phrases: ${phrases.length} items)';
  }
}
