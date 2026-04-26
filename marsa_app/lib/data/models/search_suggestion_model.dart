/// Search Suggestion Model - Represents a word suggestion with phonetic and brief meaning
class SearchSuggestion {
  final String word;
  final String phonetic;
  final String briefMeaning;

  SearchSuggestion({
    required this.word,
    required this.phonetic,
    required this.briefMeaning,
  });

  factory SearchSuggestion.fromMap(Map<String, dynamic> map) {
    return SearchSuggestion(
      word: map['word'] ?? '',
      phonetic: map['phonetic'] ?? '',
      briefMeaning: map['briefMeaning'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'phonetic': phonetic,
      'briefMeaning': briefMeaning,
    };
  }

  @override
  String toString() {
    return 'SearchSuggestion(word: $word, phonetic: $phonetic, briefMeaning: $briefMeaning)';
  }
}
