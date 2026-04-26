/// Dictionary Entry Model - Represents a parsed dictionary entry
class DictionaryEntry {
  final String word;
  final String phonetic;
  final List<PartOfSpeech> meanings;
  final String? rawHtml; // Keep original HTML for reference

  DictionaryEntry({
    required this.word,
    required this.phonetic,
    required this.meanings,
    this.rawHtml,
  });

  factory DictionaryEntry.fromMap(Map<String, dynamic> map) {
    return DictionaryEntry(
      word: map['word'] ?? '',
      phonetic: map['phonetic'] ?? '',
      meanings: (map['meanings'] as List<dynamic>?)
              ?.map((m) => PartOfSpeech.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      rawHtml: map['rawHtml'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'phonetic': phonetic,
      'meanings': meanings.map((m) => m.toMap()).toList(),
      'rawHtml': rawHtml,
    };
  }

  @override
  String toString() {
    return 'DictionaryEntry(word: $word, phonetic: $phonetic, meanings: ${meanings.length})';
  }
}

/// Part of Speech - Represents a grammatical category (noun, verb, etc.)
class PartOfSpeech {
  final String type; // noun, verb, adjective, etc.
  final List<Definition> definitions;

  PartOfSpeech({
    required this.type,
    required this.definitions,
  });

  factory PartOfSpeech.fromMap(Map<String, dynamic> map) {
    return PartOfSpeech(
      type: map['type'] ?? '',
      definitions: (map['definitions'] as List<dynamic>?)
              ?.map((d) => Definition.fromMap(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'definitions': definitions.map((d) => d.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'PartOfSpeech(type: $type, definitions: ${definitions.length})';
  }
}

/// Definition - Represents a single definition with optional example
class Definition {
  final String text;
  final String? example;

  Definition({
    required this.text,
    this.example,
  });

  factory Definition.fromMap(Map<String, dynamic> map) {
    return Definition(
      text: map['text'] ?? '',
      example: map['example'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'example': example,
    };
  }

  @override
  String toString() {
    return 'Definition(text: $text, example: $example)';
  }
}
