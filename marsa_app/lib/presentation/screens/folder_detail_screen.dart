import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/data/models/folder_model.dart';
import 'package:marsa_app/data/models/word_model.dart';
import 'package:marsa_app/data/repositories/dictionary_repository.dart';
import 'package:marsa_app/logic/blocs/word/word_bloc.dart';
import 'package:marsa_app/logic/blocs/word/word_event.dart';
import 'package:marsa_app/logic/blocs/word/word_state.dart';
import 'package:marsa_app/presentation/screens/practice_modes/flashcards_screen.dart';
import 'package:marsa_app/presentation/screens/practice_modes/learn_screen.dart';
import 'package:marsa_app/presentation/screens/practice_modes/match_screen.dart';
import 'package:marsa_app/presentation/screens/practice_modes/test_screen.dart';

class FolderDetailScreen extends StatefulWidget {
  final FolderModel folder;


  const FolderDetailScreen({
    super.key,
    required this.folder,
  });

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  late WordBloc _wordBloc;

  @override
  void initState() {
    super.initState();
    // Get the DictionaryRepository from the context
    final dictionaryRepository = context.read<DictionaryRepository>();
    
    // Create a WordBloc instance
    _wordBloc = WordBloc(dictionaryRepository: dictionaryRepository);
    
    // Load words for this folder
    _wordBloc.add(LoadWords(widget.folder.id));
  }

