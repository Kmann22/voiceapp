import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async'; // Import for Timer
import 'dart:convert';

import 'pages/word_frequency.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI-Powered Word Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.amber,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.amber),
          titleTextStyle: TextStyle(
            color: Colors.amber,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.amber,
          ),
        ),
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.amber),
          bodyText2: TextStyle(color: Colors.amber),
          headline6: TextStyle(
            color: Colors.amber,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: WordCounterScreen(),
    );
  }
}

class WordCounterScreen extends StatefulWidget {
  @override
  _WordCounterScreenState createState() => _WordCounterScreenState();
}

class _WordCounterScreenState extends State<WordCounterScreen> {
  bool isRecording = false;
  bool isPaused = false;
  int wordCount = 0;
  String lastWords = '';
  late stt.SpeechToText _speech;
  bool _isListening = false;
  Map<String, int> wordFrequencies = {};

  // Variables to track session time
  Timer? _timer;
  Duration _sessionDuration = Duration();
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadWordFrequencies();
  }

  void _startRecording() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      setState(() {
        isRecording = true;
        isPaused = false;
        _isListening = true;
        _startTime = DateTime.now(); // Record start time
        _sessionDuration = Duration(); // Reset duration
        _startTimer(); // Start the timer
      });
      _speech.listen(
        onResult: (val) {
          setState(() {
            lastWords = val.recognizedWords;
            wordCount = _countWords(lastWords);
            if (val.finalResult) {
              _updateWordFrequencies(lastWords);
            }
          });
        },
      );
    }
  }

  void _pauseRecording() {
    if (_isListening) {
      setState(() {
        isPaused = true;
        _isListening = false;
        _timer?.cancel(); // Pause the timer
      });
      _speech.stop();
    }
  }

  void _resumeRecording() {
    if (!isRecording) {
      _startRecording();
    } else {
      setState(() {
        isPaused = false;
        _isListening = true;
        _startTimer(); // Resume the timer
      });
      _speech.listen(
        onResult: (val) {
          setState(() {
            lastWords = val.recognizedWords;
            wordCount = _countWords(lastWords);
            if (val.finalResult) {
              _updateWordFrequencies(lastWords);
            }
          });
        },
      );
    }
  }

  void _stopRecording() {
    setState(() {
      isRecording = false;
      isPaused = false;
      _isListening = false;
      _timer?.cancel(); // Stop the timer
    });
    _speech.stop();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _sessionDuration = DateTime.now().difference(_startTime!);
      });
    });
  }

  int _countWords(String text) {
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  void _updateWordFrequencies(String text) {
    List<String> words =
        text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
    for (String word in words) {
      wordFrequencies.update(word, (value) => value + 1, ifAbsent: () => 1);
    }
    _saveWordFrequencies();
  }

  void _saveWordFrequencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedData = jsonEncode(wordFrequencies);
    await prefs.setString('wordFrequencies', encodedData);
  }

  void _loadWordFrequencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encodedData = prefs.getString('wordFrequencies');
    if (encodedData != null) {
      setState(() {
        wordFrequencies = Map<String, int>.from(jsonDecode(encodedData));
      });
    }
  }

  void _navigateToWordFrequencyScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WordFrequencyScreen(wordFrequencies: wordFrequencies),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('AI-Powered Word Counter'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display the session duration
            Text(
              'Session Duration: ${_sessionDuration.inHours.toString().padLeft(2, '0')}:${(_sessionDuration.inMinutes % 60).toString().padLeft(2, '0')}:${(_sessionDuration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Display the word count
            Text(
              'Word Count: $wordCount',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Display the recognized words in real-time
            Text(
              'Recognized Words: $lastWords',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),

            // Start, Pause/Resume, and Stop buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: isRecording ? null : _startRecording,
                  icon: Icon(Icons.mic),
                  label: Text('Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isRecording
                      ? (isPaused ? _resumeRecording : _pauseRecording)
                      : null,
                  icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                  label: Text(isPaused ? 'Resume' : 'Pause'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: !isRecording ? null : _stopRecording,
                  icon: Icon(Icons.stop),
                  label: Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),

            // Button to navigate to the Word Frequency Screen
            ElevatedButton.icon(
              onPressed: wordFrequencies.isNotEmpty
                  ? _navigateToWordFrequencyScreen
                  : null,
              icon: Icon(Icons.bar_chart),
              label: Text('Show Word Frequency'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
