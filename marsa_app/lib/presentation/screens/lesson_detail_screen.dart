import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:marsa_app/data/models/phrase_model.dart';
import 'package:marsa_app/logic/blocs/voice_lab/lesson_detail_bloc.dart';
import 'package:marsa_app/logic/blocs/voice_lab/lesson_detail_event.dart';
import 'package:marsa_app/logic/blocs/voice_lab/lesson_detail_state.dart';

class LessonDetailScreen extends StatefulWidget {
  final String title;

  const LessonDetailScreen({
    super.key,
    required this.title,
  });
  
  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  // Audio recording instances
  // late final AudioRecorder _audioRecorder;
  late final AudioPlayer _audioPlayer;
  
  // Recording state
  bool _isRecording = false;
  bool _hasPermission = false;
  
  // Map to store recording paths for each phrase
  // final Map<int, String> _recordingPaths = {};
  
  // Currently selected phrase for recording
  //int? _currentRecordingPhraseId;
  
  // Map to track if a phrase has been recorded
  // final Map<int, bool> _hasRecording = {};
  
  @override
  void initState() {
    super.initState();
    // _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();
    _requestPermissions();
  }
  
  @override
  void dispose() {
    // _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
  
  // Request microphone permissions
  Future<void> _requestPermissions() async {
    final status = await Permission.microphone.request();
    setState(() {
      _hasPermission = status == PermissionStatus.granted;
    });
    
    if (!_hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission is required for recording'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Add BlocListener for analysis states
    return BlocListener<LessonDetailBloc, LessonDetailState>(
      listener: (context, state) {
        if (state is AnalysisLoading) {
          // Show loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Analyzing pronunciation...'),
              duration: Duration(seconds: 1),
            ),
          );
        } else if (state is AnalysisSuccess) {
          // Show analysis results dialog
          _showAnalysisResultDialog(context, state);
        } else if (state is AnalysisFailure) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Analysis failed: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructions banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Practice Pronunciation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap on the microphone icon to record your voice and practice pronunciation',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          // Progress indicator with BlocBuilder
          BlocBuilder<LessonDetailBloc, LessonDetailState>(
            builder: (context, state) {
              int totalPhrases = 0;
              if (state is LessonDetailLoaded) {
                totalPhrases = state.phrases.length;
              }
              
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Progress',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          '0/$totalPhrases completed',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.0, // No progress yet
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Phrases list header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Phrases to Practice',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Phrases list with BlocBuilder
          Expanded(
            child: BlocBuilder<LessonDetailBloc, LessonDetailState>(
              builder: (context, state) {
                if (state is LessonDetailLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (state is LessonDetailError) {
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
                            // Retry loading phrases
                            // This would require the lesson to be passed again
                            // For now, just pop back to the previous screen
                            Navigator.pop(context);
                          },
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is LessonDetailLoaded) {
                  final phrases = state.phrases;
                  
                  if (phrases.isEmpty) {
                    return const Center(
                      child: Text(
                        'No phrases available for this lesson.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }
                  
                  return ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: phrases.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final phrase = phrases[index];
                      return _buildPhraseItem(context, phrase.text, index);
                    },
                  );
                }
                
                // Default case (LessonDetailInitial)
                return const Center(
                  child: Text('Loading phrases...'),
                );
              },
            ),
          ),
        ],
      ),
      // Floating action button for starting practice
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showStartPracticeDialog(context);
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start Practice'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    ),
    );
  }
  
  // Start recording for a specific phrase
  /*
  Future<void> _startRecording(int phraseId) async {
    if (!_hasPermission) {
      await _requestPermissions();
      if (!_hasPermission) return;
    }
    
    try {
      // Get temporary directory to store recording
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/recording_$phraseId.m4a';
      
      // Configure recorder
      await _audioRecorder.start(RecordConfig(), path: path);
      
      setState(() {
        _isRecording = true;
        _currentRecordingPhraseId = phraseId;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting recording: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  */
  
  // Stop recording and analyze pronunciation
  /*
  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    
    try {
      final path = await _audioRecorder.stop();
      
      if (path != null && _currentRecordingPhraseId != null) {
        setState(() {
          _recordingPaths[_currentRecordingPhraseId!] = path;
          _hasRecording[_currentRecordingPhraseId!] = true;
          _isRecording = false;
        });
        
        // Get the reference text for the current phrase
        final state = context.read<LessonDetailBloc>().state;
        if (state is LessonDetailLoaded) {
          final phrases = state.phrases;
          if (_currentRecordingPhraseId! < phrases.length) {
            final referenceText = phrases[_currentRecordingPhraseId!].text;
            
            // Dispatch event to analyze pronunciation
            context.read<LessonDetailBloc>().add(
              AnalyzePronunciation(
                filePath: path,
                referenceText: referenceText,
              ),
            );
          }
        }
        
        setState(() {
          _currentRecordingPhraseId = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error stopping recording: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isRecording = false;
        _currentRecordingPhraseId = null;
      });
    }
  }
  */
  
  // Play original audio (simulated with a placeholder message)
  Future<void> _playOriginalAudio(String phrase) async {
    try {
      // In a real app, this would play an audio file from assets or a URL
      // For now, we'll just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Playing original audio for: "$phrase"'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error playing audio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Play recorded audio
  /*
  Future<void> _playRecording(int phraseId) async {
    final path = _recordingPaths[phraseId];
    if (path == null) return;
    
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(path));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error playing recording: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  */

  Widget _buildPhraseItem(BuildContext context, String phrase, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Phrase number
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Phrase text
            Expanded(
              child: Text(
                phrase,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            
            // Listen button
            IconButton(
              icon: const Icon(Icons.volume_up),
              tooltip: 'Listen to original',
              onPressed: () => _playOriginalAudio(phrase),
            ),
            
            // Record button
            IconButton(
               icon: const Icon(Icons.mic),
               tooltip: 'Record',
               onPressed: null, //
            ),
            
            // Play recording button (only shown if there's a recording)
            /*
            if (_hasRecording[index] == true)
              IconButton(
                icon: const Icon(Icons.play_arrow),
                tooltip: 'Play your recording',
                onPressed: () => /*_playRecording*/(index),
              ),
            */  
          ],
        ),
      ),
    );
  }
  
  // Show analysis results dialog
  void _showAnalysisResultDialog(BuildContext context, AnalysisSuccess state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pronunciation Analysis'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall score with circular progress indicator
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: state.overallScore / 100,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          state.overallScore > 80 
                            ? Colors.green 
                            : state.overallScore > 60 
                                ? Colors.orange 
                                : Colors.red,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${state.overallScore}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('Overall'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Feedback message
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: state.overallScore > 80 
                      ? Colors.green.withOpacity(0.1) 
                      : state.overallScore > 60 
                          ? Colors.orange.withOpacity(0.1) 
                          : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: state.overallScore > 80 
                        ? Colors.green 
                        : state.overallScore > 60 
                            ? Colors.orange 
                            : Colors.red,
                    ),
                  ),
                  child: Text(
                    state.feedback,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: state.overallScore > 80 
                        ? Colors.green[800] 
                        : state.overallScore > 60 
                            ? Colors.orange[800] 
                            : Colors.red[800],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Detailed scores
              const Text(
                'Detailed Scores:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildScoreRow('Pronunciation', state.pronunciationScore),
              _buildScoreRow('Fluency', state.fluencyScore),
              const SizedBox(height: 16),
              
              // Word-level scores
              const Text(
                'Word-by-word Analysis:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...state.wordScores.map((wordScore) => _buildWordScoreRow(
                wordScore['word'],
                wordScore['score'],
                wordScore['feedback'],
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  // Helper method to build score row
  Widget _buildScoreRow(String label, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Text(
                '$score',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(' / 100'),
            ],
          ),
        ],
      ),
    );
  }
  
  // Helper method to build word score row
  Widget _buildWordScoreRow(String word, int score, String feedback) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            word,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: score > 80 
                    ? Colors.green 
                    : score > 60 
                        ? Colors.orange 
                        : Colors.red,
                ),
                child: Center(
                  child: Text(
                    '$score',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                feedback,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showRecordingDialog(BuildContext context, String phrase, int phraseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Your Voice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Repeat the phrase:',
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              phrase,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'Press and hold to record',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onLongPress: () {
                // _startRecording(phraseId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Recording started...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              onLongPressEnd: (_) {
                // _stopRecording().then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Recording stopped and saved'),
                    duration: Duration(seconds: 1),
                  ),
                );
                Navigator.pop(context);
                // });
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  void _showStartPracticeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Practice Session'),
        content: const Text(
          'Would you like to start a guided practice session? '
          'The app will guide you through each phrase one by one.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Will be implemented later
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Guided practice will be available soon!'),
                ),
              );
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
  
}
