import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:marsa_app/data/models/dictionary_entry_model.dart';

/// Word Result Card - Displays dictionary entry with glassmorphism
class WordResultCard extends StatelessWidget {
  final DictionaryEntry entry;
  final VoidCallback? onAddToFolder;
  final VoidCallback? onPlayAudio;
  final VoidCallback? onToggleFavorite;
  final bool isFavorite;

  const WordResultCard({
    super.key,
    required this.entry,
    this.onAddToFolder,
    this.onPlayAudio,
    this.onToggleFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0x38FFFFFF), // rgba(255, 255, 255, 0.22)
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Word + Icons
                _buildHeader(),

                const Divider(color: Colors.white24, height: 1),

                // Content: HTML rendered
                _buildContent(),

                const Divider(color: Colors.white24, height: 1),

                // Actions: Add to Folder button
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Word - Large Bold
                Text(
                  entry.word,
                  style: const TextStyle(
                    color: Color(0xFF1800ad),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'League Spartan',
                  ),
                ),
                if (entry.phonetic.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  // Phonetic - Italic Grey
                  Text(
                    entry.phonetic,
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Audio Icon
          if (onPlayAudio != null)
            IconButton(
              icon: const Icon(
                Icons.volume_up_rounded,
                color: Color(0xFFf64a00),
                size: 28,
              ),
              onPressed: onPlayAudio,
            ),
          // Star Icon
          if (onToggleFavorite != null)
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: const Color(0xFFf64a00),
                size: 28,
              ),
              onPressed: onToggleFavorite,
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(maxHeight: 400),
      child: SingleChildScrollView(
        child: entry.rawHtml != null && entry.rawHtml!.isNotEmpty
            ? Html(
                data: entry.rawHtml!,
                style: {
                  "body": Style(
                    color: const Color(0xFF4B4B4B),
                    fontSize: FontSize(15),
                    lineHeight: const LineHeight(1.5),
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                  ),
                  "h1": Style(
                    color: const Color(0xFF1800ad),
                    fontSize: FontSize(20),
                    fontWeight: FontWeight.bold,
                    margin: Margins.symmetric(vertical: 8),
                  ),
                  "h2": Style(
                    color: const Color(0xFFf64a00),
                    fontSize: FontSize(16),
                    fontWeight: FontWeight.bold,
                    margin: Margins.only(top: 12, bottom: 8),
                  ),
                  "h3": Style(
                    color: const Color(0xFF999999),
                    fontSize: FontSize(14),
                    fontStyle: FontStyle.italic,
                    margin: Margins.symmetric(vertical: 4),
                  ),
                  "li": Style(
                    margin: Margins.symmetric(vertical: 4),
                    lineHeight: const LineHeight(1.6),
                  ),
                  "ul": Style(
                    margin: Margins.only(left: 16),
                    padding: HtmlPaddings.zero,
                  ),
                },
              )
            : _buildStructuredContent(),
      ),
    );
  }

  Widget _buildStructuredContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entry.meanings.map((meaning) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Part of Speech
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFf64a00),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  meaning.type,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Definitions
              ...meaning.definitions.asMap().entries.map((entry) {
                final index = entry.key;
                final def = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}. ',
                            style: const TextStyle(
                              color: Color(0xFFf64a00),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              def.text,
                              style: const TextStyle(
                                color: Color(0xFF4B4B4B),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (def.example != null && def.example!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            '"${def.example}"',
                            style: const TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onAddToFolder,
          icon: const Icon(Icons.folder_outlined, size: 20),
          label: const Text('Add to Folder'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFf64a00),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
