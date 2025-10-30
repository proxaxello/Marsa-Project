class PhraseModel {
  final int id;
  final String text;

  const PhraseModel({
    required this.id,
    required this.text,
  });

  // Create a copy with updated properties
  PhraseModel copyWith({
    int? id,
    String? text,
  }) {
    return PhraseModel(
      id: id ?? this.id,
      text: text ?? this.text,
    );
  }

  // Convert model to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
    };
  }

  // Create model from a map
  factory PhraseModel.fromMap(Map<String, dynamic> map) {
    return PhraseModel(
      id: map['id'] as int,
      text: map['text'] as String,
    );
  }

  @override
  String toString() {
    return 'PhraseModel(id: $id, text: $text)';
  }
}
