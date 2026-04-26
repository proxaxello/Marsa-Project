import 'package:marsa_app/data/models/dictionary_entry_model.dart';

/// HTML Parser Utility for Dictionary Database
/// Parses HTML content from marsa_dictionary_v6.db into structured data
class HtmlParserUtil {
  /// Parse dictionary HTML content into DictionaryEntry
  static DictionaryEntry parseHtmlContent(String word, String htmlContent) {
    // Extract phonetic from <h3><i>phonetic</i></h3>
    final phonetic = _extractPhonetic(htmlContent);

    // Extract all parts of speech and their definitions
    final meanings = _extractMeanings(htmlContent);

    return DictionaryEntry(
      word: word,
      phonetic: phonetic,
      meanings: meanings,
      rawHtml: htmlContent,
    );
  }

  /// Extract phonetic pronunciation from HTML
  static String _extractPhonetic(String html) {
    // Pattern: <h3><i>/phonetic/</i></h3>
    final phoneticRegex = RegExp(r'<h3><i>(.*?)</i></h3>');
    final match = phoneticRegex.firstMatch(html);
    if (match != null) {
      return match.group(1)?.trim() ?? '';
    }
    return '';
  }

  /// Extract all parts of speech and definitions
  static List<PartOfSpeech> _extractMeanings(String html) {
    final meanings = <PartOfSpeech>[];

    // Split by <h2> tags to get different parts of speech
    final h2Regex = RegExp(r'<h2>(.*?)</h2>');
    final h2Matches = h2Regex.allMatches(html);

    for (final match in h2Matches) {
      final partOfSpeechText = match.group(1)?.trim() ?? '';
      
      // Clean up part of speech text (remove extra info like "số nhiều")
      final cleanPartOfSpeech = _cleanPartOfSpeech(partOfSpeechText);

      // Find the <ul> block after this <h2>
      final startIndex = match.end;
      final nextH2Match = h2Regex.firstMatch(html.substring(startIndex));
      final endIndex = nextH2Match != null 
          ? startIndex + nextH2Match.start 
          : html.length;

      final sectionHtml = html.substring(startIndex, endIndex);
      
      // Extract definitions from this section
      final definitions = _extractDefinitions(sectionHtml);

      if (definitions.isNotEmpty) {
        meanings.add(PartOfSpeech(
          type: cleanPartOfSpeech,
          definitions: definitions,
        ));
      }
    }

    // If no <h2> tags found, try to extract from general <ul>
    if (meanings.isEmpty) {
      final definitions = _extractDefinitions(html);
      if (definitions.isNotEmpty) {
        meanings.add(PartOfSpeech(
          type: 'general',
          definitions: definitions,
        ));
      }
    }

    return meanings;
  }

  /// Clean part of speech text
  static String _cleanPartOfSpeech(String text) {
    // Remove extra info like "số nhiều as, a's"
    final cleaned = text.split(',')[0].trim();
    
    // Map Vietnamese to English if needed
    final mapping = {
      'danh từ': 'noun',
      'động từ': 'verb',
      'tính từ': 'adjective',
      'trạng từ': 'adverb',
      'giới từ': 'preposition',
      'liên từ': 'conjunction',
      'mạo từ': 'article',
      'đại từ': 'pronoun',
      'thán từ': 'interjection',
    };

    return mapping[cleaned.toLowerCase()] ?? cleaned;
  }

  /// Extract definitions from HTML section
  static List<Definition> _extractDefinitions(String html) {
    final definitions = <Definition>[];

    // Pattern: <li>definition text<ul>...</ul></li>
    final liRegex = RegExp(r'<li>(.*?)</li>', dotAll: true);
    final matches = liRegex.allMatches(html);

    for (final match in matches) {
      final liContent = match.group(1) ?? '';
      
      // Check if this is a top-level definition (not nested)
      if (!_isNestedLi(html, match.start)) {
        final definition = _extractDefinitionText(liContent);
        final example = _extractExample(liContent);

        if (definition.isNotEmpty) {
          definitions.add(Definition(
            text: definition,
            example: example,
          ));
        }
      }
    }

    return definitions;
  }

  /// Check if <li> is nested inside another <li>
  static bool _isNestedLi(String html, int position) {
    // Count opening and closing <li> tags before this position
    final before = html.substring(0, position);
    final openCount = '<li>'.allMatches(before).length;
    final closeCount = '</li>'.allMatches(before).length;
    
    // If more opens than closes, this is nested
    return openCount > closeCount;
  }

  /// Extract definition text (remove nested <ul> and HTML tags)
  static String _extractDefinitionText(String liContent) {
    // Remove nested <ul>...</ul> blocks
    var text = liContent.replaceAll(RegExp(r'<ul.*?</ul>', dotAll: true), '');
    
    // Remove all HTML tags
    text = _stripHtmlTags(text);
    
    // Clean up whitespace
    text = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    
    return text;
  }

  /// Extract example from nested <ul> with style="list-style-type:circle"
  static String? _extractExample(String liContent) {
    // Pattern: <ul style="list-style-type:circle"><li><i>example</i></li></ul>
    final exampleRegex = RegExp(
      r'<ul[^>]*style="list-style-type:circle"[^>]*>.*?<i>(.*?)</i>',
      dotAll: true,
    );
    final match = exampleRegex.firstMatch(liContent);
    
    if (match != null) {
      var example = match.group(1) ?? '';
      example = _stripHtmlTags(example);
      return example.trim();
    }
    
    return null;
  }

  /// Strip all HTML tags from text
  static String _stripHtmlTags(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  /// Parse simple text format (fallback if HTML parsing fails)
  static DictionaryEntry parseSimpleText(String word, String text) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    
    final definitions = lines.map((line) {
      return Definition(text: line.trim());
    }).toList();

    return DictionaryEntry(
      word: word,
      phonetic: '',
      meanings: [
        PartOfSpeech(
          type: 'general',
          definitions: definitions,
        ),
      ],
    );
  }
}
