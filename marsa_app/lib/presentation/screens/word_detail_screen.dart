import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:marsa_app/data/models/dictionary_entry_model.dart';

class WordDetailScreen extends StatelessWidget {
  final DictionaryEntry entry;

  const WordDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    // Color scheme based on theme
    final backgroundColor = isDarkMode ? const Color(0xFF0A0E27) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF4B4B4B);
    final accentOrange = const Color(0xFFf64a00);
    final accentBlue = const Color(0xFF1800ad);
    final subtleTextColor = isDarkMode
        ? const Color(0xFF999999)
        : const Color(0xFF999999);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          entry.word,
          style: TextStyle(
            color: accentOrange,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: textColor),
            onPressed: () {
              // TODO: Open search
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Card with Word, Phonetic, and Action Buttons
          _buildHeaderCard(
            context,
            isDarkMode: isDarkMode,
            textColor: textColor,
            accentOrange: accentOrange,
            accentBlue: accentBlue,
            subtleTextColor: subtleTextColor,
          ),

          const SizedBox(height: 24),

          // Part of Speech Label
          Text(
            'danh từ',
            style: TextStyle(
              color: accentOrange,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          // HTML Content
          _buildContent(
            context,
            isDarkMode: isDarkMode,
            textColor: textColor,
            accentOrange: accentOrange,
            accentBlue: accentBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context, {
    required bool isDarkMode,
    required Color textColor,
    required Color accentOrange,
    required Color accentBlue,
    required Color subtleTextColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0x22FFFFFF) // Lighter glassmorphism for dark mode
                : const Color(0x38FFFFFF), // rgba(255, 255, 255, 0.22)
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Word and Phonetic
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    entry.word,
                    style: TextStyle(
                      color: accentOrange,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'League Spartan',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    entry.phonetic.isNotEmpty ? entry.phonetic : '/lʌv/',
                    style: TextStyle(
                      color: subtleTextColor,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action Buttons Row
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.volume_up_rounded,
                    label: 'Ghi chú',
                    color: accentBlue,
                    onTap: () {
                      // TODO: Play audio
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    icon: Icons.note_add_rounded,
                    label: 'Ghi chú',
                    color: accentOrange,
                    onTap: () {
                      // TODO: Add note
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    icon: Icons.bookmark_border_rounded,
                    label: 'Ghi chú',
                    color: accentBlue,
                    onTap: () {
                      // TODO: Bookmark
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required bool isDarkMode,
    required Color textColor,
    required Color accentOrange,
    required Color accentBlue,
  }) {
    if (entry.rawHtml != null && entry.rawHtml!.isNotEmpty) {
      return Text(
        entry.rawHtml!.replaceAll(RegExp(r'<[^>]*>'), ''),
        style: TextStyle(color: textColor, fontSize: 15, height: 1.6),
      );
    }

    // Fallback to structured content
    return _buildStructuredContent(
      textColor: textColor,
      accentOrange: accentOrange,
      accentBlue: accentBlue,
    );
  }

  Widget _buildStructuredContent({
    required Color textColor,
    required Color accentOrange,
    required Color accentBlue,
  }) {
    // Fallback - show meanings from DictionaryEntry model
    if (entry.meanings.isEmpty) {
      return Text(
        'No definition available',
        style: TextStyle(color: textColor, fontSize: 15, height: 1.6),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final meaning in entry.meanings)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meaning.type,
                  style: TextStyle(
                    color: accentOrange,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                for (final definition in meaning.definitions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: textColor)),
                            Expanded(
                              child: Text(
                                definition.text,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (definition.example != null &&
                            definition.example!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 4),
                            child: Text(
                              definition.example!,
                              style: TextStyle(
                                color: accentBlue,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
