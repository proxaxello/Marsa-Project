import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/data/models/folder_model.dart';
import 'package:marsa_app/data/models/word_model.dart';
import 'package:marsa_app/logic/blocs/word/word_bloc.dart';
import 'package:marsa_app/logic/blocs/word/word_event.dart';
import 'package:marsa_app/logic/blocs/word/word_state.dart';
import 'package:marsa_app/presentation/theme/neo_brutal_theme.dart';

class MultipleChoiceScreen extends StatefulWidget {
  final FolderModel folder;

  const MultipleChoiceScreen({super.key, required this.folder});

  @override
  State<MultipleChoiceScreen> createState() => _MultipleChoiceScreenState();
}

class _MultipleChoiceScreenState extends State<MultipleChoiceScreen> {
  int _currentQuestion = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;
  List<QuizQuestion> _gameQuestions = [];
  List<WordModel> _words = [];

  @override
  void initState() {
    super.initState();
    // Load words from folder
    context.read<WordBloc>().add(LoadWords(widget.folder.id));
  }

  void _generateQuestions(List<WordModel> words) {
    if (words.length < 4) return;

    final shuffled = List<WordModel>.from(words)..shuffle();
    final selectedWords = shuffled.take(10).toList();

    _gameQuestions = selectedWords.map((word) {
      final wrongAnswers = words
          .where((w) => w.id != word.id)
          .toList()
        ..shuffle();
      
      final wrongOptions = wrongAnswers
          .take(3)
          .map((w) => w.meaning)
          .toList();

      final allOptions = [word.meaning, ...wrongOptions]..shuffle();

      return QuizQuestion(
        word: word.word,
        correctAnswer: word.meaning,
        options: allOptions,
      );
    }).toList();

    setState(() {});
  }

  void _handleAnswer(String answer) {
    if (_showResult) return;

    setState(() {
      _selectedAnswer = answer;
      _isCorrect = answer == _gameQuestions[_currentQuestion].correctAnswer;
      if (_isCorrect) {
        _score++;
      }
      _showResult = true;
    });
  }

  void _handleNext() {
    if (_currentQuestion < _gameQuestions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _showResult = false;
        _isCorrect = false;
      });
    }
  }

  void _resetGame() {
    setState(() {
      _currentQuestion = 0;
      _score = 0;
      _selectedAnswer = null;
      _showResult = false;
      _isCorrect = false;
    });
    _generateQuestions(_words);
  }

  bool get _isGameOver =>
      _currentQuestion >= _gameQuestions.length - 1 && _showResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: NeoBrutalTheme.electricYellow,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MULTIPLE CHOICE',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.black,
            height: 4,
          ),
        ),
      ),
      body: BlocConsumer<WordBloc, WordState>(
        listener: (context, state) {
          if (state is WordLoaded) {
            _words = state.words;
            if (_words.length >= 4 && _gameQuestions.isEmpty) {
              _generateQuestions(_words);
            }
          }
        },
        builder: (context, state) {
          if (state is WordLoading) {
            return _buildLoadingState();
          }

          if (state is WordLoaded) {
            if (_words.length < 4) {
              return _buildInsufficientWordsState();
            }

            if (_gameQuestions.isEmpty) {
              return _buildLoadingState();
            }

            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isGameOver ? _buildGameOver() : _buildGamePlay(),
                ),
              ),
            );
          }

          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NeoBrutalTheme.electricYellow,
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(8, 8),
            ),
          ],
        ),
        child: const Text(
          'LOADING...',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildInsufficientWordsState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NeoBrutalTheme.electricYellow,
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(8, 8),
            ),
          ],
        ),
        child: const Text(
          'ADD AT LEAST 4 WORDS TO PLAY',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildGamePlay() {
    final currentQ = _gameQuestions[_currentQuestion];

    return Column(
      children: [
        // Header Stats
        _buildHeader(),
        const SizedBox(height: 24),

        // Question
        _buildQuestion(currentQ.word),
        const SizedBox(height: 24),

        // Options
        _buildOptions(currentQ),
        const SizedBox(height: 24),

        // Next Button
        if (_showResult) _buildNextButton(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: Text(
            '${_currentQuestion + 1}/${_gameQuestions.length}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF39FF14),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: NeoBrutalTheme.electricYellow,
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: Text(
            'SCORE: $_score',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion(String word) {
    return Transform.rotate(
      angle: -0.01,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: NeoBrutalTheme.hotPink,
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(8, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'TRANSLATE THIS WORD:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              word.toUpperCase(),
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions(QuizQuestion question) {
    return Column(
      children: List.generate(
        question.options.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildOptionButton(
            option: question.options[index],
            index: index,
            correctAnswer: question.correctAnswer,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String option,
    required int index,
    required String correctAnswer,
  }) {
    final isSelected = _selectedAnswer == option;
    final isCorrectAnswer = option == correctAnswer;

    Color bgColor = Colors.white;
    if (_showResult && isCorrectAnswer) {
      bgColor = NeoBrutalTheme.neonGreen;
    } else if (_showResult && isSelected && !_isCorrect) {
      bgColor = NeoBrutalTheme.hotPink;
    } else if (isSelected) {
      bgColor = NeoBrutalTheme.cyanBlue;
    }

    final rotation = index % 2 == 0 ? 0.01 : -0.01;

    return Transform.rotate(
      angle: rotation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleAnswer(option),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: _showResult
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black,
                        offset: const Offset(4, 4),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Text(
                  '${String.fromCharCode(65 + index)}.',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (_showResult && isCorrectAnswer)
                  const Icon(
                    Icons.check_circle,
                    size: 32,
                    color: Colors.black,
                  ),
                if (_showResult && isSelected && !_isCorrect)
                  const Icon(
                    Icons.cancel,
                    size: 32,
                    color: Colors.black,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: _handleNext,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.black, width: 4),
        ),
        child: Text(
          _currentQuestion < _gameQuestions.length - 1
              ? 'NEXT QUESTION →'
              : 'SEE RESULTS →',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFFE500),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    final percentage = (_score / _gameQuestions.length);
    String message;
    if (_score == _gameQuestions.length) {
      message = 'PERFECT SCORE!';
    } else if (percentage >= 0.7) {
      message = 'GREAT JOB!';
    } else if (percentage >= 0.5) {
      message = 'GOOD EFFORT!';
    } else {
      message = 'KEEP PRACTICING!';
    }

    return Column(
      children: [
        Transform.rotate(
          angle: 0.02,
          child: Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: NeoBrutalTheme.electricYellow,
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  offset: const Offset(8, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'GAME OVER!',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  '$_score/${_gameQuestions.length}',
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _resetGame,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: NeoBrutalTheme.neonGreen,
                    border: Border.all(color: Colors.black, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.refresh, size: 24, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'PLAY AGAIN',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.arrow_back, size: 24, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'BACK',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class QuizQuestion {
  final String word;
  final String correctAnswer;
  final List<String> options;

  QuizQuestion({
    required this.word,
    required this.correctAnswer,
    required this.options,
  });
}
