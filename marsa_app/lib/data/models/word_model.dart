class WordModel {
  final int id;
  final String word;
  final String meaning;
  final String? exampleSentence;
  final String? exampleTranslation;
  final String? category; // noun, verb, adjective, adverb, phrase, idiom
  final String? difficulty; // beginner, intermediate, advanced
  final bool isFavorite;
  final int? folderId;

  WordModel({
    required this.id,
    required this.word,
    required this.meaning,
    this.exampleSentence,
    this.exampleTranslation,
    this.category,
    this.difficulty,
    this.isFavorite = false,
    this.folderId,
  });

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'],
      word: map['word'],
      meaning: map['meaning'],
      exampleSentence: map['example_sentence'],
      exampleTranslation: map['example_translation'],
      category: map['category'],
      difficulty: map['difficulty'],
      isFavorite: map['is_favorite'] == 1,
      folderId: map['folder_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'example_sentence': exampleSentence,
      'example_translation': exampleTranslation,
      'category': category,
      'difficulty': difficulty,
      'is_favorite': isFavorite ? 1 : 0,
      'folder_id': folderId,
    };
  }

  WordModel copyWith({
    int? id,
    String? word,
    String? meaning,
    String? exampleSentence,
    String? exampleTranslation,
    String? category,
    String? difficulty,
    bool? isFavorite,
    int? folderId,
  }) {
    return WordModel(
      id: id ?? this.id,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      exampleTranslation: exampleTranslation ?? this.exampleTranslation,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      isFavorite: isFavorite ?? this.isFavorite,
      folderId: folderId ?? this.folderId,
    );
  }

  @override
  String toString() {
    return 'WordModel(id: $id, word: $word, meaning: $meaning, category: $category, difficulty: $difficulty, isFavorite: $isFavorite)';
  }
}