  @override
  void dispose() {
    // Close the bloc when the screen is disposed
    _wordBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WordBloc, WordState>(
      bloc: _wordBloc,
      listenWhen: (previous, current) => current is WordError,
      listener: (context, state) {
        if (state is WordError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game buttons section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Practice Modes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16.0),
                Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  children: [
                    BlocBuilder<WordBloc, WordState>(
                      bloc: _wordBloc,
                      builder: (context, state) {
                        // Determine if the button should be enabled
                        bool isEnabled = false;
                        List<WordModel> words = [];
                        
                        if (state is WordLoaded) {
                          words = state.words;
                          isEnabled = words.isNotEmpty;
                        }
                        
                        return _buildGameButton(
                          context,
                          'Flashcards',
                          Icons.flip,
                          Colors.blue,
                          isEnabled ? () {
                            // Navigate to FlashcardsScreen with the current words
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FlashcardsScreen(
                                  words: words,
                                ),
                              ),
                            );
                          } : null, // Disable button if no words
                        );
                      },
                    ),
                    BlocBuilder<WordBloc, WordState>(
                      bloc: _wordBloc,
                      builder: (context, state) {
                        // Determine if the button should be enabled
                        bool isEnabled = false;
                        List<WordModel> words = [];
                        
                        if (state is WordLoaded) {
                          words = state.words;
                          isEnabled = words.isNotEmpty;
                        }
                        
                        return _buildGameButton(
                          context,
                          'Learn',
                          Icons.school,
                          Colors.green,
                          isEnabled ? () {
                            // Navigate to LearnScreen with the current words
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LearnScreen(
                                  words: words,
                                ),
                              ),
                            );
                          } : null, // Disable button if no words
                        );
                      },
                    ),
                    BlocBuilder<WordBloc, WordState>(
                      bloc: _wordBloc,
                      builder: (context, state) {
                        // Determine if the button should be enabled
                        bool isEnabled = false;
                        List<WordModel> words = [];
                        
                        if (state is WordLoaded) {
                          words = state.words;
                          // Need at least 4 words for the test mode to work properly
                          // (1 correct answer + 3 wrong options)
                          isEnabled = words.length >= 4;
                        }
                        
                        return _buildGameButton(
                          context,
                          'Test',
                          Icons.quiz,
                          Colors.orange,
                          isEnabled ? () {
                            // Navigate to TestScreen with the current words
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TestScreen(
                                  words: words,
                                ),
                              ),
                            );
                          } : null, // Disable button if not enough words
                        );
                      },
                    ),
                    BlocBuilder<WordBloc, WordState>(
                      bloc: _wordBloc,
                      builder: (context, state) {
                        // Determine if the button should be enabled
                        bool isEnabled = false;
                        List<WordModel> words = [];
                        
                        if (state is WordLoaded) {
                          words = state.words;
                          // Need at least 4 words for the match game to be fun
                          isEnabled = words.length >= 4;
                        }
                        
                        return _buildGameButton(
                          context,
                          'Match',
                          Icons.compare_arrows,
                          Colors.purple,
                          isEnabled ? () {
                            // Navigate to MatchScreen with the current words
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MatchScreen(
                                  words: words,
                                ),
                              ),
                            );
                          } : null, // Disable button if not enough words
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider between sections
          const Divider(thickness: 1.0),

          // Words list section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Words in this folder',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // Words list with BlocBuilder
          Expanded(
            child: BlocBuilder<WordBloc, WordState>(
              bloc: _wordBloc,
              builder: (context, state) {
                if (state is WordLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (state is WordError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.message}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Retry loading words
                            _wordBloc.add(LoadWords(widget.folder.id));
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is WordLoaded) {
                  final words = state.words;
                  
                  if (words.isEmpty) {
                    return const Center(
                      child: Text(
                        'No words in this folder yet. Add your first word!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () async {
                      _wordBloc.add(LoadWords(widget.folder.id));
                      // Wait for the refresh to complete
                      return Future.delayed(const Duration(seconds: 1));
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: words.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                      final word = words[index];
                      return Dismissible(
                        key: Key('word_${word.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          // Show confirmation dialog
                          return await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Word'),
                                content: Text('Are you sure you want to delete "${word.word}"?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ) ?? false; // Return false if dialog is dismissed
                        },
                        onDismissed: (direction) {
                          // Delete the word using BLoC
                          _wordBloc.add(DeleteWord(word.id));
                          
                          // Show a snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('"${word.word}" deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  // Re-add the word (would need to store the meaning too)
                                  _wordBloc.add(AddWord(
                                    word: word.word,
                                    meaning: word.meaning,
                                    folderId: widget.folder.id,
                                  ));
                                },
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          title: Text(
                            word.word,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(word.meaning),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.volume_up),
                                onPressed: () {
                                  // Will be implemented later
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Playing audio for "${word.word}"'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                tooltip: 'Listen',
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // Will be implemented later
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Edit "${word.word}"'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                tooltip: 'Edit',
                              ),
                            ],
                          ),
                          onTap: () {
                            // Will be implemented later
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Viewing details for "${word.word}"'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      );
                      },
                    ),
                  );
                }
                
                // Default case (WordInitial)
                return const Center(
                  child: Text('Loading words...'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddWordDialog(context);
        },
        tooltip: 'Add Word',
        child: const Icon(Icons.add),
      ),
    ),
    );
  }

  // Show dialog to add a new word
  void _showAddWordDialog(BuildContext context) {
    final TextEditingController wordController = TextEditingController();
    final TextEditingController meaningController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isAdding = false;

    // Focus nodes for better keyboard navigation
    final FocusNode wordFocusNode = FocusNode();
    final FocusNode meaningFocusNode = FocusNode();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Word'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: wordController,
                  focusNode: wordFocusNode,
                  decoration: const InputDecoration(labelText: 'Word'),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  enabled: !isAdding,
                  onFieldSubmitted: (_) {
                    // Move to next field when user presses Enter/Next
                    FocusScope.of(context).requestFocus(meaningFocusNode);
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a word';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: meaningController,
                  focusNode: meaningFocusNode,
                  decoration: const InputDecoration(labelText: 'Meaning'),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  enabled: !isAdding,
                  onFieldSubmitted: (_) {
                    // Submit form when user presses Enter/Done on the last field
                    if (formKey.currentState?.validate() ?? false) {
                      _addWord(
                        dialogContext,
                        wordController.text.trim(),
                        meaningController.text.trim(),
                        setState,
                        () => setState(() => isAdding = true),
                      );
                    }
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a meaning';
                    }
                    return null;
                  },
                ),
                if (isAdding)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: [
                        const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: 16),
                        Text('Adding "${wordController.text.trim()}"...'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isAdding ? null : () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isAdding
                  ? null
                  : () {
                      // Validate form
                      if (formKey.currentState?.validate() ?? false) {
                        // Get the word and meaning
                        final word = wordController.text.trim();
                        final meaning = meaningController.text.trim();
                        
                        _addWord(
                          dialogContext,
                          word,
                          meaning,
                          setState,
                          () => setState(() => isAdding = true),
                        );
                      }
                    },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Clean up focus nodes when dialog is closed
      wordFocusNode.dispose();
      meaningFocusNode.dispose();
    });
  }

  // Helper method to add a word and handle UI updates
  void _addWord(BuildContext dialogContext, String word, String meaning, 
      StateSetter setState, VoidCallback onStartAdding) {
    // Show loading state
    onStartAdding();
    
    // Add the word to the folder using the BLoC
    _wordBloc.add(AddWord(
      word: word,
      meaning: meaning,
      folderId: widget.folder.id,
    ));
    
    // Close the dialog
    Navigator.of(dialogContext).pop();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$word" added to folder'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildGameButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
  ) {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
